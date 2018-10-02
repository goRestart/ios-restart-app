import RxSwift
import RxCocoa

final class BumpUpContainerViewController: UIViewController {
    private let bumpUpBanner = BumpUpBanner()
    private var isOpen: Bool = false
    private var topConstraint: NSLayoutConstraint?

    private let disposeBag = DisposeBag()
    fileprivate let bumpHeightRelay = BehaviorRelay<CGFloat>(value: 0)

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupBumpUpBanner()
    }

    func resetBumpUpCountdown() {
        bumpUpBanner.resetCountdown()
    }

    private func setupBumpUpBanner() {
        view.addSubviewForAutoLayout(bumpUpBanner)
        let top = bumpUpBanner.topAnchor.constraint(equalTo: view.bottomAnchor)
        [
            bumpUpBanner.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bumpUpBanner.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            top,
            bumpUpBanner.topAnchor.constraint(lessThanOrEqualTo: view.topAnchor)
        ].activate()
        self.topConstraint = top
    }

    func closeBumpUpBanner(animated: Bool) {
        isOpen = false
        if #available(iOS 11.0, *) {
            topConstraint?.constant = -view.safeAreaInsets.bottom
        } else {
            topConstraint?.constant = 0
        }
        bumpHeightRelay.accept(0)
        UIView.animate(withDuration: 0.3) {
            self.bumpUpBanner.alpha = 0
            self.view.layoutIfNeeded()
        }
    }

    private func showBumpUp(animated: Bool) {
        isOpen = true
        topConstraint?.constant = -bumpUpBanner.intrinsicContentSize.height
        bumpHeightRelay.accept(-bumpUpBanner.intrinsicContentSize.height)
        UIView.animate(withDuration: 0.3) {
            self.bumpUpBanner.alpha = 1
            self.view.layoutIfNeeded()
        }
    }

    fileprivate func update(with bumpInfo: BumpUpInfo?) {
        guard let bumpUp = bumpInfo else {
            closeBumpUpBanner(animated: true)
            return
        }

        bumpUpBanner.updateInfo(info: bumpUp)
        // TODO: Check the best way to track this 🤔
//        listingViewModel.bumpUpBannerShown(bumpInfo: bumpUp)
        guard !isOpen else { return }
        showBumpUp(animated: true)
    }
}

extension Reactive where Base: BumpUpContainerViewController {
    var bumpInfo: Binder<BumpUpInfo?> {
        return Binder(self.base) { controller, bumpInfo in
            controller.update(with: bumpInfo)
        }
    }

    var bumpBannerHeight: Driver<CGFloat> {
        return base.bumpHeightRelay.asDriver().skip(1)
    }
}
