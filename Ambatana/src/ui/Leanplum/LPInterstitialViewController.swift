import Foundation
import LGComponents

enum LPMessageType {
    case centerPopup
    case interstitial

    var view: LPMessageView & UIView {
        switch self {
        case .centerPopup: return LPCenterPopupView()
        case .interstitial: return LPInterstitialView()
        }
    }
}

protocol LPMessageView {
    var dismissControl: UIControl? { get }
    var closeControl: UIControl? { get }
    var actionControl: UIControl? { get }

    func setupWith(image: UIImage, headline: String, subHeadline: String, action: String)
}

final class LPMessageViewController: BaseViewController {

    private let type: LPMessageType
    private let lpView: LPMessageView & UIView
    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Die xibs, die")
    }

    init(type: LPMessageType) {
        self.type = type
        self.lpView = type.view
        super.init(viewModel: nil, nibName: nil)

        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overCurrentContext
    }

    override func loadView() {
        guard type == .interstitial else {
            self.view = lpView
            return
        }
        super.loadView()
        view.addSubviewForAutoLayout(lpView)
        NSLayoutConstraint.activate([
            lpView.topAnchor.constraint(equalTo: safeTopAnchor),
            lpView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lpView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            lpView.bottomAnchor.constraint(equalTo: safeBottomAnchor)
            ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = lpView.backgroundColor
    }

}
