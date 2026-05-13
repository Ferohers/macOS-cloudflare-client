//
//  FlareApp.swift
//  Flare
//
//  Created by Altan Duman on 12.05.2026.
//

import SwiftUI

@main
struct FlareApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .frame(
                    minWidth: appState.isAuthenticated ? 900 : 520,
                    maxWidth: appState.isAuthenticated ? .infinity : 520,
                    minHeight: appState.isAuthenticated ? 600 : 460,
                    maxHeight: appState.isAuthenticated ? .infinity : 460
                )
                .background(FlareColors.bgPrimary)
                .preferredColorScheme(.dark)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(appState.isAuthenticated ? .automatic : .contentSize)
        .defaultPosition(.center)
        .defaultSize(
            width: appState.isAuthenticated ? 1200 : 520,
            height: appState.isAuthenticated ? 750 : 460
        )
    }
}
