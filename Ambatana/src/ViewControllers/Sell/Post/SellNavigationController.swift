import UIKit
import RxSwift
import LGComponents

final class SellNavigationController: UINavigationController {
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewModel: SellNavigationViewModel = SellNavigationViewModel()
    fileprivate let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    fileprivate let backgroundImageView = UIImageView()

    init(root: UIViewController) { // we do this because a leak https://lists.swift.org/pipermail/swift-users/Week-of-Mon-20171211/006747.html
        super.init(nibName: nil, bundle: nil)
        viewControllers.append(root)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        isNavigationBarHidden = true
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
        viewModel.categorySelected.value = category
    }
}

extension SellNavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ContentViewPushAnimatedTransitioning(operation: operation)
    }
}
