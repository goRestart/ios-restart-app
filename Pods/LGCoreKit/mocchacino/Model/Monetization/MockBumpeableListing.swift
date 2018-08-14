public struct MockBumpeableListing: BumpeableListing {
    public var isBumpeable: Bool
    public var countdown: TimeInterval
    public var maxCountdown: TimeInterval
    public var totalBumps: Int
    public var bumpsLeft: Int
    public var timeSinceLastBump: TimeInterval
    public var paymentItems: [PaymentItem]
}
