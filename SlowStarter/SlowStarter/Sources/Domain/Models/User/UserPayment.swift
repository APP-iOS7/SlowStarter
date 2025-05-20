
import Foundation

struct UserPayment: Identifiable, Codable {
    var paymentId: String
    var userId: String
    var amount: Int
    var description: String?
    var paymentMethod: String?
    var paymentGateway: String?
    var paymentStatus: String?
    var externalTransactionId: String?
    var createdAt: Date?

    var id: String { paymentId }

    enum CodingKeys: String, CodingKey {
        case paymentId = "payment_id"
        case userId = "user_id"
        case amount
        case description
        case paymentMethod = "payment_method"
        case paymentGateway = "payment_gateway"
        case paymentStatus = "payment_status"
        case externalTransactionId = "external_transaction_id"
        case createdAt = "created_at"
    }
}

extension UserPayment {
    static let mock: UserPayment = UserPayment(
        paymentId: UUID().uuidString,
        userId: "45832D0B-5DFC-4A23-BFE9-CF3D7422F0C5",
        amount: 4990,
        description: "Monthly subscription",
        paymentMethod: "card",
        paymentGateway: "kakaopay",
        paymentStatus: "paid",
        externalTransactionId: "pg-123456",
        createdAt: Date()
    )
}
