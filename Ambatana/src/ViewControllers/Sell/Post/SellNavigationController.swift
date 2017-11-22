//
//  SellNavigationController.swift
//  LetGo
//
//  Created by Juan Iglesias on 03/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//


import UIKit
import RxSwift


class SellNavigationController: UINavigationController {
    
    static let progressViewHeight: CGFloat = 5
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewModel: SellNavigationViewModel
    
    let progressView = UIView()
    let backgroundProgressView = UIView()
    
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
    }
    
    func updateBackground(image: UIImage?) {
        guard let image = image else { return }
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurEffectView)
        blurEffectView.layout(with: view).fill()
        view.sendSubview(toBack:blurEffectView)
        
        let background = UIImageView()
        background.image = image
        background.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(background)
        background.layout(with: view).fill()
        view.sendSubview(toBack:background)
    }
    
    func startDetails(category: PostCategory?) {
        viewModel.shouldModifyProgress = true
        viewModel.categorySelected.value = category
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        viewModel.navigationControllerPushed()
        let witdh = viewModel.widthToFill(totalWidth: view.width)
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.progressView.frame = CGRect(x: 0, y: 0, width: witdh, height: SellNavigationController.progressViewHeight)
            strongSelf.progressView.layoutIfNeeded()
        }
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        viewModel.navigationControllerPop()
            let witdh = viewModel.widthToFill(totalWidth: view.width)
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.progressView.frame = CGRect(x: 0, y: 0, width: witdh, height: SellNavigationController.progressViewHeight)
                strongSelf.progressView.layoutIfNeeded()
            }
        return super.popViewController(animated: animated)
    }
    
    func setupRx() {
        viewModel.currentStep.asObservable().map { $0 == 0 }.bindTo(progressView.rx.isHidden).addDisposableTo(disposeBag)
        viewModel.currentStep.asObservable().map { $0 == 0 }.bindTo(backgroundProgressView.rx.isHidden).addDisposableTo(disposeBag)
        viewModel.categorySelected.asObservable().map { [weak self] category in
                guard let strongSelf = self else { return nil }
                return category?.numberOfSteps(shouldShowPrice: strongSelf.viewModel.shouldShowPriceStep)
            }.bindNext { [weak self] number in
                self?.viewModel.numberOfSteps.value = number ?? 0
            }.addDisposableTo(disposeBag)
    }
    
    func setupUI() {
        progressView.backgroundColor = UIColor.white
        backgroundProgressView.backgroundColor = UIColor(white: 0, alpha: 0.20)
        let witdh = viewModel.widthToFill(totalWidth: view.width)
        progressView.frame = CGRect(x: 0, y: 0, width: witdh, height: SellNavigationController.progressViewHeight)
        view.addSubview(progressView)
        backgroundProgressView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: SellNavigationController.progressViewHeight)
        view.addSubview(backgroundProgressView)
        view.sendSubview(toBack: backgroundProgressView)
    }
}

extension SellNavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ContentViewPushAnimatedTransitioning(operation: operation)
    }
}
