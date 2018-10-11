@testable import LGCoreKit

extension LGRewardPoints: Randomizable {
    
    public static func makeRandom() -> LGRewardPoints {
        return LGRewardPoints(points: Int.makeRandom())
    }
}

extension LGReward: MockFactory, Randomizable {
    
    public static func makeMock() -> LGReward {
        return self.makeRandom()
    }
    
    public static func makeRandom() -> LGReward {
        return LGReward(id: String.makeRandom(), type: RewardType.makeRandom(), points: Int.makeRandom())
    }
}

extension RewardType: Randomizable {
    
    public static func makeRandom() -> RewardType {
        let array: [RewardType] = RewardType.allValues
        return array[Int.makeRandom(min: 0, max: array.count - 1)]
    }
}

extension LGVoucher: MockFactory, Randomizable {
    
    public static func makeMock() -> LGVoucher {
        return self.makeRandom()
    }
    
    public static func makeRandom() -> LGVoucher {
        return LGVoucher(
            id: String.makeRandom(),
            createdAt: Date.makeRandom(),
            countryCode: String.makeRandom(),
            type: VoucherType.makeRandom(),
            points: Int.makeRandom(),
            itemId: String.makeRandom())
    }
}
