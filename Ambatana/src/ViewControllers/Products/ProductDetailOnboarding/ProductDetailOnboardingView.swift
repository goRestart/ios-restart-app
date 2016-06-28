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

public protocol ProductDetailOnboardingViewDelegate: class {
    func productDetailOnboardingFirstPageDidAppear()
    func productDetailOnboardingFirstPageDidDisappear()
}

public enum OnboardingState {
    case Fingers, MoreInfo
}

public class ProductDetailOnboardingView: UIView {

    @IBOutlet weak var fingersView: UIVisualEffectView!
    @IBOutlet weak var tapToGoLabel: UILabel!
    @IBOutlet weak var swipeToGoLabel: UILabel!
    @IBOutlet weak var scrollToSeeLabel: UILabel!

    @IBOutlet weak var moreInfoTagView: UIView!
    @IBOutlet weak var moreInfoBubbleView: UIView!
    @IBOutlet weak var moreInfoLabel: UILabel!

    @IBOutlet weak var tapToSwipeConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollToSwipeConstraint: NSLayoutConstraint!

    private let onboardingState = Variable<OnboardingState>(.Fingers)
    private var showChatsStep = false

    private let disposeBag = DisposeBag()

    var dismissBlock: (()->Void)?
    weak var delegate: ProductDetailOnboardingViewDelegate?

    // MARK: - Lifecycle

    public static func instanceFromNibWithState(state: OnboardingState, showChatsStep: Bool) -> ProductDetailOnboardingView {
        let view = NSBundle.mainBundle().loadNibNamed("ProductDetailOnboardingView", owner: self, options: nil)
            .first as! ProductDetailOnboardingView
        view.onboardingState.value = state
        view.showChatsStep = showChatsStep
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
        setupViewsVisibility()
        setupTapRecognizers()
        setupRxBindings()
    }


    // MARK: - RxBindings

    func setupRxBindings() {
        onboardingState.asObservable()
            .map{ $0 == .Fingers }
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
            break
        }
    }

    dynamic private func closeView() {
        removeFromSuperview()
        dismissBlock?()
    }


    // MARK: - private methods

    private func setupFingersView() {
        tapToGoLabel.text = LGLocalizedString.productOnboardingFingerTapLabel
        swipeToGoLabel.text = LGLocalizedString.productOnboardingFingerSwipeLabel
        scrollToSeeLabel.text = LGLocalizedString.productOnboardingFingerScrollLabel
    }

    private func setupMoreInfoTagView() {
        moreInfoLabel.text = LGLocalizedString.productOnboardingMoreInfoLabel
        moreInfoBubbleView.layer.cornerRadius = LGUIKitConstants.tooltipCornerRadius
    }

    private func setupViewsVisibility() {
        switch onboardingState.value {
        case .Fingers:
            fingersView.alpha = 1
            moreInfoTagView.alpha = 0
            delegate?.productDetailOnboardingFirstPageDidAppear()
        case .MoreInfo:
            fingersView.alpha = 0
            moreInfoTagView.alpha = 1
            KeyValueStorage.sharedInstance[.didShowProductDetailOnboarding] = true
            delegate?.productDetailOnboardingFirstPageDidDisappear()
        }
    }

    private func setupTapRecognizers() {
        let fingersViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeToNextState))
        fingersView.addGestureRecognizer(fingersViewTapGestureRecognizer)

        let moreInfoTagViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeView))
        moreInfoTagView.addGestureRecognizer(moreInfoTagViewTapGestureRecognizer)
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
