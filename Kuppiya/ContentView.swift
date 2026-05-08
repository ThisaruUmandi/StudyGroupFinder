//
//  ContentView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-01.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "book.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hi, Welcome to KUPPIYA!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

