@testable import LetGoGodMode
import RxSwift
import LGComponents

final class MockBubbleNotificationManager: BubbleNotificationManager {
    let bottomNotifications = Variable<[BubbleNotificationView]>([])
    
    var lastShownData: BubbleNotificationData?
    var lastDuration: TimeInterval?

    func showBubble(data: BubbleNotificationData,
                    duration: TimeInterval,
                    view: UIView,
                    alignment: BubbleNotificationView.Alignment,
                    style: BubbleNotificationView.Style) {
        lastShownData = data
        lastDuration = duration
    }
    
    func hideBottomBubbleNotifications() { }
}
