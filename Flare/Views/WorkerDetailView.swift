//
//  WorkerDetailView.swift
//  Flare
//

import SwiftUI

struct WorkerDetailView: View {
    @Environment(AppState.self) private var appState
    let worker: WorkerScript
    @State private var code: String = "// Loading script code..."

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: FlareSpacing.lg) {
                VStack(alignment: .leading, spacing: FlareSpacing.xs) {
                    HStack(spacing: FlareSpacing.sm) {
                        Text(worker.displayName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(FlareColors.textPrimary)

                        Button(action: {
                            Task {
                                code = "// Loading script code..."
                                do {
                                    code = try await appState.getWorkerScript(workerId: worker.id)
                                } catch {
                                    code = "// Error loading script: \(error.localizedDescription)"
                                }
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(FlareColors.textSecondary)
                        }
                        .buttonStyle(.plain)
                        .help("Refresh Worker Script")
                    }

                    HStack(spacing: FlareSpacing.sm) {
                        HStack(spacing: 4) {
                            Image(systemName: "gauge.medium")
                            Text(worker.displayUsageModel)
                        }
                        .font(.system(size: 11))
                        .foregroundStyle(FlareColors.textSecondary)

                        if let date = worker.compatibility_date {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                Text(date)
                            }
                            .font(.system(size: 11))
                            .foregroundStyle(FlareColors.textTertiary)
                        }
                    }
                }

                Spacer()

                // Actions
                HStack(spacing: FlareSpacing.sm) {
                    Button(action: {
                        // Dummy Cancel
                    }) {
                        Text("Cancel")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(FlareColors.textPrimary)
                            .padding(.horizontal, FlareSpacing.md)
                            .padding(.vertical, FlareSpacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: FlareRadius.md)
                                    .fill(FlareColors.bgTertiary)
                            )
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        // Dummy Save
                    }) {
                        Text("Save & Deploy")
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

            Divider()
                .background(FlareColors.borderPrimary)

            // Code Editor
            HStack(spacing: 0) {
                // Line numbers
                VStack(alignment: .trailing, spacing: 4) {
                    ForEach(1..<20, id: \.self) { line in
                        Text("\(line)")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(FlareColors.textTertiary)
                    }
                    Spacer()
                }
                .padding(.top, FlareSpacing.md)
                .padding(.horizontal, FlareSpacing.sm)
                .background(FlareColors.bgTertiary)
                
                Divider()
                    .background(FlareColors.borderPrimary)
                
                // Code content
                TextEditor(text: $code)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(FlareColors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .background(FlareColors.bgSecondary)
                    .padding(.horizontal, FlareSpacing.sm)
                    .padding(.top, 4)
            }
        }
        .background(FlareColors.bgPrimary)
        .task(id: worker.id) {
            code = "// Loading script code..."
            do {
                code = try await appState.getWorkerScript(workerId: worker.id)
            } catch {
                code = """
// Error loading script: \(error.localizedDescription)
//
// Fallback dummy script:
export default {
    async fetch(request, env, ctx) {
        return new Response('Hello World!');
    },
}; 
"""
            }
        }
    }
}
