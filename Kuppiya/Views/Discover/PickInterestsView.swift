import SwiftUI

struct PickInterestsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var viewModel = PickInterestsViewModel()

    var onComplete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Select your interests to discover\nrelevant study groups.")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)

                    chipsGrid.padding(.horizontal, 24)

                    Spacer(minLength: 100)
                }
                .padding(.top, 16)
            }

            footer
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onChange(of: viewModel.didSaveInterests) { _, saved in
            if saved {
                Task {
                    await authVM.refreshUser()
                    onComplete()
                }
            }
        }
    }

    private var header: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 36, height: 36)
                        .background(Color(UIColor.systemBackground))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                }
                .padding(.bottom, 12)

                Text("What are you")
                    .font(.system(size: 28, weight: .bold))
                Text("interested in?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: "#6B3FD4"))
            }

            Spacer()

            Image("oboy_l")
                .resizable()
                .scaledToFit()
                .frame(width: 110)
                .padding(.bottom, -8)
                .padding(.trailing, -25)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 16)
        .background(Color(UIColor.systemBackground))
    }

    private var chipsGrid: some View {
        FlowLayout(spacing: 10) {
            ForEach(viewModel.allInterests, id: \.self) { interest in
                InterestChip(
                    title: interest,
                    isSelected: viewModel.isSelected(interest)
                ) {
                    viewModel.toggle(interest)
                }
            }
        }
    }

    private var footer: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                Task { await viewModel.save() }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#6B3FD4"))
                        .clipShape(Capsule())
                } else {
                    Text(viewModel.selectedInterests.isEmpty
                         ? "Select at least one"
                         : "Continue (\(viewModel.selectedInterests.count) selected)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(viewModel.selectedInterests.isEmpty
                                    ? Color.gray.opacity(0.4)
                                    : Color(hex: "#6B3FD4"))
                        .clipShape(Capsule())
                }
            }
            .disabled(viewModel.selectedInterests.isEmpty || viewModel.isLoading)
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Button {
                Task { await viewModel.skip() }
            } label: {
                Text("Skip for now")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
        .background(Color(UIColor.systemBackground))
    }
}

private struct InterestChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Color(hex: "#6B3FD4") : Color(UIColor.systemBackground))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color(.systemGray4), lineWidth: 1)
                )
                .shadow(color: isSelected
                        ? Color(hex: "#6B3FD4").opacity(0.3)
                        : .black.opacity(0.04),
                        radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .animation(.spring(duration: 0.2), value: isSelected)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows
            .map { $0.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0 }
            .reduce(0) { $0 + $1 + spacing } - spacing
        return CGSize(width: proposal.width ?? 0, height: max(height, 0))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += rowHeight + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubview]] {
        var rows: [[LayoutSubview]] = [[]]
        var x: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > (proposal.width ?? 0), !rows[rows.count - 1].isEmpty {
                rows.append([])
                x = 0
            }
            rows[rows.count - 1].append(subview)
            x += size.width + spacing
        }
        return rows
    }
}

#Preview {
    PickInterestsView(onComplete: {}).environmentObject(AuthViewModel())
}
