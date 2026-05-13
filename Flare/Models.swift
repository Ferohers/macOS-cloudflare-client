//
//  Models.swift
//  Flare
//
//  Codable data models matching Cloudflare API v4 response structures
//

import Foundation

// MARK: - API Response Wrappers

nonisolated struct CloudflareResponse<T: Codable & Sendable>: Codable, Sendable {
    let success: Bool
    let errors: [CloudflareError]
    let messages: [CloudflareMessage]
    let result: T?
}

nonisolated struct CloudflareListResponse<T: Codable & Sendable>: Codable, Sendable {
    let success: Bool
    let errors: [CloudflareError]
    let messages: [CloudflareMessage]
    let result: [T]
    let result_info: ResultInfo?
}

nonisolated struct CloudflareError: Codable, Sendable {
    let code: Int
    let message: String
}

nonisolated struct CloudflareMessage: Codable, Sendable {
    let code: Int?
    let message: String

    enum CodingKeys: String, CodingKey {
        case code, message
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try container.decodeIfPresent(Int.self, forKey: .code)
        self.message = try container.decode(String.self, forKey: .message)
    }
}

nonisolated struct ResultInfo: Codable, Sendable {
    let page: Int?
    let per_page: Int?
    let total_pages: Int?
    let count: Int?
    let total_count: Int?
}

// MARK: - Zone

nonisolated struct Zone: Codable, Identifiable, Sendable, Hashable {
    let id: String
    let name: String
    let status: String
    let paused: Bool
    let type: String
    let name_servers: [String]?
    let original_name_servers: [String]?
    let created_on: String?
    let modified_on: String?
    let plan: ZonePlan?
    let account: ZoneAccount?

    static func == (lhs: Zone, rhs: Zone) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var isActive: Bool {
        status == "active"
    }

    var displayStatus: String {
        status.capitalized
    }

    var createdDate: String {
        guard let created = created_on else { return "—" }
        return formatAPIDate(created)
    }

    var modifiedDate: String {
        guard let modified = modified_on else { return "—" }
        return formatAPIDate(modified)
    }
}

nonisolated struct ZonePlan: Codable, Sendable, Hashable {
    let id: String?
    let name: String?
    let price: Double?
    let currency: String?
    let frequency: String?
    let is_subscribed: Bool?
    let can_subscribe: Bool?
    let legacy_id: String?
}

nonisolated struct ZoneAccount: Codable, Sendable, Hashable {
    let id: String?
    let name: String?
}

// MARK: - DNS Record Payload

nonisolated struct DNSRecordPayload: Codable, Sendable {
    let type: String
    let name: String
    let content: String
    let proxied: Bool
    let ttl: Int
}

// MARK: - Delete Result

nonisolated struct DeleteResult: Codable, Sendable {
    let id: String
}

// MARK: - DNS Record

nonisolated struct DNSRecord: Codable, Identifiable, Sendable {
    let id: String
    let zone_id: String?
    let zone_name: String?
    let name: String
    let type: String
    let content: String
    let proxied: Bool?
    let proxiable: Bool?
    let ttl: Int
    let priority: Int?
    let created_on: String?
    let modified_on: String?
    let comment: String?
    let tags: [String]?

    var displayName: String {
        name
    }

    var displayTTL: String {
        if ttl == 1 { return "Auto" }
        if ttl < 60 { return "\(ttl)s" }
        if ttl < 3600 { return "\(ttl / 60)m" }
        return "\(ttl / 3600)h"
    }

    var isProxied: Bool {
        proxied ?? false
    }

    var createdDate: String {
        guard let created = created_on else { return "—" }
        return formatAPIDate(created)
    }
}

// MARK: - Worker Script

nonisolated struct WorkerScript: Codable, Identifiable, Sendable {
    let id: String
    let etag: String?
    let created_on: String?
    let modified_on: String?
    let usage_model: String?
    let compatibility_date: String?
    let last_deployed_from: String?

    var displayName: String {
        id
    }

    var modifiedDate: String {
        guard let modified = modified_on else { return "—" }
        return formatAPIDate(modified)
    }

    var createdDate: String {
        guard let created = created_on else { return "—" }
        return formatAPIDate(created)
    }

    var displayUsageModel: String {
        switch usage_model {
        case "bundled": return "Bundled"
        case "unbound": return "Unbound"
        case "standard": return "Standard"
        default: return usage_model?.capitalized ?? "Standard"
        }
    }
}

// MARK: - User / Token Verification

nonisolated struct TokenVerifyResult: Codable, Sendable {
    let id: String?
    let status: String?
}

nonisolated struct UserDetails: Codable, Sendable {
    let id: String
    let email: String
    let first_name: String?
    let last_name: String?
    let username: String?
    let telephone: String?
    let country: String?
    let created_on: String?
    let modified_on: String?
    let two_factor_authentication_enabled: Bool?
    let suspended: Bool?
}

// MARK: - Sidebar Navigation

enum SidebarItem: Hashable {
    case zone(String)
    case worker(String)
    case settings
}

// MARK: - Helpers

nonisolated private func formatAPIDate(_ dateString: String) -> String {
    let isoFormatter = ISO8601DateFormatter()
    isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let date = isoFormatter.date(from: dateString) {
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
    // Fallback: try without fractional seconds
    isoFormatter.formatOptions = [.withInternetDateTime]
    if let date = isoFormatter.date(from: dateString) {
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
    return dateString
}
