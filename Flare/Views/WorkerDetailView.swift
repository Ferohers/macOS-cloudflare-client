//
//  WorkerDetailView.swift
//  Flare
//
//  Worker editor with Liquid Glass frame and solid dark code canvas
//

import SwiftUI

struct WorkerDetailView: View {
    @Environment(AppState.self) private var appState
    let worker: WorkerScript
    @State private var code: String = "// Loading script code..."

    var body: some View {
        VStack(spacing: 0) {
            // Header — glass frame
            HStack(spacing: FlareSpacing.lg) {
                VStack(alignment: .leading, spacing: FlareSpacing.xs) {
                    HStack(spacing: FlareSpacing.sm) {
                        Text(worker.displayName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(FlareColors.textPrimary)
                            .tracking(0.3)

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

                // Actions — squircle glass buttons
                HStack(spacing: FlareSpacing.sm) {
                    Button(action: {
                        // Cancel
                    }) {
                        Text("Cancel")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(FlareColors.textPrimary)
                            .padding(.horizontal, FlareSpacing.md)
                            .padding(.vertical, FlareSpacing.sm)
                            .liquidGlassButton(isPrimary: false)
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        // Save & Deploy
                    }) {
                        Text("Save & Deploy")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, FlareSpacing.md)
                            .padding(.vertical, FlareSpacing.sm)
                            .liquidGlassButton(isPrimary: true)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(FlareSpacing.lg)
            .background(
                // Glass header backing
                ZStack {
                    Rectangle()
                        .fill(FlareColors.glassOverlay)
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.05),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )

            Divider()
                .background(FlareColors.glassBorder)

            // Code Editor — solid dark canvas for clarity
            HStack(spacing: 0) {
                // Line numbers — subtle glass gutter
                VStack(alignment: .trailing, spacing: 4) {
                    ForEach(1..<20, id: \.self) { line in
                        Text("\(line)")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(FlareColors.textTertiary.opacity(0.7))
                    }
                    Spacer()
                }
                .padding(.top, FlareSpacing.md)
                .padding(.horizontal, FlareSpacing.sm)
                .background(FlareColors.bgTertiary.opacity(0.8))
                
                // Subtle glass divider
                Rectangle()
                    .fill(FlareColors.glassBorder)
                    .frame(width: 0.5)
                
                // Code content — solid dark for maximum readability
                TextEditor(text: $code)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(FlareColors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .background(FlareColors.bgPrimary)
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
