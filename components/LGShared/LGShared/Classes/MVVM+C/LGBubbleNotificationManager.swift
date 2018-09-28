import Foundation
import RxSwift
import LGComponents

final public class LGBubbleNotificationManager: BubbleNotificationManager {

    public static let defaultDuration: TimeInterval = 3

    public static let sharedInstance: LGBubbleNotificationManager = LGBubbleNotificationManager()

    private var taggedNotifications: [String : [BubbleNotificationView]] = [:]
  
    public let bottomNotifications = Variable<[BubbleNotificationView]>([])
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

    public func showBubble(data: BubbleNotificationData,
                    duration: TimeInterval,
                    view: UIView,
                    alignment: BubbleNotificationView.Alignment,
                    style: BubbleNotificationView.Style) {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: BubbleNotificationView.initialHeight)
        let bubble = BubbleNotificationView(frame: frame, data: data, alignment: alignment, style: style)
        bubble.delegate = self
        
        view.addSubviewForAutoLayout(bubble)
        bubble.setupOnView(parentView: view)
        
        if let tag = data.tagGroup {
            if taggedNotifications[tag] == nil {
                taggedNotifications[tag] = []
            }
            taggedNotifications[tag]?.append(bubble)
        }

        let finalDuration = (data.action == nil && duration <= 0) ? LGBubbleNotificationManager.defaultDuration : duration
        bubble.showBubble(autoDismissTime: finalDuration)
        
        if bubble.isBottomAligned {
            bottomNotifications.value.append(bubble)
        }
    }
    
    public func hideBottomBubbleNotifications() {
        bottomNotifications.value.forEach {
            closeBubbleNotification($0)
        }
    }
    
    private func clearTagNotifications(_ tag: String?) {
        guard let tag = tag, let notifications = taggedNotifications[tag] else { return }
        taggedNotifications[tag] = nil
        notifications.forEach{ $0.closeBubble() }
    }
    
    private func closeBubbleNotification(_ bubbleNotification: BubbleNotificationView) {
        if bubbleNotification.isBottomAligned {
            guard let index = bottomNotifications.value.index(of: bubbleNotification) else { return }
            bottomNotifications.value.remove(at: index)
        }
        bubbleNotification.closeBubble()
    }
}


// MARK: - BubbleNotificationDelegate

extension LGBubbleNotificationManager: BubbleNotificationDelegate {

    public func bubbleNotificationSwiped(_ notification: BubbleNotificationView) {
        closeBubbleNotification(notification)
    }

    public func bubbleNotificationTimedOut(_ notification: BubbleNotificationView) {
        closeBubbleNotification(notification)
    }

    public func bubbleNotificationActionPressed(_ notification: BubbleNotificationView) {
        notification.data.action?.action()
        closeBubbleNotification(notification)
        clearTagNotifications(notification.data.tagGroup)
    }
}
