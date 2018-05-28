import UIKit
import RxSwift
import LGComponents

class SellNavigationController: UINavigationController {
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewModel: SellNavigationViewModel
    fileprivate let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    fileprivate let backgroundImageView = UIImageView()
    
    let progressView = ProgressView(backgroundColor: UIColor.white.withAlphaComponent(0.7), progressColor: .white)
    let stepLabel = UILabel()
    
    var currentStep: CGFloat {
        return viewModel.actualStep
    }
    
    override init(rootViewController: UIViewController) {
        self.viewModel = SellNavigationViewModel()
        super.init(rootViewController: rootViewController)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.viewModel = SellNavigationViewModel()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        isNavigationBarHidden = true
        setupRx()
        setupUI()
        setupConstraints()
    }
    
    func updateBackground(image: UIImage?) {
        guard let image = image else { return }
        view.addSubviewForAutoLayout(blurEffectView)
        blurEffectView.layout(with: view).fill()
        view.sendSubview(toBack:blurEffectView)

        backgroundImageView.image = image
        view.addSubviewForAutoLayout(backgroundImageView)
        backgroundImageView.layout(with: view).fill()
        view.sendSubview(toBack: backgroundImageView)
        view.layoutIfNeeded()
    }
    
    func removeBackground() {
        blurEffectView.removeFromSuperview()
        backgroundImageView.removeFromSuperview()
    }
    
    func setupInitialCategory(postCategory: PostCategory?) {
        viewModel.hasInitialCategory = postCategory != nil
    }
    
    func startDetails(category: PostCategory?) {
        viewModel.shouldModifyProgress = true
        viewModel.categorySelected.value = category
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        viewModel.navigationControllerPushed()
        updateProgress()
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        viewModel.navigationControllerPop()
        updateProgress()
        return super.popViewController(animated: animated)
    }
    
    private func updateProgress() {
        guard viewModel.numberOfSteps.value > 0 else { return }
        progressView.updateProgress(to: CGFloat(viewModel.currentStep.value/viewModel.numberOfSteps.value), animated: true)
    }
    
    private func animateStep(isHidden: Bool) {
        let alpha: CGFloat = isHidden ? 0.0 : 1.0
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.progressView.alpha = alpha
            self?.stepLabel.alpha = alpha
        })
    }
    
    func setupRx() {
        viewModel.hideProgressHeader.bind { [weak self] isHidden in
                self?.animateStep(isHidden: isHidden)
            }.disposed(by: disposeBag)
        
        viewModel.categorySelected.asObservable().map { category in
            return category?.numberOfSteps ?? 0
        }.bind(to: viewModel.numberOfSteps).disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.currentStep.asObservable(), viewModel.numberOfSteps.asObservable()) { ($0, $1) }
            .bind { [weak self] (currentStep, totalSteps) in
                let current = Int(min(currentStep, totalSteps))
                let totalStep = Int(totalSteps)
                self?.stepLabel.text = R.Strings.realEstateCurrentStepOfTotal(current, totalStep)
            }.disposed(by: disposeBag)
    }
    
    func setupUI() {
        view.addSubview(progressView)
        view.addSubview(stepLabel)
        stepLabel.textColor = UIColor.whiteTextHighAlpha
        stepLabel.textAlignment = .right
    }
    
    func setupConstraints() {
        stepLabel.translatesAutoresizingMaskIntoConstraints = false
        stepLabel.layout(with: view).right(by: -Metrics.margin)
        stepLabel.layout().width(100)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.layout(with: view).right().left()
        progressView.layout().height(5)
        let topAnchor: NSLayoutYAxisAnchor
        if #available(iOS 11, *) {
            topAnchor = view.safeAreaLayoutGuide.topAnchor
        } else {
            topAnchor = view.topAnchor
        }
        progressView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stepLabel.topAnchor.constraint(equalTo: topAnchor, constant: Metrics.margin).isActive = true
    }
}

extension SellNavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ContentViewPushAnimatedTransitioning(operation: operation)
    }
}
