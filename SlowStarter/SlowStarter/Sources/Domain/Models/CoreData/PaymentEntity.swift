extension PaymentEntity {
    func toUserPayment() -> UserPayment {
        return UserPayment(
            paymentId: self.paymentId ?? "",
            userId: self.userId ?? "",
            amount: Int(self.amount),
            description: self.paymentDescription,
            paymentMethod: self.paymentMethod,
            paymentGateway: self.paymentGateway,
            paymentStatus: self.paymentStatus,
            externalTransactionId: self.externalId,
            createdAt: self.createdAt
        )
    }
}
