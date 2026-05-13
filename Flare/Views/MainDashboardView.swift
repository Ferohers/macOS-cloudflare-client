//
//  MainDashboardView.swift
//  Flare
//
//  Three-column NavigationSplitView dashboard layout
//

import SwiftUI

struct MainDashboardView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var state = appState

        NavigationSplitView {
            SidebarView()
                .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 320)
        } detail: {
            detailColumn
        }
        .navigationSplitViewStyle(.balanced)
        .overlay(alignment: .bottom) {
            VStack(spacing: FlareSpacing.sm) {
                if let error = appState.errorMessage {
                    ToastBanner(message: error, isError: true) {
                        appState.errorMessage = nil
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                if let success = appState.successMessage {
                    ToastBanner(message: success, isError: false) {
                        appState.successMessage = nil
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.horizontal, FlareSpacing.xl)
            .padding(.bottom, FlareSpacing.lg)
            .animation(.spring(response: 0.3), value: appState.errorMessage)
            .animation(.spring(response: 0.3), value: appState.successMessage)
        }
    }

    @ViewBuilder
    private var detailColumn: some View {
        if let selectedItem = appState.selectedItem {
            switch selectedItem {
            case .zone(let id):
                if let zone = appState.zones.first(where: { $0.id == id }) {
                    ZoneDetailView(zone: zone)
                } else {
                    placeholderDetail(icon: "globe", title: "Zone not found", message: "")
                }
            case .worker(let id):
                if let worker = appState.workers.first(where: { $0.id == id }) {
                    WorkerDetailView(worker: worker)
                } else {
                    placeholderDetail(icon: "chevron.left.forwardslash.chevron.right", title: "Worker not found", message: "")
                }
            case .settings:
                SettingsView()
            }
        } else {
            placeholderDetail(
                icon: "globe",
                title: "Select an Item",
                message: "Choose a zone, worker, or setting from the sidebar."
            )
        }
    }

    // MARK: - Settings Detail Panel

    private var settingsDetailPanel: some View {
        VStack(spacing: FlareSpacing.xl) {
            VStack(spacing: FlareSpacing.sm) {
                Image(systemName: "key.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(FlareColors.cloudflareOrange)
                
                Text("API Requirements")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(FlareColors.textPrimary)
                
                Text("Ensure your Cloudflare API Token has the following permissions for Flare to work correctly.")
                    .font(.system(size: 12))
                    .foregroundStyle(FlareColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, FlareSpacing.xl)

            VStack(alignment: .leading, spacing: 0) {
                permissionRow(resource: "Zone", category: "Zone", access: "Read")
                Divider().background(FlareColors.borderPrimary).padding(.horizontal, FlareSpacing.md)
                permissionRow(resource: "Zone", category: "DNS", access: "Read")
                Divider().background(FlareColors.borderPrimary).padding(.horizontal, FlareSpacing.md)
                permissionRow(resource: "Account", category: "Workers Scripts", access: "Read")
            }
            .background(
                RoundedRectangle(cornerRadius: FlareRadius.lg)
                    .fill(FlareColors.bgSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: FlareRadius.lg)
                            .strokeBorder(FlareColors.borderPrimary, lineWidth: 1)
                    )
            )
            .padding(.horizontal, FlareSpacing.xl)
            
            if !appState.missingPermissions.isEmpty {
                VStack(alignment: .leading, spacing: FlareSpacing.sm) {
                    HStack(spacing: FlareSpacing.xs) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(FlareColors.statusWarning)
                        Text("Missing Permissions Detected")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(FlareColors.statusWarning)
                    }

                    ForEach(appState.missingPermissions, id: \.self) { perm in
                        HStack(spacing: FlareSpacing.sm) {
                            Circle()
                                .fill(FlareColors.statusError)
                                .frame(width: 5, height: 5)
                            Text(perm)
                                .font(.system(size: 11))
                                .foregroundStyle(FlareColors.textSecondary)
                        }
                    }
                }
                .padding(FlareSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: FlareRadius.md)
                        .fill(FlareColors.statusWarning.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: FlareRadius.md)
                                .strokeBorder(FlareColors.statusWarning.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal, FlareSpacing.xl)
            }
            
            Spacer()
        }
        .padding(.top, FlareSpacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FlareColors.bgPrimary)
    }
    
    private func permissionRow(resource: String, category: String, access: String) -> some View {
        HStack(spacing: FlareSpacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(FlareColors.statusActive)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(resource)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(FlareColors.textPrimary)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(FlareColors.textTertiary)
                    Text(category)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(FlareColors.textPrimary)
                }
                
                Text("Access: \(access)")
                    .font(.system(size: 11))
                    .foregroundStyle(FlareColors.textSecondary)
            }
            Spacer()
        }
        .padding(FlareSpacing.md)
    }

    private func placeholderDetail(icon: String, title: String, message: String) -> some View {
        VStack(spacing: FlareSpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundStyle(FlareColors.textTertiary.opacity(0.5))

            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(FlareColors.textSecondary)

            Text(message)
                .font(.system(size: 13))
                .foregroundStyle(FlareColors.textTertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FlareColors.bgPrimary)
    }
}
