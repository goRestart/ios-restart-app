import Foundation
import LGComponents

enum ErrorCode: Int {
    case imageDownloadFailed
}

extension NSError {
    convenience init(code: ErrorCode) {
        self.init(domain: SharedConstants.appDomain, code: code.rawValue, userInfo: nil)
    }
}
