//
//  ProductDetailOnboardingView.swift
//  LetGo
//
//  Created by Dídac on 22/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


public enum OnboardingState {
    case Fingers, MoreInfo, HoldQuickAnswers
}

public class ProductDetailOnboardingView: UIView {

    @IBOutlet weak var fingersView: UIVisualEffectView!
    @IBOutlet weak var tapToGoLabel: UILabel!
    @IBOutlet weak var swipeToGoLabel: UILabel!
    @IBOutlet weak var scrollToSeeLabel: UILabel!

    @IBOutlet weak var moreInfoTagView: UIView!
    @IBOutlet weak var moreInfoBubbleView: UIView!
    @IBOutlet weak var moreInfoLabel: UILabel!

    @IBOutlet weak var holdQuickAnswersTagView: UIView!
    @IBOutlet weak var holdQuickAnswersBubbleView: UIView!
    @IBOutlet weak var holdQuickAnswersLabel: UILabel!

    @IBOutlet weak var tapToSwipeConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollToSwipeConstraint: NSLayoutConstraint!

    let statusBarHidden = Variable<Bool>(false)

    private let onboardingState = Variable<OnboardingState>(.Fingers)
    private var productIsMine: Bool = false
    // presentingVC needed to manage the navigation bar
    private var presentingVC: UIViewController = UIViewController()

    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    public static func instanceFromNibWithState(state: OnboardingState, productIsMine: Bool, presentingVC: UIViewController) -> ProductDetailOnboardingView {
        let view = NSBundle.mainBundle().loadNibNamed("ProductDetailOnboardingView", owner: self, options: nil)
            .first as! ProductDetailOnboardingView
        view.onboardingState.value = state
        view.productIsMine = productIsMine
        view.presentingVC = presentingVC
        return view
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public func setupUI() {
        if DeviceFamily.current == .iPhone4 {
            adaptConstraintsToiPhone4()
        }
        setupFingersView()
        setupMoreInfoTagView()
        setupHoldQuickAnswersTagView()
        setupViewsVisibility()
        setupTapRecognizers()
        setupRxBindings()
    }


    // MARK: - RxBindings

    func setupRxBindings() {
        onboardingState.asObservable()
            .map{
                return $0 == .Fingers
            }
            .subscribeNext{ hidden in
                UIApplication.sharedApplication().setStatusBarHidden(hidden, withAnimation: .Fade)
            }.addDisposableTo(disposeBag)

        onboardingState.asObservable().subscribeNext { [weak self] state in
            self?.animateViewTransition()
        }.addDisposableTo(disposeBag)
    }


    // MARK: -Tap actions

    dynamic private func changeToNextState() {
        switch onboardingState.value {
        case .Fingers:
            onboardingState.value = .MoreInfo
        case .MoreInfo:
            onboardingState.value = .HoldQuickAnswers
        case .HoldQuickAnswers:
            break
        }
    }

    dynamic private func closeView() {
        removeFromSuperview()
    }


    // MARK: - private methods

    private func setupFingersView() {
        tapToGoLabel.text = LGLocalizedString.productOnboardingFingerTapLabel
        swipeToGoLabel.text = LGLocalizedString.productOnboardingFingerSwipeLabel
        scrollToSeeLabel.text = LGLocalizedString.productOnboardingFingerScrollLabel
    }

    private func setupMoreInfoTagView() {
        moreInfoLabel.text = LGLocalizedString.productOnboardingMoreInfoLabel
        moreInfoBubbleView.layer.cornerRadius = 10
    }

    private func setupHoldQuickAnswersTagView() {
        holdQuickAnswersLabel.text = LGLocalizedString.productOnboardingQuickAnswersLabel
        holdQuickAnswersBubbleView.layer.cornerRadius = 10
    }

    private func setupViewsVisibility() {
        switch onboardingState.value {
        case .Fingers:
            fingersView.alpha = 1
            moreInfoTagView.alpha = 0
            holdQuickAnswersTagView.alpha = 0
            // nav bar behaves weird when is hidden in mainproducts list and the onboarding is shown
            presentingVC.navigationController?.setNavigationBarHidden(true, animated: false)
        case .MoreInfo:
            fingersView.alpha = 0
            moreInfoTagView.alpha = 1
            holdQuickAnswersTagView.alpha = 0
            UserDefaultsManager.sharedInstance.saveDidShowProductDetailOnboarding()
            // nav bar shown again, but under the onboarding
            presentingVC.navigationController?.setNavigationBarHidden(false, animated: false)
            superview?.bringSubviewToFront(self)
        case .HoldQuickAnswers:
            fingersView.alpha = 0
            moreInfoTagView.alpha = 0
            holdQuickAnswersTagView.alpha = 1
            UserDefaultsManager.sharedInstance.saveDidShowProductDetailOnboardingOthersProduct()
        }
    }

    private func setupTapRecognizers() {
        let fingersViewTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                     action: #selector(ProductDetailOnboardingView.changeToNextState))
        fingersView.addGestureRecognizer(fingersViewTapGestureRecognizer)

        let moreInfoTagSelector: Selector = productIsMine ? #selector(ProductDetailOnboardingView.closeView) :
            #selector(ProductDetailOnboardingView.changeToNextState)
        let moreInfoTagViewTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                         action: moreInfoTagSelector)
        moreInfoTagView.addGestureRecognizer(moreInfoTagViewTapGestureRecognizer)
        let holdQuickAnswersTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                          action: #selector(ProductDetailOnboardingView.closeView))
        holdQuickAnswersTagView.addGestureRecognizer(holdQuickAnswersTapGestureRecognizer)
    }

    private func animateViewTransition() {
        UIView.animateWithDuration(0.35) { [weak self] in
            self?.setupViewsVisibility()
        }
    }

    private func adaptConstraintsToiPhone4() {
        tapToSwipeConstraint.constant = 30
        scrollToSwipeConstraint.constant = 30
    }
}
