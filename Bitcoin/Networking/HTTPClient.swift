import Foundation

protocol HTTPClient: Sendable {
    func send(_ request: APIRequest, config: AppConfig) async throws -> Data
}
