//
//  EditDNSRecordView.swift
//  Flare
//
//  DNS record editor modal — Liquid Glass
//

import SwiftUI

struct EditDNSRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    let zone: Zone
    let record: DNSRecord?

    @State private var name: String
    @State private var content: String
    @State private var isProxied: Bool
    @State private var recordType: String
    @State private var isSaving = false

    init(zone: Zone, record: DNSRecord? = nil) {
        self.zone = zone
        self.record = record
        _name = State(initialValue: record?.name ?? "")
        _content = State(initialValue: record?.content ?? "")
        _isProxied = State(initialValue: record?.proxied ?? false)
        _recordType = State(initialValue: record?.type ?? "A")
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header — glass
            HStack {
                Text(record != nil ? "Edit \(record!.type) Record" : "Add DNS Record")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(FlareColors.textPrimary)
                    .tracking(0.3)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(FlareColors.textTertiary)
                        .padding(6)
                        .background(
                            Circle()
                                .fill(FlareColors.glassOverlay)
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
                                )
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(FlareSpacing.lg)
            .background(
                ZStack {
                    Rectangle().fill(FlareColors.glassOverlay)
                    LinearGradient(
                        colors: [Color.white.opacity(0.04), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )

            Divider()
                .background(FlareColors.glassBorder)

            // Form
            VStack(spacing: FlareSpacing.lg) {
                // Type Picker (only for new records)
                if record == nil {
                    VStack(alignment: .leading, spacing: FlareSpacing.xs) {
                        Text("Type")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(FlareColors.textSecondary)
                        Picker("", selection: $recordType) {
                            Text("A").tag("A")
                            Text("AAAA").tag("AAAA")
                            Text("CNAME").tag("CNAME")
                            Text("TXT").tag("TXT")
                            Text("MX").tag("MX")
                        }
                        .pickerStyle(.menu)
                        .frame(width: 100)
                    }
                }

                // Name
                VStack(alignment: .leading, spacing: FlareSpacing.xs) {
                    Text("Name")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(FlareColors.textSecondary)
                    TextField("", text: $name)
                        .textFieldStyle(.plain)
                        .padding(FlareSpacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: FlareRadius.md, style: .continuous)
                                .fill(FlareColors.bgPrimary.opacity(0.8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: FlareRadius.md, style: .continuous)
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.12),
                                                    Color.white.opacity(0.05)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 0.5
                                        )
                                )
                        )
                }

                // Content
                VStack(alignment: .leading, spacing: FlareSpacing.xs) {
                    Text("Content")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(FlareColors.textSecondary)
                    TextField("", text: $content)
                        .textFieldStyle(.plain)
                        .padding(FlareSpacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: FlareRadius.md, style: .continuous)
                                .fill(FlareColors.bgPrimary.opacity(0.8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: FlareRadius.md, style: .continuous)
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.12),
                                                    Color.white.opacity(0.05)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 0.5
                                        )
                                )
                        )
                }

                // Proxy toggle
                if recordType == "A" || recordType == "CNAME" || recordType == "AAAA" {
                    Toggle("Proxied", isOn: $isProxied)
                        .toggleStyle(.switch)
                        .tint(FlareColors.cloudflareOrange)
                }
            }
            .padding(FlareSpacing.lg)

            Spacer()

            Divider()
                .background(FlareColors.glassBorder)

            // Footer — glass
            HStack {
                if record != nil {
                    Button(action: {
                        deleteRecord()
                    }) {
                        if isSaving {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Text("Delete")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, FlareSpacing.md)
                                .padding(.vertical, FlareSpacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: FlareRadius.lg, style: .continuous)
                                        .fill(FlareColors.statusError.opacity(0.85))
                                        .shadow(color: FlareColors.statusError.opacity(0.2), radius: 4, x: 0, y: 2)
                                )
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(isSaving)
                }

                Spacer()

                Button(action: { dismiss() }) {
                    Text("Cancel")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(FlareColors.textPrimary)
                        .padding(.horizontal, FlareSpacing.md)
                        .padding(.vertical, FlareSpacing.sm)
                        .liquidGlassButton(isPrimary: false)
                }
                .buttonStyle(.plain)
                .disabled(isSaving)

                Button(action: {
                    saveRecord()
                }) {
                    if isSaving {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("Save")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, FlareSpacing.md)
                            .padding(.vertical, FlareSpacing.sm)
                            .liquidGlassButton(isPrimary: true)
                    }
                }
                .buttonStyle(.plain)
                .disabled(isSaving)
            }
            .padding(FlareSpacing.lg)
            .background(
                ZStack {
                    Rectangle().fill(FlareColors.glassOverlay)
                    LinearGradient(
                        colors: [Color.white.opacity(0.03), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
        }
        .frame(width: 400, height: 380)
        .background(FlareColors.bgPrimary)
        .clipShape(RoundedRectangle(cornerRadius: FlareRadius.window, style: .continuous))
    }

    private func saveRecord() {
        guard let api = appState.api else { return }
        isSaving = true

        let payload = DNSRecordPayload(
            type: record != nil ? record!.type : recordType,
            name: name,
            content: content,
            proxied: isProxied,
            ttl: record?.ttl ?? 1
        )

        Task {
            do {
                if let existing = record {
                    _ = try await api.updateDNSRecord(zoneId: zone.id, recordId: existing.id, payload: payload)
                    appState.showSuccess("DNS Record updated successfully.")
                } else {
                    _ = try await api.createDNSRecord(zoneId: zone.id, payload: payload)
                    appState.showSuccess("DNS Record created successfully.")
                }
                await appState.loadDNSRecords(for: zone)
                dismiss()
            } catch {
                appState.showError(error.localizedDescription)
                isSaving = false
            }
        }
    }

    private func deleteRecord() {
        guard let api = appState.api, let existing = record else { return }
        isSaving = true

        Task {
            do {
                try await api.deleteDNSRecord(zoneId: zone.id, recordId: existing.id)
                appState.showSuccess("DNS Record deleted.")
                await appState.loadDNSRecords(for: zone)
                dismiss()
            } catch {
                appState.showError(error.localizedDescription)
                isSaving = false
            }
        }
    }
}
