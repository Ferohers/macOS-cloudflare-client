//
//  WorkersListView.swift
//  Flare
//
//  Workers scripts list with search and script cards
//

import SwiftUI

struct WorkersListView: View {
    @Environment(AppState.self) private var appState
    @State private var searchText = ""
    @State private var hoveredWorkerId: String?

    private var filteredWorkers: [WorkerScript] {
        if searchText.isEmpty {
            return appState.workers
        }
        return appState.workers.filter { worker in
            worker.id.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            SectionHeader(
                title: "Workers",
                subtitle: "\(appState.workers.count) script\(appState.workers.count == 1 ? "" : "s")",
                action: {
                    Task { await appState.loadWorkers() }
                },
                actionLabel: "Refresh"
            )
            .padding(.horizontal, FlareSpacing.xl)
            .padding(.top, FlareSpacing.lg)
            .padding(.bottom, FlareSpacing.md)

            // Search
            HStack(spacing: FlareSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12))
                    .foregroundStyle(FlareColors.textTertiary)

                TextField("Search workers...", text: $searchText)
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
                RoundedRectangle(cornerRadius: FlareRadius.md)
                    .fill(FlareColors.bgTertiary)
                    .overlay(
                        RoundedRectangle(cornerRadius: FlareRadius.md)
                            .strokeBorder(FlareColors.borderPrimary, lineWidth: 1)
                    )
            )
            .padding(.horizontal, FlareSpacing.xl)
            .padding(.bottom, FlareSpacing.md)

            // Content
            if appState.isLoadingWorkers {
                VStack(spacing: FlareSpacing.sm) {
                    ForEach(0..<4, id: \.self) { _ in
                        LoadingCard()
                    }
                }
                .padding(.horizontal, FlareSpacing.xl)
                Spacer()
            } else if appState.accountId == nil {
                EmptyStateView(
                    icon: "exclamationmark.triangle",
                    title: "Account Required",
                    message: "Add a zone first so Flare can detect your account ID."
                )
            } else if filteredWorkers.isEmpty {
                EmptyStateView(
                    icon: "chevron.left.forwardslash.chevron.right",
                    title: searchText.isEmpty ? "No Workers" : "No Results",
                    message: searchText.isEmpty
                        ? "No Workers scripts found in your account."
                        : "No workers match \"\(searchText)\"."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: FlareSpacing.sm) {
                        ForEach(filteredWorkers) { worker in
                            WorkerRow(
                                worker: worker,
                                isHovered: hoveredWorkerId == worker.id
                            )
                            .onHover { hovering in
                                hoveredWorkerId = hovering ? worker.id : nil
                            }
                        }
                    }
                    .padding(.horizontal, FlareSpacing.xl)
                    .padding(.bottom, FlareSpacing.lg)
                }
            }
        }
        .background(FlareColors.bgPrimary)
        .onAppear {
            if appState.workers.isEmpty && appState.accountId != nil {
                Task { await appState.loadWorkers() }
            }
        }
    }
}

// MARK: - Worker Row

struct WorkerRow: View {
    let worker: WorkerScript
    var isHovered: Bool = false

    var body: some View {
        HStack(spacing: FlareSpacing.md) {
            // Icon
            RoundedRectangle(cornerRadius: FlareRadius.sm)
                .fill(FlareColors.statusInfo.opacity(0.15))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(FlareColors.statusInfo)
                )

            // Name and metadata
            VStack(alignment: .leading, spacing: 3) {
                Text(worker.displayName)
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundStyle(FlareColors.textPrimary)
                    .lineLimit(1)

                HStack(spacing: FlareSpacing.sm) {
                    HStack(spacing: 3) {
                        Image(systemName: "gauge.medium")
                            .font(.system(size: 9))
                        Text(worker.displayUsageModel)
                            .font(.system(size: 10))
                    }
                    .foregroundStyle(FlareColors.textTertiary)

                    if let compatDate = worker.compatibility_date {
                        HStack(spacing: 3) {
                            Image(systemName: "calendar")
                                .font(.system(size: 9))
                            Text(compatDate)
                                .font(.system(size: 10))
                        }
                        .foregroundStyle(FlareColors.textTertiary)
                    }
                }
                .fixedSize(horizontal: true, vertical: false)
            }

            Spacer()

            // Modified date
            VStack(alignment: .trailing, spacing: 2) {
                Text("Modified")
                    .font(.system(size: 9))
                    .foregroundStyle(FlareColors.textTertiary)
                Text(worker.modifiedDate)
                    .font(.system(size: 10))
                    .foregroundStyle(FlareColors.textSecondary)
                    .lineLimit(1)
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding(FlareSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: FlareRadius.lg)
                .fill(isHovered ? FlareColors.bgHover : FlareColors.bgSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: FlareRadius.lg)
                        .strokeBorder(FlareColors.borderPrimary, lineWidth: 1)
                )
        )
        .contentShape(Rectangle())
        .animation(.easeInOut(duration: 0.12), value: isHovered)
    }
}
