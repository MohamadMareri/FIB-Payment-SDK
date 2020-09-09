import Foundation
 
struct Token: Decodable {
    let accessToken: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

struct TransactionCode: Decodable {
    public let paymentId: String
    public let readableCode: String
    public let personalAppLink: String
    public let businessAppLink: String
}
