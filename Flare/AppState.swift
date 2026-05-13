//
//  AppState.swift
//  Flare
//
//  Root observable state container managing authentication and data
//

import SwiftUI

@Observable
final class AppState {
    // Auth
    var isAuthenticated = false
    var isAuthenticating = false
    var authError: String?

    // Navigation
    var selectedItem: SidebarItem?

    // Data
    var zones: [Zone] = []
    var dnsRecords: [DNSRecord] = []
    var workers: [WorkerScript] = []

    // User
    var userEmail: String?
    var accountId: String?

    // Loading states
    var isLoadingZones = false
    var isLoadingDNS = false
    var isLoadingWorkers = false
    var errorMessage: String?
    var successMessage: String?
    
    // Settings state
    var hiddenZoneIds: Set<String> = []
    var missingPermissions: [String] = []

    // API
    private(set) var api: CloudflareAPI?

    init() {
        // Try to restore session from Keychain
        if let token = KeychainHelper.retrieveToken() {
            api = CloudflareAPI(token: token)
            isAuthenticated = true
            Task {
                await initialLoad()
            }
        }
    }

    // MARK: - Authentication

    func authenticate(token: String) async {
        isAuthenticating = true
        authError = nil

        let tempAPI = CloudflareAPI(token: token)

        do {
            let verifyResult = try await tempAPI.verifyToken()
            guard verifyResult.status == "active" else {
                authError = "Token is not active. Status: \(verifyResult.status ?? "unknown")"
                isAuthenticating = false
                return
            }

            // Save token
            let saved = KeychainHelper.save(token: token)
            if !saved {
                authError = "Failed to save token securely. Please try again."
                isAuthenticating = false
                return
            }

            self.api = tempAPI
            self.isAuthenticated = true
            self.isAuthenticating = false

            // Load user details and data
            await initialLoad()
        } catch {
            authError = error.localizedDescription
            isAuthenticating = false
        }
    }

    func signOut() {
        _ = KeychainHelper.deleteToken()
        api = nil
        isAuthenticated = false
        zones = []
        dnsRecords = []
        workers = []
        userEmail = nil
        accountId = nil
        selectedItem = nil
        errorMessage = nil
    }

    // MARK: - Data Loading

    private func initialLoad() async {
        do {
            let user = try await api?.getUserDetails()
            userEmail = user?.email
        } catch {
            // Non-critical, continue
        }

        await loadZones()
    }

    func loadZones() async {
        guard let api = api else { return }
        isLoadingZones = true
        errorMessage = nil

        do {
            let (fetchedZones, _) = try await api.listZones()
            zones = fetchedZones

            // Extract account ID from first zone
            if accountId == nil, let firstZone = fetchedZones.first {
                accountId = firstZone.account?.id
            }
            if accountId != nil {
                Task { await self.loadWorkers() }
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingZones = false
    }

    func loadDNSRecords(for zone: Zone, clearOld: Bool = true) async {
        guard let api = api else { return }
        isLoadingDNS = true
        if clearOld {
            dnsRecords = []
        }

        do {
            var allRecords: [DNSRecord] = []
            var page = 1
            var hasMore = true

            while hasMore {
                let (records, info) = try await api.listDNSRecords(zoneId: zone.id, page: page)
                allRecords.append(contentsOf: records)

                if let totalPages = info?.total_pages, page < totalPages {
                    page += 1
                } else {
                    hasMore = false
                }
            }

            dnsRecords = allRecords
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingDNS = false
    }

    func loadWorkers() async {
        guard let api = api, let accountId = accountId else { return }
        isLoadingWorkers = true

        do {
            workers = try await api.listWorkers(accountId: accountId)
        } catch {
            // Workers might not be available on all plans
            if case CloudflareAPIError.notFound = error {
                workers = []
            } else {
                errorMessage = error.localizedDescription
            }
        }

        isLoadingWorkers = false
    }

    func getWorkerScript(workerId: String) async throws -> String {
        guard let api = api, let accountId = accountId else {
            throw CloudflareAPIError.apiError("Not authenticated or missing account ID")
        }
        return try await api.getWorkerScript(accountId: accountId, scriptName: workerId)
    }

    func selectZone(_ zone: Zone) {
        selectedItem = .zone(zone.id)
        Task {
            await loadDNSRecords(for: zone, clearOld: true)
        }
    }

    func selectWorker(_ worker: WorkerScript) {
        selectedItem = .worker(worker.id)
    }

    func refresh() async {
        await loadZones()
        if accountId != nil {
            await loadWorkers()
        }
        if case .zone(let id) = selectedItem, let zone = zones.first(where: { $0.id == id }) {
            await loadDNSRecords(for: zone, clearOld: false)
        }
    }
    func showSuccess(_ message: String) {
        successMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            if self?.successMessage == message {
                self?.successMessage = nil
            }
        }
    }

    func showError(_ message: String) {
        errorMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            if self?.errorMessage == message {
                self?.errorMessage = nil
            }
        }
    }
}
