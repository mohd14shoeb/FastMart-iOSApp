import Foundation

// MARK: - Log Level

enum LogLevel: String {
    case debug   = "🔍"
    case info    = "ℹ️"
    case success = "✅"
    case warning = "⚠️"
    case error   = "❌"
    case network = "🌐"
}

// MARK: - Network Logger

final class NetworkLogger {

    static let shared = NetworkLogger()

    var isEnabled: Bool = true

    private let separator = "──────────────────────────────────────────────────────"

    private init() {}

    // MARK: - Request Logging

    func logRequest(_ request: URLRequest) {
        guard isEnabled else { return }
        print("")
        print(separator)
        print("📤 REQUEST")
        print(separator)
        print("Method : \(request.httpMethod ?? "?")")
        print("URL    : \(request.url?.absoluteString ?? "?")")

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("Headers:")
            for (key, value) in headers.sorted(by: { $0.key < $1.key }) {
                let masked = key == "Authorization" ? maskToken(value) : value
                print("  \(key): \(masked)")
            }
        }

        if let body = request.httpBody, let bodyString = prettyJSON(body) {
            print("Body   :")
            print(bodyString)
        }

        print(separator)
    }

    // MARK: - Response Logging

    func logResponse(_ response: URLResponse?, data: Data?, error: Error?, duration: TimeInterval) {
        guard isEnabled else { return }
        print("")

        guard let httpResponse = response as? HTTPURLResponse else {
            print(separator)
            print("📥 RESPONSE (FAILED)")
            print(separator)
            print("Error  : \(error?.localizedDescription ?? "Unknown")")
            print("Time   : \(formattedDuration(duration))")
            print(separator)
            return
        }

        let statusCode = httpResponse.statusCode
        let emoji = statusEmoji(statusCode)

        print(separator)
        print("📥 RESPONSE \(emoji)")
        print(separator)
        print("Status : \(statusCode) \(HTTPURLResponse.localizedString(forStatusCode: statusCode))")
        print("URL    : \(httpResponse.url?.absoluteString ?? "?")")
        print("Time   : \(formattedDuration(duration))")

        if let data = data, data.count <= 100_000 {
            if let json = prettyJSON(data) {
                print("Body   :")
                print(json)
            } else if let text = String(data: data, encoding: .utf8) {
                print("Body   : \(text.prefix(500))")
            } else {
                print("Body   : [\(data.count) bytes — not UTF-8]")
            }
        } else if let data = data {
            print("Body   : [\(data.count) bytes — truncated]")
        }

        print(separator)
    }

    // MARK: - Generic Logging

    func log(_ message: String, level: LogLevel = .debug, file: String = #file, line: Int = #line) {
        guard isEnabled else { return }
        let filename = (file as NSString).lastPathComponent
        print("\(level.rawValue) [\(filename):\(line)]  \(message)")
    }

    // MARK: - Helpers

    private func prettyJSON(_ data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data),
              let pretty = try? JSONSerialization.data(
                withJSONObject: json,
                options: [.prettyPrinted, .sortedKeys]
              ),
              let string = String(data: pretty, encoding: .utf8)
        else { return nil }
        return string
    }

    private func statusEmoji(_ code: Int) -> String {
        switch code {
        case 200...299: return "✅"
        case 300...399: return "↪️"
        case 400...499: return "⚠️"
        case 500...599: return "❌"
        default:        return "❓"
        }
    }

    private func formattedDuration(_ seconds: TimeInterval) -> String {
        if seconds < 1 {
            return "\(Int(seconds * 1000)) ms"
        } else if seconds < 60 {
            return String(format: "%.2f s", seconds)
        } else {
            return "\(Int(seconds) / 60)m \(Int(seconds) % 60)s"
        }
    }

    private func maskToken(_ token: String) -> String {
        guard token.count > 15 else { return "Bearer ***" }
        return "\(token.prefix(10))...<redacted>"
    }
}

// MARK: - Convenience Global Functions

func logDebug(_ message: String, file: String = #file, line: Int = #line) {
    NetworkLogger.shared.log(message, level: .debug, file: file, line: line)
}

func logInfo(_ message: String, file: String = #file, line: Int = #line) {
    NetworkLogger.shared.log(message, level: .info, file: file, line: line)
}

func logSuccess(_ message: String, file: String = #file, line: Int = #line) {
    NetworkLogger.shared.log(message, level: .success, file: file, line: line)
}

func logWarning(_ message: String, file: String = #file, line: Int = #line) {
    NetworkLogger.shared.log(message, level: .warning, file: file, line: line)
}

func logError(_ message: String, file: String = #file, line: Int = #line) {
    NetworkLogger.shared.log(message, level: .error, file: file, line: line)
}
