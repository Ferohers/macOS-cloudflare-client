//
//  Theme.swift
//  Flare
//
//  Design system with Cloudflare-inspired dark theme
//

import SwiftUI

// MARK: - Color Palette

enum FlareColors {
    // Brand
    static let cloudflareOrange = Color(hex: "F6821F")
    static let cloudflareOrangeLight = Color(hex: "FBAD41")
    static let cloudflareOrangeDark = Color(hex: "E05D00")

    // Backgrounds
    static let bgPrimary = Color(hex: "0D1117")
    static let bgSecondary = Color(hex: "161B22")
    static let bgTertiary = Color(hex: "1C2128")
    static let bgElevated = Color(hex: "21262D")
    static let bgHover = Color(hex: "292E36")

    // Text
    static let textPrimary = Color(hex: "E6EDF3")
    static let textSecondary = Color(hex: "8B949E")
    static let textTertiary = Color(hex: "6E7681")
    static let textLink = Color(hex: "58A6FF")

    // Borders
    static let borderPrimary = Color(hex: "30363D")
    static let borderSecondary = Color(hex: "21262D")

    // Status
    static let statusActive = Color(hex: "3FB950")
    static let statusWarning = Color(hex: "D29922")
    static let statusError = Color(hex: "F85149")
    static let statusPending = Color(hex: "A371F7")
    static let statusInfo = Color(hex: "58A6FF")

    // DNS Record Type Colors
    static let dnsA = Color(hex: "58A6FF")
    static let dnsAAAA = Color(hex: "79C0FF")
    static let dnsCNAME = Color(hex: "8A3FFC")
    static let dnsMX = Color(hex: "3FB950")
    static let dnsTXT = Color(hex: "D29922")
    static let dnsNS = Color(hex: "F778BA")
    static let dnsSRV = Color(hex: "FFA657")
    static let dnsCAA = Color(hex: "FF7B72")
    static let dnsDefault = Color(hex: "8B949E")

    static func colorForDNSType(_ type: String) -> Color {
        switch type.uppercased() {
        case "A": return dnsA
        case "AAAA": return dnsAAAA
        case "CNAME": return dnsCNAME
        case "MX": return dnsMX
        case "TXT": return dnsTXT
        case "NS": return dnsNS
        case "SRV": return dnsSRV
        case "CAA": return dnsCAA
        default: return dnsDefault
        }
    }
}

// MARK: - Spacing & Layout

enum FlareSpacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48
}

enum FlareRadius {
    static let sm: CGFloat = 4
    static let md: CGFloat = 8
    static let lg: CGFloat = 12
    static let xl: CGFloat = 16
    static let pill: CGFloat = 999
}

// MARK: - View Modifiers

struct CardStyle: ViewModifier {
    var isHovered: Bool = false

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: FlareRadius.lg)
                    .fill(isHovered ? FlareColors.bgHover : FlareColors.bgSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: FlareRadius.lg)
                            .strokeBorder(FlareColors.borderPrimary, lineWidth: 1)
                    )
            )
            .animation(.easeInOut(duration: 0.15), value: isHovered)
    }
}

struct GlassStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: FlareRadius.lg)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: FlareRadius.lg)
                            .strokeBorder(FlareColors.borderPrimary.opacity(0.5), lineWidth: 1)
                    )
            )
    }
}

struct GlowEffect: ViewModifier {
    var color: Color = FlareColors.cloudflareOrange
    var radius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.3), radius: radius, x: 0, y: 0)
    }
}

extension View {
    func cardStyle(isHovered: Bool = false) -> some View {
        modifier(CardStyle(isHovered: isHovered))
    }

    func glassStyle() -> some View {
        modifier(GlassStyle())
    }

    func glowEffect(color: Color = FlareColors.cloudflareOrange, radius: CGFloat = 20) -> some View {
        modifier(GlowEffect(color: color, radius: radius))
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
