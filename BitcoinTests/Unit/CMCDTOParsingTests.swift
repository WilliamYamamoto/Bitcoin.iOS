import Foundation
import Testing
@testable import Desafio

struct CMCDTOParsingTests {
    @Test
    func decodeListingsLatestResponse() throws {
        let data = Data(
            """
            {
              "status": {
                "timestamp": "2026-03-05T22:43:48.471Z",
                "error_code": 0,
                "error_message": "",
                "elapsed": 10,
                "credit_count": 1,
                "notice": ""
              },
              "data": [
                {
                  "id": 270,
                  "name": "Binance",
                  "slug": "binance",
                  "date_launched": "2017-07-14T00:00:00.000Z",
                  "quote": {
                    "USD": {
                      "volume_24h": 768478308.529847,
                      "volume_24h_adjusted": 768478308.529847,
                      "effective_liquidity_24h": 629.9774,
                      "last_updated": "2026-03-05T22:43:48.471Z"
                    }
                  }
                }
              ]
            }
            """.utf8
        )

        let response = try CMCDecoder.make().decode(CMCResponseDTO<[ExchangeListingDTO]>.self, from: data)

        #expect(response.data.count == 1)
        #expect(response.data.first?.id == 270)
        #expect(response.data.first?.spotVolumeUSD == Decimal(string: "768478308.529847"))
    }

    @Test
    func decodeInfoResponse() throws {
        let data = Data(
            """
            {
              "status": {
                "timestamp": "2026-03-05T22:43:48.471Z",
                "error_code": 0,
                "error_message": "",
                "elapsed": 10,
                "credit_count": 1,
                "notice": ""
              },
              "data": {
                "270": {
                  "id": 270,
                  "name": "Binance",
                  "slug": "binance",
                  "logo": "https://s2.coinmarketcap.com/static/img/exchanges/64x64/270.png",
                  "description": "Launched in Jul-2017, Binance is a centralized exchange based in Malta.",
                  "date_launched": "2017-07-14T00:00:00.000Z",
                  "maker_fee": 0.02,
                  "taker_fee": 0.04,
                  "spot_volume_usd": 66926283498.60113,
                  "urls": {
                    "website": ["https://www.binance.com/"]
                  }
                }
              }
            }
            """.utf8
        )

        let response = try CMCDecoder.make().decode(CMCResponseDTO<[String: ExchangeInfoDTO]>.self, from: data)
        let info = try #require(response.data["270"])

        #expect(info.name == "Binance")
        #expect(info.spotVolumeUSD == Decimal(string: "66926283498.60113"))
        #expect(info.logo?.absoluteString == "https://s2.coinmarketcap.com/static/img/exchanges/64x64/270.png")
        #expect(info.urls?.website?.first?.absoluteString == "https://www.binance.com/")
    }

    @Test
    func decodeInfoResponseBuildsFallbackLogoURLWhenSandboxReturnsUnsupportedValue() throws {
        let data = Data(
            """
            {
              "status": {
                "timestamp": "2026-03-05T22:43:48.471Z",
                "error_code": 0,
                "error_message": "",
                "elapsed": 10,
                "credit_count": 1,
                "notice": ""
              },
              "data": {
                "42": {
                  "id": 42,
                  "name": "Sandbox Exchange",
                  "slug": "sandbox-exchange",
                  "logo": "bw7xqd1ynpf"
                }
              }
            }
            """.utf8
        )

        let response = try CMCDecoder.make().decode(CMCResponseDTO<[String: ExchangeInfoDTO]>.self, from: data)
        let info = try #require(response.data["42"])

        #expect(info.logo?.absoluteString == "https://s2.coinmarketcap.com/static/img/exchanges/64x64/42.png")
    }

    @Test
    func decodeAssetsResponse() throws {
        let data = Data(
            """
            {
              "status": {
                "timestamp": "2022-11-24T08:23:22.028Z",
                "error_code": 0,
                "error_message": null,
                "elapsed": 1828,
                "credit_count": 0,
                "notice": null
              },
              "data": [
                {
                  "wallet_address": "0xabc",
                  "balance": 45000000,
                  "platform": {
                    "crypto_id": 1027,
                    "symbol": "ETH",
                    "name": "Ethereum"
                  },
                  "currency": {
                    "crypto_id": 5117,
                    "price_usd": 0.10241799413549,
                    "symbol": "OGN",
                    "name": "Origin Protocol"
                  }
                }
              ]
            }
            """.utf8
        )

        let response = try CMCDecoder.make().decode(CMCResponseDTO<[ExchangeAssetDTO]>.self, from: data)
        let asset = try #require(response.data.first)

        #expect(asset.currency.name == "Origin Protocol")
        #expect(asset.currency.priceUSD == Decimal(string: "0.10241799413549"))
        #expect(asset.assetID.contains("5117"))
    }
}
