//
//  CustomTabBar.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-09.
//

import SwiftUI

struct CustomTabBar: View {
    var activeForeground: Color = .white
    var activeBackground: Color = Color(hex: "0300BF")
    @Binding var activeTab: TabModel
    @EnvironmentObject var tabManager: TabBarViewModel

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabModel.mainTabs, id: \.rawValue) { tab in
                Button {
                    if tabManager.activeTab == .none {
                        tabManager.popToRoot()
                    }
                    activeTab = tab
                } label: {
                    HStack(spacing: 2) {
                        Image(tab.icon)
                            .renderingMode(.template)
                            .font(.title.bold())
                            .frame(width: 30, height: 30)

                        if activeTab == tab {
                            Text(tab.title)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                        }
                    }
                    .padding(.vertical, 8)
                    .foregroundStyle(activeTab == tab ? activeForeground : .primary)
                    .padding(.leading, 20)
                    .padding(.trailing, 15)
                    .background {
                        if activeTab == tab {
                            Capsule()
                                .fill(activeBackground)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    TabBarView()
        .environmentObject(AuthViewModel())
        .environmentObject(TabBarViewModel())
}
