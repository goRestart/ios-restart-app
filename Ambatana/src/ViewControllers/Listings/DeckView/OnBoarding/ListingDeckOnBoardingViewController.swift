//
//  ListingDeckOnBoardingViewController.swift
//  LetGo
//
//  Created by Facundo Menzella on 24/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        tapGesture.delaysTouchesBegan = true
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
>>>>>>> ABIOS-listing-deck-view
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
