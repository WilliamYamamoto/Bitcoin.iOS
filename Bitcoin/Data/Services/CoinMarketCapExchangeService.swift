import Foundation

protocol ExchangeService: Sendable {
    func fetchListings(limit: Int) async throws -> [ExchangeListingDTO]
    func fetchInfo(ids: [Int]) async throws -> [Int: ExchangeInfoDTO]
    func fetchAssets(exchangeID: Int) async throws -> [ExchangeAssetDTO]
}

struct CoinMarketCapExchangeService: ExchangeService {
    let httpClient: HTTPClient
    let config: AppConfig

    func fetchListings(limit: Int = 30) async throws -> [ExchangeListingDTO] {
        let request = APIRequest(
            path: "/v1/exchange/listings/latest",
            queryItems: [
                URLQueryItem(name: "start", value: "1"),
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "sort", value: "volume_24h"),
                URLQueryItem(name: "sort_dir", value: "desc"),
                URLQueryItem(name: "market_type", value: "all"),
                URLQueryItem(name: "category", value: "spot"),
                URLQueryItem(name: "convert", value: "USD"),
                URLQueryItem(name: "aux", value: "date_launched")
            ]
        )

        let data = try await httpClient.send(request, config: config)
        return try decode(CMCResponseDTO<[ExchangeListingDTO]>.self, from: data).data
    }

    func fetchInfo(ids: [Int]) async throws -> [Int: ExchangeInfoDTO] {
        guard !ids.isEmpty else { return [:] }

        let request = APIRequest(
            path: "/v1/exchange/info",
            queryItems: [
                URLQueryItem(name: "id", value: ids.map(String.init).joined(separator: ",")),
                URLQueryItem(name: "aux", value: "urls,logo,description,date_launched")
            ]
        )

        let data = try await httpClient.send(request, config: config)
        let response = try decode(CMCResponseDTO<[String: ExchangeInfoDTO]>.self, from: data)
        return Dictionary(uniqueKeysWithValues: response.data.compactMap { key, value in
            guard let id = Int(key) else { return nil }
            return (id, value)
        })
    }

    func fetchAssets(exchangeID: Int) async throws -> [ExchangeAssetDTO] {
        let request = APIRequest(
            path: "/v1/exchange/assets",
            queryItems: [
                URLQueryItem(name: "id", value: String(exchangeID))
            ]
        )

        let data = try await httpClient.send(request, config: config)
        let response = try decode(CMCResponseDTO<[String: [ExchangeAssetDTO]]>.self, from: data)
        return response.data[String(exchangeID)] ?? []
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            let decoder = CMCDecoder.make()
            return try decoder.decode(type, from: data)
        } catch let decodingError as DecodingError {
            #if DEBUG
            switch decodingError {
            case .keyNotFound(let key, let context):
                print("[CMC Decode] keyNotFound: \(key.stringValue) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            case .typeMismatch(let type, let context):
                print("[CMC Decode] typeMismatch: \(type) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            case .valueNotFound(let type, let context):
                print("[CMC Decode] valueNotFound: \(type) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            case .dataCorrupted(let context):
                print("[CMC Decode] dataCorrupted at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            @unknown default:
                print("[CMC Decode] unknown DecodingError")
            }
            if let json = String(data: data, encoding: .utf8) {
                print("[CMC Decode] Raw payload:\n\(json)")
            }
            #endif
            throw NetworkError.decoding
        } catch {
            throw error
        }
    }
}
