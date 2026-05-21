import Foundation

struct URLSessionHTTPClient: HTTPClient {
    let session: URLSession

    func send(_ request: APIRequest, config: AppConfig) async throws -> Data {
        guard let apiKey = config.apiKey, !apiKey.isEmpty else {
            throw NetworkError.missingAPIKey
        }

        guard var components = URLComponents(url: config.baseURL.appendingPathComponent(request.path), resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }

        if !request.queryItems.isEmpty {
            components.queryItems = request.queryItems
        }

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url, timeoutInterval: config.requestTimeout)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.setValue(apiKey, forHTTPHeaderField: "X-CMC_PRO_API_KEY")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        for (header, value) in request.headers {
            urlRequest.setValue(value, forHTTPHeaderField: header)
        }

        do {
            let (data, response) = try await session.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unexpected("Resposta HTTP invalida.")
            }

            switch httpResponse.statusCode {
            case 200 ... 299:
                return data
            case 429:
                throw NetworkError.rateLimited
            default:
                let message = Self.extractMessage(from: data) ?? String(data: data, encoding: .utf8)
                throw NetworkError.httpStatus(code: httpResponse.statusCode, message: message)
            }
        } catch {
            throw Self.map(error)
        }
    }

    private static func map(_ error: Error) -> NetworkError {
        if let networkError = error as? NetworkError {
            return networkError
        }

        let nsError = error as NSError
        switch nsError.code {
        case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
            return .offline
        case NSURLErrorTimedOut:
            return .timeout
        default:
            return .unexpected(nsError.localizedDescription)
        }
    }

    private static func extractMessage(from data: Data) -> String? {
        let response = try? CMCDecoder.make().decode(CMCErrorEnvelope.self, from: data)
        return response?.status.errorMessage ?? response?.status.notice
    }
}

private struct CMCErrorEnvelope: Decodable {
    let status: CMCStatusDTO
}
