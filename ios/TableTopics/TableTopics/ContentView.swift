// ContentView.swift
// Main content view for Table Topics — forced dark mode

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            LeadListView()
                .tabItem {
                    Label("Leads", systemImage: "person.crop.rectangle.stack")
                }

            ContractorSearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
        }
        .tint(.brandBlue)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}