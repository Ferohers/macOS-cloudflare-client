//
//  SidebarView.swift
//  Flare
//
//  Navigation sidebar with branding, sections, and user info
//

import SwiftUI

struct SidebarView: View {
    @Environment(AppState.self) private var appState
    var body: some View {
        VStack(spacing: 0) {
            // Branding header
            brandingHeader

            Divider()
                .background(FlareColors.borderPrimary)

            List(selection: Binding(
                get: { appState.selectedItem },
                set: { newItem in
                    if let item = newItem {
                        appState.selectedItem = item
                        if case .worker = item, appState.workers.isEmpty {
                            Task { await appState.loadWorkers() }
                        }
                        if case .zone(let id) = item, let zone = appState.zones.first(where: { $0.id == id }) {
                            Task { await appState.loadDNSRecords(for: zone) }
                        }
                    }
                }
            )) {
                Section("Zones") {
                    let visibleZones = appState.zones.filter { !appState.hiddenZoneIds.contains($0.id) }
                    if appState.isLoadingZones && visibleZones.isEmpty {
                        Text("Loading...").foregroundStyle(FlareColors.textTertiary)
                    } else if visibleZones.isEmpty {
                        Text("No zones").foregroundStyle(FlareColors.textTertiary)
                    } else {
                        ForEach(visibleZones) { zone in
                            NavigationLink(value: SidebarItem.zone(zone.id)) {
                                Label(zone.name, systemImage: "globe")
                            }
                        }
                    }
                }
                
                Section("Workers") {
                    if appState.isLoadingWorkers && appState.workers.isEmpty {
                        Text("Loading...").foregroundStyle(FlareColors.textTertiary)
                    } else if appState.workers.isEmpty {
                        Text("No workers").foregroundStyle(FlareColors.textTertiary)
                    } else {
                        ForEach(appState.workers) { worker in
                            NavigationLink(value: SidebarItem.worker(worker.id)) {
                                Label(worker.displayName, systemImage: "chevron.left.forwardslash.chevron.right")
                            }
                        }
                    }
                }
                
                Section("Preferences") {
                    NavigationLink(value: SidebarItem.settings) {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
            .listStyle(.sidebar)
            .tint(FlareColors.cloudflareOrange)
            .listItemTint(FlareColors.cloudflareOrange)
            .scrollContentBackground(.hidden)
            .background(Color.clear)

            // User info footer
            userFooter
        }
        .frame(minWidth: 200)
        .background(FlareColors.bgSecondary)
        .onAppear {
            if appState.workers.isEmpty {
                Task { await appState.loadWorkers() }
            }
        }
    }

    // MARK: - Branding

    private var brandingHeader: some View {
        HStack(spacing: FlareSpacing.sm) {
            Image(systemName: "flame.fill")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [FlareColors.cloudflareOrange, FlareColors.cloudflareOrangeLight],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )

            Text("Flare")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(FlareColors.textPrimary)

            Spacer()
        }
        .padding(.horizontal, FlareSpacing.lg)
        .padding(.vertical, FlareSpacing.lg)
    }

    // MARK: - User Footer

    private var userFooter: some View {
        VStack(spacing: 0) {
            Divider()
                .background(FlareColors.borderPrimary)
                .padding(.horizontal, FlareSpacing.lg)

            HStack(spacing: FlareSpacing.sm) {
                // Connected Icon
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [FlareColors.statusActive, FlareColors.statusActive.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    )

                VStack(alignment: .leading, spacing: 1) {
                    Text("Connected")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(FlareColors.textPrimary)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Text("Cloudflare API")
                        .font(.system(size: 9))
                        .foregroundStyle(FlareColors.textTertiary)
                }

                Spacer()
            }
            .padding(.horizontal, FlareSpacing.lg)
            .padding(.vertical, FlareSpacing.md)
        }
    }
}
