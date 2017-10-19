//
//  PostingDetailsViewController.swift
//  LetGo
//
//  Created by Juan Iglesias on 04/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift

class PostingDetailsViewController : BaseViewController {
    
    fileprivate static let titleHeight: CGFloat = 60
    fileprivate static let skipButtonMinimumWidth: CGFloat = 100
    fileprivate static let skipButtonHeight: CGFloat = 44
    
    private let titleLabel: UILabel = UILabel()
    private let contentView: UIView = UIView()
    private let buttonNext: UIButton = UIButton()
    
    private let viewModel: PostingDetailsViewModel
    
    let disposeBag = DisposeBag()
    
    
    // MARK: - LifeCycle
    
    init(viewModel: PostingDetailsViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // navigationController?.delegate = self
        navigationController?.setNavigationBarHidden(false, animated: false)

        setupConstraints()
        setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarHidden(true)
        setupNavigationBar()
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        view.clipsToBounds = true
        
        titleLabel.text = viewModel.title
        buttonNext.setTitle(LGLocalizedString.postingButtonSkip, for: .normal)
        
        view.backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        titleLabel.font = UIFont.headline
        titleLabel.textColor = UIColor.white
        
        buttonNext.setStyle(.postingFlow)
        buttonNext.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
    }
    
    private func setupNavigationBar() {
        guard let navigationController = navigationController as? SellNavigationController else { return }
        let currentStep = navigationController.currentStep.value
        if currentStep == 1 {
            setNavBarBackgroundStyle(.transparent(substyle: .dark))
            let closeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_post_close") , style: UIBarButtonItemStyle.plain,
                                              target: self, action: #selector(PostingDetailsViewController.closeButtonPressed))
            self.navigationItem.leftBarButtonItem = closeButton
        } else {
            setNavBarBackgroundStyle(.transparent(substyle: .dark))
            let closeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "navbar_back_white_shadow") , style: UIBarButtonItemStyle.plain,
                                              target: self, action: #selector(PostingDetailsViewController.popBackViewController))
            self.navigationItem.leftBarButtonItem = closeButton
        }
        
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        buttonNext.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        titleLabel.layout(with: view).fillHorizontal(by: Metrics.bigMargin)
        titleLabel.layout(with: view).top(by: PostingDetailsViewController.titleHeight)
        
        view.addSubview(contentView)
        contentView.layout(with: titleLabel).below(by: Metrics.bigMargin)
        contentView.layout(with: view).fillHorizontal(by: Metrics.veryShortMargin)
        
        
        let tableView = viewModel.makeContentView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tableView)
        tableView.layout(with: contentView).fill()
        
        view.addSubview(buttonNext)
        buttonNext.layout(with: contentView).below(by: Metrics.bigMargin)
        buttonNext.layout().height(PostingDetailsViewController.skipButtonHeight)
        buttonNext.layout().width(PostingDetailsViewController.skipButtonMinimumWidth, relatedBy: .greaterThanOrEqual)
        buttonNext.layout(with: view).right(by: -Metrics.bigMargin).bottom(by: -Metrics.bigMargin)
    }
    
    
    // MARK: - UIActions
    
    func closeButtonPressed() {
        viewModel.closeButtonPressed()
    }
    
    func nextButtonPressed() {
        viewModel.nextbuttonPressed()
    }
}

extension PostingDetailsViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
           return AlphaPushAnimator()
        } else {
            return AlphaPopAnimator()
        }
    }
}

class AlphaPushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
            else { return }
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else { return }
        let containerView = transitionContext.containerView
        
        containerView.addSubview(toViewController.view)
        containerView.addSubview(fromViewController.view)
        
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        
        fromViewController.view.alpha = 1.0
        toViewController.view.alpha = 0.0
        toViewController.view.frame = CGRect(x: finalFrame.width*2, y: 0, width: finalFrame.width, height: finalFrame.height)
        
        UIView.animate(withDuration: 0.5, animations: {
            fromViewController.view.alpha = 0.0
            toViewController.view.alpha = 1.0
            fromViewController.view.frame = CGRect(x: -fromViewController.view.frame.width, y: 0, width: fromViewController.view.frame.width, height: fromViewController.view.frame.height)
            toViewController.view.frame = finalFrame
        }, completion: { finished in
            let cancelled = transitionContext.transitionWasCancelled
            fromViewController.view.alpha = 1.0
            transitionContext.completeTransition(!cancelled)
        })
    }
}

class AlphaPopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
            else {
                return }
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else {
                return }
        let containerView = transitionContext.containerView
        
        containerView.addSubview(toViewController.view)
        containerView.addSubview(fromViewController.view)
        
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        
        fromViewController.view.alpha = 1.0
        toViewController.view.alpha = 0.0
        toViewController.view.frame = CGRect(x: -finalFrame.width*2, y: 0, width: finalFrame.width, height: finalFrame.height)
        
        UIView.animate(withDuration: 0.5, animations: {
            fromViewController.view.alpha = 0.0
            toViewController.view.alpha = 1.0
            fromViewController.view.frame = CGRect(x: fromViewController.view.frame.width, y: 0, width: fromViewController.view.frame.width, height: fromViewController.view.frame.height)
            toViewController.view.frame = finalFrame
        }, completion: { finished in
            let cancelled = transitionContext.transitionWasCancelled
            fromViewController.view.alpha = 1.0
            transitionContext.completeTransition(!cancelled)
        })
    }
}

