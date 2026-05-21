import Foundation

struct CMCResponseDTO<DataType: Decodable>: Decodable {
    let status: CMCStatusDTO
    let data: DataType
}

struct CMCStatusDTO: Decodable {
    let timestamp: String?
    let errorCode: Int?
    let errorMessage: String?
    let elapsed: Int?
    let creditCount: Int?
    let notice: String?

    enum CodingKeys: String, CodingKey {
        case timestamp
        case errorCode = "error_code"
        case errorMessage = "error_message"
        case elapsed
        case creditCount = "credit_count"
        case notice
    }
}

struct EmptyPayload: Decodable {}
