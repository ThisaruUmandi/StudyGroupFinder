//
//  CreateSessionView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-29.
//

import SwiftUI
import MapKit

struct CreateSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = CreateSessionViewModel()

    @State private var showLocationPicker = false

    let group: StudyGroup

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                header
                sectionLabel("SESSION DETAILS").padding(.top, 28)
                detailsCard.padding(.top, 8)
                sectionLabel("SESSION TYPE").padding(.top, 24)
                KSegmentControl(
                    options: ["Online", "Physical"],
                    selected: $vm.sessionType
                )
                //.frame(maxWidth: .infinity)
                .padding(.top, 8)

                if vm.isOnline {
                    sectionLabel("LINK").padding(.top, 24)
                    linkCard.padding(.top, 8)
                } else {
                    sectionLabel("MEETING LOCATION").padding(.top, 24)
                    locationCard.padding(.top, 8)
                }

                sectionLabel("DATE & TIME").padding(.top, 24)
                dateTimeCard.padding(.top, 8)

                scheduleButton
                    .padding(.top, 32)
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: $showLocationPicker) {
            LocationPickerView(
                selectedCoordinate: $vm.selectedCoordinate,
                locationName: $vm.locationName
            )
        }
        .onChange(of: vm.didSave) { _, saved in
            if saved { dismiss() }
        }
        .alert("Error", isPresented: $vm.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .padding(.bottom, 16)

                Text("Schedule a")
                    .font(.system(size: 28, weight: .bold))
                Text("New Session")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: "#6B3FD4"))
            }
            Spacer()
            Image("oboy_l")
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .offset(y: -8)
                .padding(.trailing, -20)
        }
    }

    private var detailsCard: some View {
        VStack(spacing: 0) {
            inputRow(
                icon: "book",
                iconColor: Color(hex: "#1D9E75"),
                bgColor: Color(hex: "#E0F5EE"),
                label: "SESSION TITLE",
                placeholder: "e.g. Related Subject is here",
                text: $vm.title
            )
            Divider().padding(.leading, 54)
            inputRow(
                icon: "message",
                iconColor: Color(hex: "#BA7517"),
                bgColor: Color(hex: "#FAEEDA"),
                label: "DESCRIPTION",
                placeholder: "e.g. Group details, goals, Expectations...",
                text: $vm.description
            )
        }
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .primary.opacity(0.05), radius: 8, x: 0, y: 3)
    }

    private var linkCard: some View {
        inputRow(
            icon: "link",
            iconColor: Color(hex: "#1D9E75"),
            bgColor: Color(hex: "#E0F5EE"),
            label: "LINK",
            placeholder: "e.g. paste your meeting link here...",
            text: $vm.joinLink
        )
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .primary.opacity(0.05), radius: 8, x: 0, y: 3)
    }

    private var locationCard: some View {
        VStack(spacing: 10) {
            if let coord = vm.selectedCoordinate {
                Map(coordinateRegion: .constant(MKCoordinateRegion(
                    center: coord,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )), annotationItems: [PinItem(coordinate: coord)]) { item in
                    MapMarker(coordinate: item.coordinate,
                              tint: Color(hex: "#0300BF"))
                }
                .frame(height: 150)
                .cornerRadius(12)
                .disabled(true)

                if !vm.locationName.isEmpty {
                    Text(vm.locationName.uppercased())
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                }

                Button {
                    showLocationPicker = true
                } label: {
                    HStack {
                        Text("Refine location")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#0300BF"))
                        Spacer()
                        Image(systemName: "map")
                            .foregroundColor(Color(hex: "#0300BF"))
                    }
                }
            } else {
                Button {
                    showLocationPicker = true
                } label: {
                    HStack(spacing: 12) {
                        KIconBox(
                            icon: "mappin.and.ellipse",
                            iconColor: Color(hex: "#6B3FD4"),
                            bgColor: Color(hex: "#EDE7FF"),
                            size: 34,
                            cornerRadius: 17,
                            iconSize: 14
                        )
                        VStack(alignment: .leading, spacing: 2) {
                            Text("LOCATION")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.secondary)
                            Text("Tap to pick meeting location")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(14)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var dateTimeCard: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("DATE")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                HStack(spacing: 8) {
                    KIconBox(
                        icon: "calendar",
                        iconColor: Color(hex: "#258BF1"),
                        bgColor: Color(hex: "#258BF1").opacity(0.15),
                        size: 30,
                        cornerRadius: 15,
                        iconSize: 13
                    )
                    DatePicker("", selection: $vm.date, displayedComponents: .date)
                        .labelsHidden()
                        .tint(Color(hex: "#0300BF"))
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .primary.opacity(0.05), radius: 8, x: 0, y: 3)

            VStack(alignment: .leading, spacing: 6) {
                Text("START TIME")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                HStack(spacing: 8) {
                    KIconBox(
                        icon: "clock",
                        iconColor: Color(hex: "#FF8C00"),
                        bgColor: Color(hex: "#FF8C00").opacity(0.15),
                        size: 30,
                        cornerRadius: 15,
                        iconSize: 13
                    )
                    DatePicker("", selection: $vm.startTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .tint(Color(hex: "#0300BF"))
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .primary.opacity(0.05), radius: 8, x: 0, y: 3)
        }
    }

    private var scheduleButton: some View {
        Button {
            Task { await vm.save(for: group) }
        } label: {
            ZStack {
                if vm.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Schedule Session")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(vm.isValid ? Color(hex: "#0300BF") : Color(.systemGray4))
            .clipShape(Capsule())
        }
        .disabled(!vm.isValid || vm.isLoading)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.secondary)
            .tracking(0.5)
    }

    private func inputRow(
        icon: String,
        iconColor: Color,
        bgColor: Color,
        label: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        HStack(spacing: 12) {
            KIconBox(
                icon: icon,
                iconColor: iconColor,
                bgColor: bgColor,
                size: 34,
                cornerRadius: 17,
                iconSize: 14
            )
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                TextField(placeholder, text: text)
                    .font(.system(size: 14))
            }
        }
        .padding(14)
    }
}

private struct PinItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

#Preview {
    NavigationStack {
        CreateSessionView(group: StudyGroup(
            groupId: "preview",
            name: "iOS Dev",
            subject: "iOS Development",
            major: "Computer Science",
            description: "Test",
            createdBy: "uid1",
            members: ["uid1"],
            privacy: "public",
            university: "NIBM",
            createdAt: Date()
        ))
        .environmentObject(AuthViewModel())
    }
}
