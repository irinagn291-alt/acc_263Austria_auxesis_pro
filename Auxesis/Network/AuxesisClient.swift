import Foundation

/// Typed transport errors. A 404 is not retried. This product has no remote catalog.
enum AuxesisTransportError: Error, Equatable, Sendable {
    case timeout
    case transport
    case httpStatus(Int)
    case notFound
    case decode
    case cancelled
}

protocol HTTPTransport: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

struct URLSessionTransport: HTTPTransport {
    let session: URLSession

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
}

/// Owns session policy. User-Agent on every request. No Open Food Facts catalog.
struct AuxesisClient: Sendable {
    static let userAgent = "Auxesis/1.0 (iOS; +https://auxesis-ring.pro)"
    static let timeout: TimeInterval = 15

    private let transport: any HTTPTransport

    init(transport: any HTTPTransport) {
        self.transport = transport
    }

    init(session: URLSession? = nil) {
        if let session {
            transport = URLSessionTransport(session: session)
        } else {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.timeoutIntervalForRequest = Self.timeout
            configuration.httpAdditionalHeaders = ["User-Agent": Self.userAgent]
            transport = URLSessionTransport(session: URLSession(configuration: configuration))
        }
    }

    static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        return decoder
    }

    func data(for request: URLRequest) async throws -> Data {
        try await perform(request, attempt: 0)
    }

    func get(_ url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(Self.userAgent, forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = Self.timeout
        return try await data(for: request)
    }

    func decode<T: Decodable>(_ data: Data, as type: T.Type) throws -> T {
        do {
            return try Self.decoder().decode(type, from: data)
        } catch {
            throw AuxesisTransportError.decode
        }
    }

    private func perform(_ request: URLRequest, attempt: Int) async throws -> Data {
        try Task.checkCancellation()
        var stamped = request
        if stamped.value(forHTTPHeaderField: "User-Agent") == nil {
            stamped.setValue(Self.userAgent, forHTTPHeaderField: "User-Agent")
        }
        if stamped.timeoutInterval <= 0 || stamped.timeoutInterval > Self.timeout {
            stamped.timeoutInterval = Self.timeout
        }
        do {
            let (data, response) = try await transport.data(for: stamped)
            try Self.validate(response)
            return data
        } catch is CancellationError {
            throw AuxesisTransportError.cancelled
        } catch let error as AuxesisTransportError {
            throw error
        } catch {
            if attempt == 0, Self.isTransient(error) {
                return try await perform(request, attempt: 1)
            }
            if (error as? URLError)?.code == .timedOut {
                throw AuxesisTransportError.timeout
            }
            throw AuxesisTransportError.transport
        }
    }

    private static func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }
        if http.statusCode == 404 {
            throw AuxesisTransportError.notFound
        }
        guard (200 ..< 300).contains(http.statusCode) else {
            throw AuxesisTransportError.httpStatus(http.statusCode)
        }
    }

    private static func isTransient(_ error: Error) -> Bool {
        guard let urlError = error as? URLError else { return false }
        switch urlError.code {
        case .timedOut, .networkConnectionLost, .notConnectedToInternet, .cannotConnectToHost:
            return true
        default:
            return false
        }
    }
}
