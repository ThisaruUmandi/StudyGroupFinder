//
//  HomeView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-07.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Home Screen")
                    .font(.title)

                NavigationLink("Go to Next Screen") {
                    Text("Next Screen")
                }
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
}
