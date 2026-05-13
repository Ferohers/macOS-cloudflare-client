//
//  CloudflareAPI.swift
//  Flare
//
//  Async networking service for Cloudflare API v4
//

import Foundation

// MARK: - API Errors

nonisolated enum CloudflareAPIError: LocalizedError, Sendable {
    case invalidToken
    case networkError(String)
    case decodingError(String)
    case apiError(String)
    case unauthorized
    case rateLimited
    case notFound
    case unknown(Int)

    var errorDescription: String? {
        switch self {
        case .invalidToken:
            return "Invalid API token. Please check your token and try again."
        case .networkError(let msg):
            return "Network error: \(msg)"
        case .decodingError(let msg):
            return "Failed to parse response: \(msg)"
        case .apiError(let msg):
            return msg
        case .unauthorized:
            return "Unauthorized. Your API token may have expired."
        case .rateLimited:
            return "Rate limited. Please wait a moment and try again."
        case .notFound:
            return "Resource not found."
        case .unknown(let code):
            return "Unexpected error (HTTP \(code))."
        }
    }
}

// MARK: - API Service

actor CloudflareAPI {
    private let baseURL = "https://api.cloudflare.com/client/v4"
    private var token: String
    private let session: URLSession

    init(token: String) {
        self.token = token
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }

    func updateToken(_ newToken: String) {
        self.token = newToken
    }

    // MARK: - API Methods

    func verifyToken() async throws -> TokenVerifyResult {
        let response: CloudflareResponse<TokenVerifyResult> = try await request(
            endpoint: "/user/tokens/verify"
        )
        guard let result = response.result else {
            throw CloudflareAPIError.invalidToken
        }
        return result
    }

    func getUserDetails() async throws -> UserDetails {
        let response: CloudflareResponse<UserDetails> = try await request(
            endpoint: "/user"
        )
        guard let result = response.result else {
            throw CloudflareAPIError.apiError("Failed to fetch user details.")
        }
        return result
    }

    func listZones(page: Int = 1, perPage: Int = 50) async throws -> ([Zone], ResultInfo?) {
        let response: CloudflareListResponse<Zone> = try await request(
            endpoint: "/zones",
            queryItems: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)"),
                URLQueryItem(name: "order", value: "name"),
                URLQueryItem(name: "direction", value: "asc")
            ]
        )
        return (response.result, response.result_info)
    }

    func listDNSRecords(zoneId: String, page: Int = 1, perPage: Int = 100) async throws -> ([DNSRecord], ResultInfo?) {
        let response: CloudflareListResponse<DNSRecord> = try await request(
            endpoint: "/zones/\(zoneId)/dns_records",
            queryItems: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)")
            ]
        )
        return (response.result, response.result_info)
    }

    func createDNSRecord(zoneId: String, payload: DNSRecordPayload) async throws -> DNSRecord {
        let data = try JSONEncoder().encode(payload)
        let response: CloudflareResponse<DNSRecord> = try await request(
            endpoint: "/zones/\(zoneId)/dns_records",
            method: "POST",
            body: data
        )
        guard let result = response.result else {
            throw CloudflareAPIError.apiError("Failed to create DNS record.")
        }
        return result
    }

    func updateDNSRecord(zoneId: String, recordId: String, payload: DNSRecordPayload) async throws -> DNSRecord {
        let data = try JSONEncoder().encode(payload)
        let response: CloudflareResponse<DNSRecord> = try await request(
            endpoint: "/zones/\(zoneId)/dns_records/\(recordId)",
            method: "PUT",
            body: data
        )
        guard let result = response.result else {
            throw CloudflareAPIError.apiError("Failed to update DNS record.")
        }
        return result
    }

    func deleteDNSRecord(zoneId: String, recordId: String) async throws {
        let response: CloudflareResponse<DeleteResult> = try await request(
            endpoint: "/zones/\(zoneId)/dns_records/\(recordId)",
            method: "DELETE"
        )
        guard response.success else {
            throw CloudflareAPIError.apiError("Failed to delete DNS record.")
        }
    }

    func listWorkers(accountId: String) async throws -> [WorkerScript] {
        let response: CloudflareListResponse<WorkerScript> = try await request(
            endpoint: "/accounts/\(accountId)/workers/scripts"
        )
        return response.result
    }

    func getWorkerScript(accountId: String, scriptName: String) async throws -> String {
        let data = try await rawRequest(
            endpoint: "/accounts/\(accountId)/workers/scripts/\(scriptName)"
        )
        if let rawContent = String(data: data, encoding: .utf8) {
            return extractMultipartScript(from: rawContent)
        }
        throw CloudflareAPIError.decodingError("Could not decode script content as UTF-8.")
    }

    private func extractMultipartScript(from raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("--") else { return raw }
        
        do {
            // Regex to find the content between the double-newline (after headers) and the end boundary
            // We look for Content-Disposition, then \r\n\r\n or \n\n, then capture everything until \r\n-- or \n--
            let pattern = "Content-Disposition:.*?name=\"[^\"]+\".*?[\\r\\n]{2}([\\s\\S]*?)[\\r\\n]+--"
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            if let match = regex.firstMatch(in: trimmed, options: [], range: NSRange(location: 0, length: trimmed.utf16.count)) {
                if let range = Range(match.range(at: 1), in: trimmed) {
                    return String(trimmed[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            
            // Fallback: If it didn't match Content-Disposition exactly, just try to find the first double newline
            if let headerEnd = trimmed.range(of: "\r\n\r\n") ?? trimmed.range(of: "\n\n") {
                let contentStartIndex = headerEnd.upperBound
                let content = String(trimmed[contentStartIndex...])
                
                // Find the boundary
                let firstLineEnd = trimmed.range(of: "\n")?.lowerBound ?? trimmed.endIndex
                let boundary = String(trimmed[trimmed.startIndex..<firstLineEnd]).trimmingCharacters(in: .whitespacesAndNewlines)
                
                if let endRange = content.range(of: boundary) {
                    var finalContent = String(content[..<endRange.lowerBound])
                    while finalContent.hasSuffix("\n") || finalContent.hasSuffix("\r") || finalContent.hasSuffix("-") {
                        finalContent.removeLast()
                    }
                    return finalContent.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                return content.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            print("Regex error: \(error)")
        }
        
        return raw
    }

    // MARK: - Generic Request

    private func request<T: Codable & Sendable>(
        endpoint: String,
        method: String = "GET",
        queryItems: [URLQueryItem]? = nil,
        body: Data? = nil
    ) async throws -> T {
        let data = try await rawRequest(endpoint: endpoint, method: method, queryItems: queryItems, body: body)
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            throw CloudflareAPIError.decodingError(error.localizedDescription)
        }
    }

    private func rawRequest(
        endpoint: String,
        method: String = "GET",
        queryItems: [URLQueryItem]? = nil,
        body: Data? = nil
    ) async throws -> Data {
        guard var components = URLComponents(string: baseURL + endpoint) else {
            throw CloudflareAPIError.networkError("Invalid URL: \(endpoint)")
        }

        if let queryItems = queryItems, !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw CloudflareAPIError.networkError("Failed to construct URL.")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body = body {
            request.httpBody = body
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw CloudflareAPIError.networkError(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CloudflareAPIError.networkError("Invalid response type.")
        }

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 429:
            throw CloudflareAPIError.rateLimited
        default:
            // Try to parse Cloudflare specific error message first
            if let errorResponse = try? JSONDecoder().decode(CloudflareResponse<EmptyResult>.self, from: data),
               let firstError = errorResponse.errors.first {
                // Cloudflare provides specific errors (e.g. "Actor does not have permission")
                throw CloudflareAPIError.apiError("\(firstError.message) (Code: \(firstError.code))")
            }
            
            // Fallback to generic errors if no specific message is available
            switch httpResponse.statusCode {
            case 401:
                throw CloudflareAPIError.unauthorized
            case 403:
                throw CloudflareAPIError.invalidToken
            case 404:
                throw CloudflareAPIError.notFound
            default:
                throw CloudflareAPIError.unknown(httpResponse.statusCode)
            }
        }

        return data
    }
}

// Empty placeholder for error-only responses
private nonisolated struct EmptyResult: Codable, Sendable {}
