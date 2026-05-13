//
//  ContentView.swift
//  Flare
//
//  Root view router: setup vs. dashboard
//

import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if appState.isAuthenticated {
                MainDashboardView()
                    .frame(minWidth: 900, minHeight: 600)
            } else {
                SetupView()
            }
        }
        .tint(FlareColors.cloudflareOrange)
        .accentColor(FlareColors.cloudflareOrange)
    }
}
