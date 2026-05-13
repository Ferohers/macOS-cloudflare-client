//
//  ZoneDetailView.swift
//  Flare
//
//  Zone detail with DNS records table, stats, and zone info
//

import SwiftUI

struct ZoneDetailView: View {
    @Environment(AppState.self) private var appState
    let zone: Zone
    @State private var searchText = ""
    @State private var filterType: String = "All"
    @State private var sortOrder: SortOrder = .name
    @State private var selectedRecord: DNSRecord? = nil
    @State private var hoveredRecordId: String? = nil
    @State private var showAddSheet: Bool = false

    enum SortOrder: String, CaseIterable {
        case name = "Name"
        case type = "Type"
        case modified = "Modified"
    }

    private var recordTypes: [String] {
        let types = Set(appState.dnsRecords.map(\.type))
        return ["All"] + types.sorted()
    }

    private var filteredRecords: [DNSRecord] {
        var records = appState.dnsRecords

        if filterType != "All" {
            records = records.filter { $0.type == filterType }
        }

        if !searchText.isEmpty {
            records = records.filter { record in
                record.name.localizedCaseInsensitiveContains(searchText) ||
                record.content.localizedCaseInsensitiveContains(searchText)
            }
        }

        switch sortOrder {
        case .name:
            records.sort { $0.name < $1.name }
        case .type:
            records.sort { $0.type < $1.type }
        case .modified:
            records.sort { ($0.modified_on ?? "") > ($1.modified_on ?? "") }
        }

        return records
    }

