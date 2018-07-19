import Foundation
import LGComponents

enum ReportUpdateType {
    case product(productname: String, username: String)
    case userA(username: String)
    case userB(username: String)
    case userC(username: String)

    var text: String {
        switch self {
        case .product(let productname, let username): return R.Strings.reportingListingUpdateText(productname, username)
        case .userA(let username): return R.Strings.reportingUserUpdateTextA(username)
        case .userB(let username): return R.Strings.reportingUserUpdateTextB(username)
        case .userC(let username): return R.Strings.reportingUserUpdateTextC(username)
        }
    }

    var title: String {
        switch self {
        case .product:
            return R.Strings.reportingListingUpdateTitle
        case .userA, .userB, .userC:
            return R.Strings.reportingUserUpdateTitle
        }
    }
}
