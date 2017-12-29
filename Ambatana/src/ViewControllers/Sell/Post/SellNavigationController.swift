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
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewModel: SellNavigationViewModel
    
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
        view.layoutIfNeeded()
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
        viewModel.currentStep.asObservable().map { [weak self] currentStep -> Bool in
            guard let totalSteps = self?.viewModel.numberOfSteps.value else { return false }
            return currentStep == 0 || currentStep > totalSteps
            }.bind { [weak self] isHidden in
                self?.animateStep(isHidden: isHidden)
            }.disposed(by: disposeBag)
        
        viewModel.categorySelected.asObservable().map { [weak self] category in
                guard let strongSelf = self else { return nil }
                return category?.numberOfSteps(shouldShowPrice: strongSelf.viewModel.shouldShowPriceStep)
            }.bind { [weak self] number in
                self?.viewModel.numberOfSteps.value = number ?? 0
            }.disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.currentStep.asObservable(), viewModel.numberOfSteps.asObservable()) { ($0, $1) }
            .bind { [weak self] (currentStep, totalSteps) in
                let current = Int(min(currentStep, totalSteps))
                let totalStep = Int(totalSteps)
                self?.stepLabel.text = LGLocalizedString.realEstateCurrentStepOfTotal(current, totalStep)
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
