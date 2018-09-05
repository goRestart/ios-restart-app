import Foundation

final class ChatOtherInfoCellDrawer: BaseChatCellDrawer<ChatOtherInfoCell> {

    override init(autoHide: Bool) {
        super.init(autoHide: autoHide)
    }

    override func draw(_ cell: ChatOtherInfoCell, message: ChatViewMessage, bubbleColor: UIColor? = nil) {
        switch message.type {
        case let .userInfo(userInfo):
            cell.set(name: userInfo.name)
            cell.set(rating: userInfo.rating)
            cell.set(bubbleBackgroundColor: bubbleColor)
            if userInfo.isDummy {
                cell.setupLetgoAssistantInfo()
            } else {
                cell.setupLocation(userInfo.address)
                cell.setupVerifiedInfo(
                    facebook: userInfo.isFacebookVerified,
                    google: userInfo.isGoogleVerified,
                    email: userInfo.isEmailVerified
                )
            }
        default:
            break
        }
    }
}
