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
    case httpError(statusCode: Int, message: String?)
    case decodingFailed(Error)
    case noData
    case networkError(Error)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .httpError(_, let message?):
            return message
        case .httpError(let code, nil):
            return "Server error (\(code))"
        case .decodingFailed(let e):
            return "Failed to parse response: \(e.localizedDescription)"
        case .noData:
            return "No data received"
        case .networkError(let e):
            return e.localizedDescription
        case .unknown:
            return "Something went wrong"
        }
    }
    
    /// Convenience: the HTTP status code, if any.
    var statusCode: Int? {
        if case .httpError(let code, _) = self { return code }
        return nil
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
    private let logger = NetworkLogger.shared

    // MARK: - Init

    init(
        baseURL: String = "https://fastapi-for-ai.onrender.com",
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
    }

    // MARK: - Request (with decoding)

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let request = try buildRequest(from: endpoint)
        
        // ── Log Request ──
        logger.logRequest(request)
        
        let startTime = Date()
        
        do {
            let (data, response) = try await session.data(for: request)
            
            let duration = Date().timeIntervalSince(startTime)
            
            // ── Log Response ──
            logger.logResponse(response, data: data, error: nil, duration: duration)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                break
            default:
                let backendMessage = extractBackendMessage(from: data)
                throw APIError.httpError(
                    statusCode: httpResponse.statusCode,
                    message: backendMessage
                )
            }
            
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingFailed(error)
            }
            
        } catch let error as APIError {
            throw error
        } catch {
            let _ = Date().timeIntervalSince(startTime)
            logger.log("Network request failed: \(error.localizedDescription)", level: .error)
            throw APIError.networkError(error)
        }
    }

    // MARK: - Request (no decoding)

    func request(_ endpoint: APIEndpoint) async throws {
        let request = try buildRequest(from: endpoint)

        // ── Log Request ──
        logger.logRequest(request)

        let startTime = Date()

        do {
            let (data, response) = try await session.data(for: request)

            let duration = Date().timeIntervalSince(startTime)

            // ── Log Response ──
            logger.logResponse(response, data: nil, error: nil, duration: duration)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }

            switch httpResponse.statusCode {
            case 200...299:
                return
            default:
                let backendMessage = extractBackendMessage(from: data)
                throw APIError.httpError(
                    statusCode: httpResponse.statusCode,
                    message: backendMessage
                )
            }

        } catch let error as APIError {
            throw error
        } catch {
            let _ = Date().timeIntervalSince(startTime)
            logger.log("Network request failed: \(error.localizedDescription)", level: .error)
            throw APIError.networkError(error)
        }
    }

    // MARK: - Request Builder

    private func buildRequest(from endpoint: APIEndpoint) throws -> URLRequest {
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

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = SessionStore.shared.authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        request.httpBody = endpoint.body

        return request
    }
    
    // MARK: - Backend Error Parser

      private func extractBackendMessage(from data: Data?) -> String? {
          guard let data = data else { return nil }

          // FastAPI { "detail": "..." } or { "detail": [{...}] }
          if let error = try? decoder.decode(ServerAPIError.self, from: data) {
              return error.detail.message
          }

          // Generic { "message": "..." }
          if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
             let message = json["message"] as? String {
              return message
          }

          return String(data: data, encoding: .utf8)
      }
}
