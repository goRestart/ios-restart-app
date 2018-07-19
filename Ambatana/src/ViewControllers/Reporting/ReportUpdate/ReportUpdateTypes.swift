import Foundation
import LGComponents

enum ReportUpdateType {
    case product(productname: String, username: String)
    case userA(username: String)
    case userB(username: String)
    case userC(username: String)

    var title: String {
        switch self {
        case .product:
            return R.Strings.reportingListingUpdateTitle
        case .userA, .userB, .userC:
            return R.Strings.reportingUserUpdateTitle
        }
    }

    var attributedText: NSAttributedString {
        switch self {
        case .product(let productname, let username):
            return makeAttributedString(string: self.text, with: [productname, username])
        case .userA(let username):
            return makeAttributedString(string: self.text, with: [username])
        case .userB(let username):
            return makeAttributedString(string: self.text, with: [username])
        case .userC(let username):
            return makeAttributedString(string: self.text, with: [username])
        }
    }

    private var text: String {
        switch self {
        case .product(let productname, let username): return R.Strings.reportingListingUpdateText(productname, username)
        case .userA(let username): return R.Strings.reportingUserUpdateTextA(username)
        case .userB(let username): return R.Strings.reportingUserUpdateTextB(username)
        case .userC(let username): return R.Strings.reportingUserUpdateTextC(username)
        }
    }

    private func makeAttributedString(string: String, with boldStrings: [String]) -> NSAttributedString {
        let attrString = NSMutableAttributedString(string: string,
                                               attributes: [.foregroundColor: UIColor.lgBlack,
                                                            .font: UIFont.bigBodyFont])
        for boldString in boldStrings {
            let boldStringRange = (string as NSString).range(of: boldString)
            attrString.addAttributes([.font: UIFont.reportSentUserNameText], range: boldStringRange)
        }
        return attrString
    }
}
