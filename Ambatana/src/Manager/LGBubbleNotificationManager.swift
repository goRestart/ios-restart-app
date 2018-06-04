import Foundation
import RxSwift

final class LGBubbleNotificationManager: BubbleNotificationManager {

    static let defaultDuration: TimeInterval = 3

    static let sharedInstance: LGBubbleNotificationManager = LGBubbleNotificationManager()

    private var taggedNotifications: [String : [BubbleNotificationView]] = [:]
  
    var bottomNotifications = Variable<[BubbleNotificationView]>([])
    private let disposeBag = DisposeBag()
    
    
    // Showing Methods

    /**
     Adds bubble to the view and shows it
     
     - text: text of the notification
     - action: the action associated with the notification button
     - duration: for how long the notification should be shown
        . no duration: default duration
        . duration <= 0 : notification stays there until the user interacts with it.
     */

    func showBubble(data: BubbleNotificationData,
                    duration: TimeInterval,
                    view: UIView,
                    alignment: BubbleNotificationView.Alignment,
                    style: BubbleNotificationView.Style) {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: BubbleNotificationView.initialHeight)
        let bubble = BubbleNotificationView(frame: frame, data: data, alignment: alignment, style: style)
        bubble.delegate = self
        
        bubble.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bubble)
        bubble.setupOnView(parentView: view)
        
        if let tag = data.tagGroup {
            if taggedNotifications[tag] == nil {
                taggedNotifications[tag] = []
            }
            taggedNotifications[tag]?.append(bubble)
        }

        bubble.showBubble(autoDismissTime: LGBubbleNotificationManager.defaultDuration)

        let finalDuration = (data.action == nil && duration <= 0) ? LGBubbleNotificationManager.defaultDuration : duration
        bubble.showBubble(autoDismissTime: finalDuration)
        
        if alignment == .bottom {
            bottomNotifications.value.append(bubble)
        }
    }
    
    func hideBottomBubbleNotifications() {
        bottomNotifications.value.forEach {
            guard let index = bottomNotifications.value.index(of: $0) else { return }
            bottomNotifications.value.remove(at: index)
            $0.closeBubble()
        }
    }
    
    fileprivate func clearTagNotifications(_ tag: String?) {
        guard let tag = tag, let notifications = taggedNotifications[tag] else { return }
        taggedNotifications[tag] = nil
        notifications.forEach{ $0.closeBubble() }
    }
}


// MARK: - BubbleNotificationDelegate

extension LGBubbleNotificationManager: BubbleNotificationDelegate {

    func bubbleNotificationSwiped(_ notification: BubbleNotificationView) {
        notification.closeBubble()
    }

    func bubbleNotificationTimedOut(_ notification: BubbleNotificationView) {
        notification.closeBubble()
    }

    func bubbleNotificationActionPressed(_ notification: BubbleNotificationView) {
        notification.data.action?.action()
        notification.closeBubble()
        clearTagNotifications(notification.data.tagGroup)
    }
}
