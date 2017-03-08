public struct MockBumpeableProduct: BumpeableProduct {
    public var isBumpeable: Bool
    public var countdown: Int
    public var maxCountdown: Int
    public var totalBumps: Int
    public var bumpsLeft: Int
    public var timeSinceLastBump: Int
    public var paymentItems: [PaymentItem]
}
