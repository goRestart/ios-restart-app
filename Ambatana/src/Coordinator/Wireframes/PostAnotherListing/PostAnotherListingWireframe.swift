import LGCoreKit
import LGComponents

protocol PostAnotherListingNavigator: class {
    func cancelPost()
    func postAnotherListing()
}

final class PostAnotherListingWireframe: PostAnotherListingNavigator {
    private let root: UIViewController
    private let deepLinkMailBox: DeepLinkMailBox

    convenience init(root: UIViewController) {
        self.init(root: root, deepLinkMailBox: LGDeepLinkMailBox.sharedInstance)
    }

    init(root: UIViewController, deepLinkMailBox: DeepLinkMailBox) {
        self.root = root
        self.deepLinkMailBox = deepLinkMailBox
    }

    func cancelPost() {
        root.dismiss(animated: true, completion: nil)
    }

    func postAnotherListing() {
        root.dismiss(animated: true) { [weak self] in
            guard let url = URL.makeSellDeeplink(with: .markAsSold, category: nil, title: nil) else { return }
            self?.deepLinkMailBox.push(convertible: url)
        }
    }
}
