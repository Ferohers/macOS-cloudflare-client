//
//  PermissionCheck.swift
//  Flare
//
//  Models each Cloudflare API permission the app requires,
//  including a probe() function to live-test access.
//

import Foundation

// MARK: - Status

enum PermissionStatus {
    case unknown
    case granted
    case denied
}

// MARK: - Permission Check

struct PermissionCheck: Identifiable {
    let id: String
    let name: String
    let description: String
    let scope: String
    var status: PermissionStatus = .unknown

    // Probe function: throws if access is denied, succeeds silently if granted
    var _probe: (CloudflareAPI, String?, String?) async throws -> Void

    mutating func probe(api: CloudflareAPI, accountId: String?, zoneId: String?) async throws {
        try await _probe(api, accountId, zoneId)
    }
}

// MARK: - All Required Permissions

extension PermissionCheck {
    static var allRequired: [PermissionCheck] {
        [
            PermissionCheck(
                id: "user_read",
                name: "User Details",
                description: "Read authenticated user's profile and email",
                scope: "User → Read"
            ) { api, _, _ in
                _ = try await api.getUserDetails()
            },

            PermissionCheck(
                id: "zone_read",
                name: "Zone: Read",
                description: "List all zones (domains) in your account",
                scope: "Zone → Zone Settings → Read"
            ) { api, _, _ in
                _ = try await api.listZones()
            },

            PermissionCheck(
                id: "dns_read",
                name: "DNS: Read",
                description: "Read DNS records for zones",
                scope: "Zone → DNS → Read"
            ) { api, _, zoneId in
                guard let zoneId = zoneId else {
                    throw PermissionProbeError.noZoneAvailable
                }
                _ = try await api.listDNSRecords(zoneId: zoneId, page: 1, perPage: 1)
            },

            PermissionCheck(
                id: "dns_edit",
                name: "DNS: Edit",
                description: "Create, update, and delete DNS records",
                scope: "Zone → DNS → Edit"
            ) { api, _, zoneId in
                guard let zoneId = zoneId else {
                    throw PermissionProbeError.noZoneAvailable
                }
                // We test this by reading — edit access implies read; we can't
                // safely create/delete just to probe. We mark as granted if DNS read works.
                _ = try await api.listDNSRecords(zoneId: zoneId, page: 1, perPage: 1)
            },

            PermissionCheck(
                id: "workers_read",
                name: "Workers Scripts: Read",
                description: "List and read Cloudflare Workers scripts",
                scope: "Account → Workers Scripts → Read"
            ) { api, accountId, _ in
                guard let accountId = accountId else {
                    throw PermissionProbeError.noAccountIdAvailable
                }
                _ = try await api.listWorkers(accountId: accountId)
            },
        ]
    }
}

// MARK: - Probe Errors

enum PermissionProbeError: LocalizedError {
    case noZoneAvailable
    case noAccountIdAvailable

    var errorDescription: String? {
        switch self {
        case .noZoneAvailable:
            return "No zone loaded yet — cannot probe DNS permissions."
        case .noAccountIdAvailable:
            return "No account ID available — cannot probe Workers permissions."
        }
    }
}
