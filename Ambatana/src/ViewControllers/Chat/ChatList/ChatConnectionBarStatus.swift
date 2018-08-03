import LGComponents

enum ChatConnectionBarStatus {
    case noNetwork
    case wsClosed(reconnectBlock: (() -> Void)?)
    case wsConnecting
    case wsConnected
    
    var title: NSAttributedString? {
        switch self {
        case .noNetwork:
            return NSAttributedString(string: R.Strings.chatStatusViewNoNetwork)
        case .wsClosed:
            let tryAgain = R.Strings.chatStatusViewTryAgain
            let tryAgainAttributes: [NSAttributedStringKey: Any] = [.foregroundColor : UIColor.macaroniAndCheese,
                                                                    .underlineStyle: NSUnderlineStyle.styleSingle.rawValue,
                                                                    .underlineColor: UIColor.macaroniAndCheese]
            let unableToConnectString = R.Strings.chatStatusViewUnableToConnect
            let finalAttributtedString = NSMutableAttributedString(string: unableToConnectString)
            let tryAgainRange = NSString(string: unableToConnectString).range(of: tryAgain)
            finalAttributtedString.setAttributes(tryAgainAttributes, range: tryAgainRange)
            return finalAttributtedString
        case .wsConnecting:
            return NSAttributedString(string: R.Strings.chatStatusViewConnecting)
        case .wsConnected:
            return nil
        }
    }
    
    var showActivityIndicator: Bool {
        switch self {
        case .noNetwork, .wsClosed, .wsConnected:
            return false
        case .wsConnecting:
            return true
        }
    }
    
    var actionBlock: (()->Void)? {
        switch self {
        case .noNetwork, .wsConnecting, .wsConnected:
            return nil
        case .wsClosed(let reconnectBlock):
            return reconnectBlock
        }
    }
    
    var chatUserInteractionsEnabled: Bool {
        switch self {
        case .wsConnected:
            return true
        case .wsClosed, .noNetwork, .wsConnecting:
            return false
        }
    }
}
