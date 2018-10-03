import RxSwift
import RxCocoa

final class BumpUpContainerViewController: UIViewController {
    private enum Layout {
        static let bannerHeight: CGFloat = 64
    }
    private let bumpUpBanner = BumpUpBanner()
    private var bannerHeight: NSLayoutConstraint?

    private var isOpen: Bool = false
    private var topConstraint: NSLayoutConstraint?

    weak var bumpDelegate: BumpUpBannerBoostDelegate?

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
        let height = bumpUpBanner.heightAnchor.constraint(equalToConstant: Layout.bannerHeight)
        let top = bumpUpBanner.topAnchor.constraint(equalTo: view.bottomAnchor)
        [
            height,
            top,
            bumpUpBanner.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bumpUpBanner.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bumpUpBanner.topAnchor.constraint(lessThanOrEqualTo: view.topAnchor),
            view.heightAnchor.constraint(equalTo: bumpUpBanner.heightAnchor)
        ].activate()
        self.bannerHeight = height
        self.topConstraint = top

        bumpUpBanner.delegate = self
    }

    func closeBumpUpBanner(animated: Bool) {
        isOpen = false
        if #available(iOS 11.0, *) {
            topConstraint?.constant = -view.safeAreaInsets.bottom
        } else {
            topConstraint?.constant = 0
        }
        bumpHeightRelay.accept(0)
        UIView.animate(withDuration: animated ? 0.3 : 0) {
            self.bumpUpBanner.alpha = 0
            self.view.layoutIfNeeded()
        }
    }

    private func showBumpUp(animated: Bool) {
        let height = bumpUpBanner.type.height
        defer { bumpHeightRelay.accept(height) }
        guard !isOpen else { return }
        isOpen = true
        topConstraint?.constant = -height
        UIView.animate(withDuration: animated ? 0.3 : 0) {
            self.bumpUpBanner.alpha = 1
            self.view.layoutIfNeeded()
        }
    }

    fileprivate func update(with bumpInfo: BumpUpInfo?) {
        guard let bumpUp = bumpInfo else {
            closeBumpUpBanner(animated: false)
            return
        }
        if bumpUpBanner.type != bumpUp.type {
            updateBannerHeightFor(type: bumpUp.type)
        }
        bumpUpBanner.updateInfo(info: bumpUp)
        // TODO: Check the best way to track this 🤔
//        listingViewModel.bumpUpBannerShown(bumpInfo: bumpUp)
        showBumpUp(animated: true)
    }

    private func updateBannerHeightFor(type: BumpUpType) {
        bannerHeight?.constant = type.height
        UIView.animate(withDuration: 0.3,
                       animations: {
                        self.view.layoutIfNeeded()
        })
    }
}

extension BumpUpContainerViewController: BumpUpBannerBoostDelegate {
    func bumpUpTimerReachedZero() {
        closeBumpUpBanner(animated: true)
        bumpDelegate?.bumpUpTimerReachedZero()
    }

    func updateBoostBannerFor(type: BumpUpType) {
        updateBannerHeightFor(type: type)
    }
}

extension Reactive where Base: BumpUpContainerViewController {
    var bumpInfo: Binder<BumpUpInfo?> {
        return Binder(self.base) { controller, bumpInfo in
            controller.update(with: bumpInfo)
        }
    }

    var bumpBannerHeight: Driver<CGFloat> {
        return base.bumpHeightRelay.asDriver()
    }
}
