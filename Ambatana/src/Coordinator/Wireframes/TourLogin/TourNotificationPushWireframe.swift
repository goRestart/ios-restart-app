final class TourNotificationPushWireframe: TourNotificationsNavigator {
    private let root: UIViewController

    init(root: UIViewController) {
        self.root = root
    }

    func tourNotificationsFinish() {
        // Not needed when presented in the chat
    }
    func showTourLocation() {
        // Not needed when presented in the chat
    }
    func closeTour() {
        root.dismiss(animated: true, completion: nil)
    }
}
