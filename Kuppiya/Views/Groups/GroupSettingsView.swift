//
//  GroupSettingsView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-22.
//

import SwiftUI

struct GroupSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    let group: StudyGroup

    var body: some View {
        NavigationStack {
            Text("Group Settings — Coming Soon")
                .foregroundColor(.secondary)
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Close") { dismiss() }
                    }
                }
        }
    }
}
