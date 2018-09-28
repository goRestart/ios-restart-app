import Foundation

public protocol Voucher {
    var id: String { get }
    var itemId: String { get }
    var type: VoucherType { get }
    var points: Int { get }
    var createdAt: Date { get }
    var countryCode: String { get }
}

public typealias VoucherType = RewardType
