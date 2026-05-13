//
//  ZonesListView.swift
//  Flare
//
//  Zones list with glass cards — macOS Tahoe Liquid Glass
//

import SwiftUI

struct ZonesListView: View {
    @Environment(AppState.self) private var appState
    @State private var searchText = ""
    @State private var hoveredZoneId: String?

    private var filteredZones: [Zone] {
        let visibleZones = appState.zones.filter { !appState.hiddenZoneIds.contains($0.id) }
        if searchText.isEmpty {
            return visibleZones
        }
        return visibleZones.filter { zone in
            zone.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            SectionHeader(
                title: "Zones",
                subtitle: "\(appState.zones.count) domain\(appState.zones.count == 1 ? "" : "s")",
                action: {
                    Task { await appState.loadZones() }
                },
                actionLabel: "Refresh"
            )
            .padding(.horizontal, FlareSpacing.lg)
            .padding(.top, FlareSpacing.lg)
            .padding(.bottom, FlareSpacing.md)

            // Search — glass-backed
            HStack(spacing: FlareSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12))
                    .foregroundStyle(FlareColors.textTertiary)

                TextField("Search zones...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .foregroundStyle(FlareColors.textPrimary)

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(FlareColors.textTertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(FlareSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: FlareRadius.md, style: .continuous)
                    .fill(FlareColors.glassOverlay)
                    .overlay(
                        RoundedRectangle(cornerRadius: FlareRadius.md, style: .continuous)
                            .strokeBorder(FlareColors.glassBorder, lineWidth: 0.5)
                    )
            )
            .padding(.horizontal, FlareSpacing.lg)
            .padding(.bottom, FlareSpacing.md)

            // Zone list
            if appState.isLoadingZones && appState.zones.isEmpty {
                VStack(spacing: FlareSpacing.sm) {
                    ForEach(0..<5, id: \.self) { _ in
                        LoadingCard()
                    }
                }
                .padding(.horizontal, FlareSpacing.lg)
                Spacer()
            } else if filteredZones.isEmpty {
                EmptyStateView(
                    icon: "globe",
                    title: searchText.isEmpty ? "No Zones" : "No Results",
                    message: searchText.isEmpty
                        ? "No zones found in your account."
                        : "No zones match \"\(searchText)\"."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: FlareSpacing.sm) {
                        ForEach(filteredZones) { zone in
                            ZoneRow(
                                zone: zone,
                                isSelected: appState.selectedItem == .zone(zone.id),
                                isHovered: hoveredZoneId == zone.id
                            )
                            .onTapGesture {
                                appState.selectZone(zone)
                            }
                            .onHover { hovering in
                                hoveredZoneId = hovering ? zone.id : nil
                            }
                        }
                    }
                    .padding(.horizontal, FlareSpacing.lg)
                    .padding(.bottom, FlareSpacing.lg)
                }
            }
        }
        .background(FlareColors.bgPrimary)
    }
}

// MARK: - Zone Row — Glass Card

struct ZoneRow: View {
    let zone: Zone
    var isSelected: Bool = false
    var isHovered: Bool = false

    var body: some View {
        HStack(spacing: FlareSpacing.md) {
            // Zone icon
            RoundedRectangle(cornerRadius: FlareRadius.sm, style: .continuous)
                .fill(
                    zone.isActive
                        ? FlareColors.statusActive.opacity(0.12)
                        : FlareColors.statusPending.opacity(0.12)
                )
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "globe")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(
                            zone.isActive ? FlareColors.statusActive : FlareColors.statusPending
                        )
                        .shadow(color: (zone.isActive ? FlareColors.statusActive : FlareColors.statusPending).opacity(0.3), radius: 3)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(zone.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(FlareColors.textPrimary)
                    .lineLimit(1)

                HStack(spacing: FlareSpacing.sm) {
                    StatusBadge(zoneStatus: zone.status)

                    if let plan = zone.plan?.name {
                        Text(plan)
                            .font(.system(size: 10))
                            .foregroundStyle(FlareColors.textTertiary)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(FlareColors.textTertiary)
        }
        .padding(FlareSpacing.md)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: FlareRadius.lg, style: .continuous)
                    .fill(
                        isSelected
                            ? FlareColors.cloudflareOrange.opacity(0.06)
                            : (isHovered ? FlareColors.glassHover : FlareColors.glassOverlay)
                    )

                // Light refraction on selected
                if isSelected {
                    RoundedRectangle(cornerRadius: FlareRadius.lg, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.08),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                RoundedRectangle(cornerRadius: FlareRadius.lg, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: isSelected
                                ? [FlareColors.cloudflareOrange.opacity(0.3), Color.white.opacity(0.08)]
                                : [Color.white.opacity(0.12), Color.white.opacity(0.04)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            }
        )
        .contentShape(Rectangle())
        .animation(.easeInOut(duration: 0.12), value: isSelected)
        .animation(.easeInOut(duration: 0.12), value: isHovered)
    }
}
