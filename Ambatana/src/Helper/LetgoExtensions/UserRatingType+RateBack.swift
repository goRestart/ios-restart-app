import LGCoreKit

extension UserRatingType {
    
    var rateBackType: UserRatingType {
        get {
            switch self {
            case .conversation, .report: return .conversation
            case .seller: return .buyer
            case .buyer: return .seller
            case .report: return .report
            }
        }
    }
}
