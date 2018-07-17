import UIKit
import RxSwift

public protocol BubbleNotificationManager {
    var bottomNotifications: Variable<[BubbleNotificationView]> { get }
    
    func showBubble(data: BubbleNotificationData,
                    duration: TimeInterval,
                    view: UIView,
                    alignment: BubbleNotificationView.Alignment,
                    style: BubbleNotificationView.Style)
    func hideBottomBubbleNotifications()
}