    var body: some View {
        VStack(spacing: 0) {
            // Zone header
            zoneHeader

            Divider()
                .background(FlareColors.borderPrimary)

            // Stats row
            statsRow

            // DNS Records
            dnsSection
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(FlareColors.bgPrimary)
        .sheet(item: $selectedRecord) { record in
            EditDNSRecordView(zone: zone, record: record)
        }
        .sheet(isPresented: $showAddSheet) {
            EditDNSRecordView(zone: zone, record: nil)
        }
    }

    // MARK: - Zone Header

    private var zoneHeader: some View {
        HStack(spacing: FlareSpacing.lg) {
            VStack(alignment: .leading, spacing: FlareSpacing.xs) {
                HStack(spacing: FlareSpacing.sm) {
                    Text(zone.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(FlareColors.textPrimary)

                    StatusBadge(zoneStatus: zone.status)

                    Button(action: {
                        Task { await appState.loadDNSRecords(for: zone, clearOld: false) }
                    }) {
                        if appState.isLoadingDNS && !appState.dnsRecords.isEmpty {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(FlareColors.textSecondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .help("Refresh DNS Records")
                    .disabled(appState.isLoadingDNS)
                }

                Label(zone.createdDate, systemImage: "calendar")
                    .font(.system(size: 11))
                    .foregroundStyle(FlareColors.textTertiary)
            }

            Spacer()

            // Actions
            HStack(spacing: FlareSpacing.sm) {
                Button(action: {
                    showAddSheet = true
                }) {
                    Text("Add")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, FlareSpacing.md)
                        .padding(.vertical, FlareSpacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: FlareRadius.md)
                                .fill(FlareColors.cloudflareOrange)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(FlareSpacing.lg)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: FlareSpacing.md) {
            StatCard(
                title: "Total Records",
                value: "\(appState.dnsRecords.count)",
                icon: "list.bullet.rectangle",
                iconColor: FlareColors.statusInfo
            )

            StatCard(
                title: "Proxied",
                value: "\(appState.dnsRecords.filter(\.isProxied).count)",
                icon: "cloud.fill",
                iconColor: FlareColors.cloudflareOrange
            )

            StatCard(
                title: "Record Types",
                value: "\(Set(appState.dnsRecords.map(\.type)).count)",
                icon: "tag",
                iconColor: FlareColors.statusPending
            )

            if let nameservers = zone.name_servers, !nameservers.isEmpty {
                StatCard(
                    title: "Nameservers",
                    value: "\(nameservers.count)",
                    icon: "server.rack",
                    iconColor: FlareColors.statusActive
                )
            }
        }
        .padding(FlareSpacing.lg)
    }

    // MARK: - DNS Section

    private var dnsSection: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack(spacing: FlareSpacing.md) {
                Text("DNS Records")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(FlareColors.textPrimary)

                Spacer()

                // Filter by type
                Picker("Type", selection: $filterType) {
                    ForEach(recordTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 100)

                // Sort
                Picker("Sort", selection: $sortOrder) {
                    ForEach(SortOrder.allCases, id: \.self) { order in
                        Text(order.rawValue).tag(order)
                    }
                }
                .pickerStyle(.menu)
                .fixedSize()

                // Search
                HStack(spacing: FlareSpacing.xs) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 10))
                        .foregroundStyle(FlareColors.textTertiary)

                    TextField("Filter...", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12))
                        .foregroundStyle(FlareColors.textPrimary)
                        .frame(width: 120)
                }
                .padding(.horizontal, FlareSpacing.sm)
                .padding(.vertical, FlareSpacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: FlareRadius.sm)
                        .fill(FlareColors.bgTertiary)
                        .overlay(
                            RoundedRectangle(cornerRadius: FlareRadius.sm)
                                .strokeBorder(FlareColors.borderPrimary, lineWidth: 1)
                        )
                )
            }
            .padding(.horizontal, FlareSpacing.lg)
            .padding(.vertical, FlareSpacing.md)

            Divider()
                .background(FlareColors.borderPrimary)

            // Table Headers
            HStack(spacing: 0) {
                tableHeader("Type", width: 70)
                tableHeader("Name", flex: true)
                tableHeader("Content", flex: true)
                tableHeader("Proxy", width: 50)
                tableHeader("TTL", width: 60)
            }
            .padding(.horizontal, FlareSpacing.lg)
            .padding(.vertical, FlareSpacing.sm)
            .background(FlareColors.bgSecondary)

            Divider()
                .background(FlareColors.borderPrimary)

            // Table Content
            if appState.isLoadingDNS && appState.dnsRecords.isEmpty {
                ScrollView {
                    VStack(spacing: FlareSpacing.sm) {
                        ForEach(0..<8, id: \.self) { _ in
                            LoadingCard()
                        }
                    }
                    .padding(FlareSpacing.lg)
                }
            } else if filteredRecords.isEmpty {
                EmptyStateView(
                    icon: "doc.text",
                    title: "No DNS Records",
                    message: searchText.isEmpty
                        ? "This zone has no DNS records."
                        : "No records match your filter."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredRecords) { record in
                            dnsRow(record)
                                .background(hoveredRecordId == record.id ? FlareColors.bgHover : Color.clear)
                                .onHover { hovering in
                                    hoveredRecordId = hovering ? record.id : nil
                                }
                                .onTapGesture {
                                    selectedRecord = record
                                }
                            Divider()
                                .background(FlareColors.borderSecondary)
                        }
                    }
                }
            }
        }
    }

    private func tableHeader(_ title: String, width: CGFloat? = nil, flex: Bool = false) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(FlareColors.textTertiary)
            .textCase(.uppercase)
            .frame(width: width, alignment: .leading)
            .frame(maxWidth: flex ? .infinity : nil, alignment: .leading)
    }

    private func dnsRow(_ record: DNSRecord) -> some View {
        HStack(spacing: 0) {
            // Type badge
            DNSTypeBadge(type: record.type)
                .frame(width: 70, alignment: .leading)

            // Name
            Text(record.displayName)
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(FlareColors.textPrimary)
                .lineLimit(1)
                .truncationMode(.middle)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Content
            Text(record.content)
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(FlareColors.textSecondary)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
                .help(record.content)

            // Proxy
            if record.proxiable ?? false {
                ProxyStatusIcon(isProxied: record.isProxied)
                    .frame(width: 50, alignment: .center)
            } else {
                Text("—")
                    .font(.system(size: 12))
                    .foregroundStyle(FlareColors.textTertiary)
                    .frame(width: 50, alignment: .center)
            }

            // TTL
            Text(record.displayTTL)
                .font(.system(size: 11))
                .foregroundStyle(FlareColors.textSecondary)
                .frame(width: 60, alignment: .leading)
        }
        .padding(.horizontal, FlareSpacing.lg)
        .padding(.vertical, FlareSpacing.sm)
        .contentShape(Rectangle())
    }
}
