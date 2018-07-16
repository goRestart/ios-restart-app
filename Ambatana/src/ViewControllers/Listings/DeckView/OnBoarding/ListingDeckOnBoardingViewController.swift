import Foundation
import LGComponents

protocol ListingDeckOnBoardingViewModelType: class {
    func close()
}

protocol ListingDeckOnBoardingViewControllerType: class {
    func close()
}

final class ListingDeckOnBoardingViewController: BaseViewController, ListingDeckOnBoardingViewControllerType, UIViewControllerTransitioningDelegate {

    private let onboardingView = ListingDeckOnBoardingView()
    private let viewModel: ListingDeckOnBoardingViewModelType
    private let binder = ListingDeckOnBoardingBinder()

    private var animator: OnBoardingAnimator?

    override func loadView() {
        self.view = onboardingView
    }

    init<T>(viewModel: T, animator: OnBoardingAnimator) where T: ListingDeckOnBoardingViewModelType, T: BaseViewModel {
        self.viewModel = viewModel
        self.animator = animator
        super.init(viewModel: viewModel, nibName: nil)
        self.transitioningDelegate = self
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()

        onboardingView.backgroundColor = UIColor.darkBarBackground
        binder.viewController = self
        binder.bind(withView: onboardingView)

        onboardingView.backgroundColor = UIColor.darkBarBackground

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        onboardingView.addGestureRecognizer(tapGesture)
    }

    func prepareForPresentation() {
        onboardingView.setVisualEffectAlpha(0)
        onboardingView.compressContentView()
    }

    func finishPresentation() {
        onboardingView.setVisualEffectAlpha(0.7)
        onboardingView.expandContainerView()
    }

    func prepareForDismissal() {
        finishPresentation()
    }

    func finishDismiss() {
        onboardingView.setVisualEffectAlpha(0)
        onboardingView.compressContentView()
    }

    func close() {
        didTapView()
    }

    @objc private func didTapView() {
        viewModel.close()
    }

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animator
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator?.presenting = false
        return animator
    }
}
