import Foundation
import LGComponents

protocol ExpressChatNavigator: class {
    func closeExpressChat(_ showAgain: Bool, forProduct: String)
    func sentMessage(_ forProduct: String, count: Int)
}

final class ExpressChatRouter: ExpressChatNavigator {
    private weak var root: UIViewController?

    init(root: UIViewController) {
        self.root = root
    }

    func closeExpressChat(_ showAgain: Bool, forProduct: String) {
        root?.dismiss(animated: true, completion: nil)
    }

    func sentMessage(_ forProduct: String, count: Int) {
        let one = R.Strings.chatExpressOneMessageSentSuccessAlert
        let more = R.Strings.chatExpressSeveralMessagesSentSuccessAlert
        let message = count == 1 ? one : more
        root?.dismiss(animated: true, completion: { [weak root] in
            root?.showAutoFadingOutMessageAlert(message: message)
        })
    }
}
