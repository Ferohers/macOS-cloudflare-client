//
//  SidebarView.swift
//  Flare
//
//  Frosted glass navigation sidebar — macOS Tahoe Liquid Glass
//

import SwiftUI

struct SidebarView: View {
    @Environment(AppState.self) private var appState
    var body: some View {
        VStack(spacing: 0) {
            // Branding header
            brandingHeader

            List {
                Section {
                    let visibleZones = appState.zones.filter { !appState.hiddenZoneIds.contains($0.id) }
                    if appState.isLoadingZones && visibleZones.isEmpty {
                        Text("Loading...")
                            .foregroundStyle(FlareColors.textTertiary)
                            .font(.system(size: 12))
                    } else if visibleZones.isEmpty {
                        Text("No zones")
                            .foregroundStyle(FlareColors.textTertiary)
                            .font(.system(size: 12))
                    } else {
                        ForEach(visibleZones) { zone in
                            sidebarButton(
                                title: zone.name,
                                icon: "globe",
                                isSelected: appState.selectedItem == .zone(zone.id)
                            ) {
                                appState.selectZone(zone)
                            }
                        }
                    }
                } header: {
                    Text("Zones")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(FlareColors.textPrimary)
                        .tracking(0.8)
                }
                
                Section {
                    if appState.isLoadingWorkers && appState.workers.isEmpty {
                        Text("Loading...")
                            .foregroundStyle(FlareColors.textTertiary)
                            .font(.system(size: 12))
                    } else if appState.workers.isEmpty {
                        Text("No workers")
                            .foregroundStyle(FlareColors.textTertiary)
                            .font(.system(size: 12))
                    } else {
                        ForEach(appState.workers) { worker in
                            sidebarButton(
                                title: worker.displayName,
                                icon: "chevron.left.forwardslash.chevron.right",
                                isSelected: appState.selectedItem == .worker(worker.id)
                            ) {
                                appState.selectWorker(worker)
                            }
                        }
                    }
                } header: {
                    Text("Workers")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(FlareColors.textPrimary)
                        .tracking(0.8)
                }
                
                Section {
                    sidebarButton(
                        title: "Settings",
                        icon: "gearshape",
                        isSelected: appState.selectedItem == .settings
                    ) {
                        appState.selectedItem = .settings
                    }
                } header: {
                    Text("Preferences")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(FlareColors.textPrimary)
                        .tracking(0.8)
                }
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
            .background(Color.clear)

            // User info footer — glass element
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
                .shadow(color: FlareColors.cloudflareOrange.opacity(0.4), radius: 6, x: 0, y: 0)

            Text("Flare")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(FlareColors.textPrimary)
                .tracking(0.5)

            Spacer()
        }
        .padding(.horizontal, FlareSpacing.lg)
        .padding(.vertical, FlareSpacing.lg)
    }

    // MARK: - User Footer — Glass element

    private var userFooter: some View {
        VStack(spacing: 0) {
            HStack(spacing: FlareSpacing.sm) {
                // Connected Icon
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [FlareColors.statusActive, FlareColors.statusActive.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 26, height: 26)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                    )
                    .shadow(color: FlareColors.statusActive.opacity(0.3), radius: 4, x: 0, y: 0)

                VStack(alignment: .leading, spacing: 1) {
                    Text("Connected")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(FlareColors.textPrimary)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Text("Cloudflare API")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(FlareColors.textPrimary)
                }

                Spacer()
            }
            .padding(.horizontal, FlareSpacing.md)
            .padding(.vertical, FlareSpacing.sm)
            .glassFooter(cornerRadius: FlareRadius.lg)
        }
        .padding(.horizontal, FlareSpacing.sm)
        .padding(.vertical, FlareSpacing.sm)
    }

    // MARK: - Sidebar Row Helper
    
    private func sidebarButton(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: FlareSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .frame(width: 16)
                
                Text(title)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                
                Spacer()
            }
            .foregroundStyle(isSelected ? FlareColors.textPrimary : FlareColors.textSecondary)
            .padding(.horizontal, FlareSpacing.sm)
            .padding(.vertical, 6)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: FlareRadius.md, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        FlareColors.cloudflareOrange.opacity(0.25),
                                        FlareColors.cloudflareOrange.opacity(0.05)
                                    ],
                                    startPoint: .bottomLeading,
                                    endPoint: .topTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: FlareRadius.md, style: .continuous)
                                    .strokeBorder(FlareColors.cloudflareOrange.opacity(0.2), lineWidth: 0.5)
                            )
                    }
                }
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
