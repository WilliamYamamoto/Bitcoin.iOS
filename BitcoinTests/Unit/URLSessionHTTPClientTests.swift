import Foundation
import Testing
@testable import Desafio

struct URLSessionHTTPClientTests {
    @Test
    func returnsDataOnSuccess() async throws {
        URLProtocolStub.stub(data: Data("{}".utf8), response: HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil), error: nil)

        let client = URLSessionHTTPClient(session: makeSession())
        let data = try await client.send(APIRequest(path: "/v1/test"), config: AppConfig(apiKey: "key", baseURL: URL(string: "https://example.com")!, requestTimeout: 1))

        #expect(String(decoding: data, as: UTF8.self) == "{}")
    }

    @Test
    func maps429ToRateLimited() async throws {
        URLProtocolStub.stub(data: Data(), response: HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 429, httpVersion: nil, headerFields: nil), error: nil)

        let client = URLSessionHTTPClient(session: makeSession())

        await #expect(throws: NetworkError.rateLimited) {
            try await client.send(APIRequest(path: "/v1/test"), config: AppConfig(apiKey: "key", baseURL: URL(string: "https://example.com")!, requestTimeout: 1))
        }
    }

    @Test
    func missingAPIKeyThrowsExplicitError() async throws {
        let client = URLSessionHTTPClient(session: makeSession())

        await #expect(throws: NetworkError.missingAPIKey) {
            try await client.send(APIRequest(path: "/v1/test"), config: AppConfig(apiKey: nil, baseURL: URL(string: "https://example.com")!, requestTimeout: 1))
        }
    }

    @Test
    func mapsOfflineNSError() async throws {
        let nsError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        URLProtocolStub.stub(data: nil, response: nil, error: nsError)

        let client = URLSessionHTTPClient(session: makeSession())

        await #expect(throws: NetworkError.offline) {
            try await client.send(APIRequest(path: "/v1/test"), config: AppConfig(apiKey: "key", baseURL: URL(string: "https://example.com")!, requestTimeout: 1))
        }
    }
}

private func makeSession() -> URLSession {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [URLProtocolStub.self]
    return URLSession(configuration: configuration)
}

private final class URLProtocolStub: URLProtocol, @unchecked Sendable {
    private static var currentStub: Stub?

    struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }

    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        currentStub = Stub(data: data, response: response, error: error)
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let stub = Self.currentStub else { return }

        if let response = stub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }

        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}
}
