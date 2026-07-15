import Foundation

// MARK: - HTTP Method

enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case patch  = "PATCH"
    case delete = "DELETE"
}

// MARK: - API Error

enum APIError: LocalizedError {
    case invalidURL
    case requestFailed(Int)
    case decodingFailed(Error)
    case noData
    case unauthorized
    case networkError(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:           return "Invalid URL"
        case .requestFailed(let c): return "Server error (\(c))"
        case .decodingFailed:       return "Failed to parse response"
        case .noData:               return "No data received"
        case .unauthorized:         return "Session expired — please login again"
        case .networkError(let e):  return e.localizedDescription
        case .unknown:              return "Something went wrong"
        }
    }
}

// MARK: - API Endpoint Protocol

protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
    var queryItems: [URLQueryItem]? { get }
}

extension APIEndpoint {
    var headers: [String: String]? { nil }
    var body: Data? { nil }
    var queryItems: [URLQueryItem]? { nil }
}

// MARK: - API Client

final class APIClient {

    // MARK: - Singleton

    static let shared = APIClient()

    // MARK: - Properties

    private let baseURL: String
    private let session: URLSession
    private let decoder: JSONDecoder

    // MARK: - Init

    init(
        baseURL: String = "https://api.fastmart.com/v1",
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
    }

    // MARK: - Core Request Builder

    /// Fire an endpoint and decode the response.
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let request = try buildRequest(from: endpoint)
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw APIError.unauthorized
        default:
            throw APIError.requestFailed(httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }

    /// Fire an endpoint that returns nothing.
    func request(_ endpoint: APIEndpoint) async throws {
        let request = try buildRequest(from: endpoint)
        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw APIError.unauthorized
        default:
            throw APIError.requestFailed(httpResponse.statusCode)
        }
    }

    // MARK: - Request Builder

    private func buildRequest(from endpoint: APIEndpoint) throws -> URLRequest {
        // URL
        guard var components = URLComponents(string: baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }

        if let queryItems = endpoint.queryItems, !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = 30

        // Default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Auth token (auto-injected)
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Endpoint-specific headers (override defaults if needed)
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Body
        request.httpBody = endpoint.body

        return request
    }
}
