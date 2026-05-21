import Foundation

struct ExchangeInfoDTO: Decodable {
    let id: Int
    let name: String
    let slug: String?
    let logo: URL?
    let description: String?
    let dateLaunched: Date?
    let makerFee: Decimal?
    let takerFee: Decimal?
    let spotVolumeUSD: Decimal?
    let urls: ExchangeURLsDTO?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case slug
        case logo
        case description
        case dateLaunched = "date_launched"
        case makerFee = "maker_fee"
        case takerFee = "taker_fee"
        case spotVolumeUSD = "spot_volume_usd"
        case urls
    }

    init(
        id: Int,
        name: String,
        slug: String?,
        logo: URL?,
        description: String?,
        dateLaunched: Date?,
        makerFee: Decimal?,
        takerFee: Decimal?,
        spotVolumeUSD: Decimal?,
        urls: ExchangeURLsDTO?
    ) {
        self.id = id
        self.name = name
        self.slug = slug
        self.logo = logo
        self.description = description
        self.dateLaunched = dateLaunched
        self.makerFee = makerFee
        self.takerFee = takerFee
        self.spotVolumeUSD = spotVolumeUSD
        self.urls = urls
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let id = try container.decode(Int.self, forKey: .id)
        let rawLogo = try container.decodeIfPresent(String.self, forKey: .logo)

        self.init(
            id: id,
            name: try container.decode(String.self, forKey: .name),
            slug: try container.decodeIfPresent(String.self, forKey: .slug),
            logo: Self.normalizeLogoURL(rawLogo, exchangeID: id),
            description: try container.decodeIfPresent(String.self, forKey: .description),
            dateLaunched: try container.decodeIfPresent(Date.self, forKey: .dateLaunched),
            makerFee: try container.decodeIfPresent(Decimal.self, forKey: .makerFee),
            takerFee: try container.decodeIfPresent(Decimal.self, forKey: .takerFee),
            spotVolumeUSD: try container.decodeIfPresent(Decimal.self, forKey: .spotVolumeUSD),
            urls: try container.decodeIfPresent(ExchangeURLsDTO.self, forKey: .urls)
        )
    }
}

private extension ExchangeInfoDTO {
    static func normalizeLogoURL(_ rawValue: String?, exchangeID: Int) -> URL? {
        guard let rawValue else { return nil }

        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if let url = URL(string: trimmed),
           let scheme = url.scheme?.lowercased(),
           scheme == "http" || scheme == "https" {
            return url
        }

        if trimmed.hasPrefix("//") {
            return URL(string: "https:\(trimmed)")
        }

        return URL(string: "https://s2.coinmarketcap.com/static/img/exchanges/64x64/\(exchangeID).png")
    }
}

struct ExchangeURLsDTO: Decodable {
    let website: [URL]?
}
