import Foundation
import LGCoreKit
import LGComponents

class ChatStickerCellDrawer: BaseChatCellDrawer<ChatStickerCell> {

    let messageIsMine: Bool

    init(messageIsMine: Bool, autoHide: Bool) {
        self.messageIsMine = messageIsMine

        super.init(autoHide: autoHide)
    }
    
    override func draw(_ cell: ChatStickerCell, message: ChatViewMessage) {
        guard let url = URL(string: message.value) else { return }
        if messageIsMine {
            cell.rightImage.lg_setImageWithURL(url, placeholderImage: nil) { (result, url) in
                if let _ = result.error {
                    cell.rightImage.image = R.Asset.BackgroundsAndImages.stickerError.image
                }
            }
            
            cell.leftImage.image = nil
        } else {
            cell.leftImage.lg_setImageWithURL(url, placeholderImage: nil) { (result, url) in
                if let _ = result.error {
                    cell.leftImage.image = R.Asset.BackgroundsAndImages.stickerError.image
                }
            }
            cell.rightImage.image = nil
        }
    }
}
