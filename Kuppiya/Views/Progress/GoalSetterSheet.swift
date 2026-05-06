//
//  GoalSetterSheet.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-06.
//

import SwiftUI

struct GoalSetterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedHours: Double

    let onSave: (Double) -> Void
    let options: [Double] = [1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 15, 20]

    init(currentGoal: Double, onSave: @escaping (Double) -> Void) {
        _selectedHours = State(initialValue: currentGoal)
        self.onSave    = onSave
    }

    var body: some View {
        VStack(spacing: 0) {

            // Handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(.systemGray4))
                .frame(width: 40, height: 5)
                .padding(.top, 12)

            Text("Weekly Study Goal")
                .font(.system(size: 17, weight: .semibold))
                .padding(.top, 20)

            Text("How many hours do you want to study per week in this group?")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 8)

            // Ring preview
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 12)
                    .frame(width: 120, height: 120)
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        Color(hex: "#0300BF"),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 2) {
                    Text(String(format: "%.0fh", selectedHours))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "#0300BF"))
                    Text("/ week")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 28)

            // Options grid
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 4),
                spacing: 12
            ) {
                ForEach(options, id: \.self) { hours in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedHours = hours
                        }
                    } label: {
                        Text(String(format: "%.0fh", hours))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(
                                selectedHours == hours
                                    ? .white
                                    : Color(hex: "#0300BF")
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                selectedHours == hours
                                    ? Color(hex: "#0300BF")
                                    : Color(hex: "#0300BF").opacity(0.08)
                            )
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal, 24)

            // Save button
            Button {
                onSave(selectedHours)
                dismiss()
            } label: {
                Text("Save Goal")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "#0300BF"))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 40)
        }
        .background(Color(UIColor.systemBackground))
    }
}
