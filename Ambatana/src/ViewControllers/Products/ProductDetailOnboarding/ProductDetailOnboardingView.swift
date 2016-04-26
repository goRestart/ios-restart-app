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

enum OnboardingState {
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

    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    public static func instanceFromNib() -> ProductDetailOnboardingView {
        let view = NSBundle.mainBundle().loadNibNamed("ProductDetailOnboardingView", owner: self, options: nil)
            .first as! ProductDetailOnboardingView
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

        tapToGoLabel.text = LGLocalizedString.productOnboardingFingerTapLabel
        swipeToGoLabel.text = LGLocalizedString.productOnboardingFingerSwipeLabel
        scrollToSeeLabel.text = LGLocalizedString.productOnboardingFingerScrollLabel

        moreInfoLabel.text = LGLocalizedString.productOnboardingMoreInfoLabel
        holdQuickAnswersLabel.text = LGLocalizedString.productOnboardingQuickAnswersLabel

        moreInfoBubbleView.layer.cornerRadius = 10
        holdQuickAnswersBubbleView.layer.cornerRadius = 10

        fingersView.alpha = 1
        moreInfoTagView.alpha = 0
        holdQuickAnswersTagView.alpha = 0

        let fingersViewTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(ProductDetailOnboardingView.changeToNextState))
        fingersView.addGestureRecognizer(fingersViewTapGestureRecognizer)
        let moreInfoTagViewTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                     action: #selector(ProductDetailOnboardingView.changeToNextState))
        moreInfoTagView.addGestureRecognizer(moreInfoTagViewTapGestureRecognizer)

        let holdQuickAnswersTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                          action: #selector(ProductDetailOnboardingView.closeView))
        holdQuickAnswersTagView.addGestureRecognizer(holdQuickAnswersTapGestureRecognizer)

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
            switch state {
            case .Fingers:
                self?.showFingersView()
            case .MoreInfo:
                self?.showMoreInfoTagView()
            case .HoldQuickAnswers:
                self?.showHoldQuickAnswersTagView()
            }
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

    private func showFingersView() {
        UIView.animateWithDuration(0.35) { [weak self] in
            self?.fingersView.alpha = 1
            self?.moreInfoTagView.alpha = 0
            self?.holdQuickAnswersTagView.alpha = 0
        }
    }

    private func showMoreInfoTagView() {
        UIView.animateWithDuration(0.35) { [weak self] in
            self?.fingersView.alpha = 0
            self?.moreInfoTagView.alpha = 1
            self?.holdQuickAnswersTagView.alpha = 0
        }
    }

    private func showHoldQuickAnswersTagView() {
        UIView.animateWithDuration(0.35) { [weak self] in
            self?.fingersView.alpha = 0
            self?.moreInfoTagView.alpha = 0
            self?.holdQuickAnswersTagView.alpha = 1
        }
    }

    private func adaptConstraintsToiPhone4() {
        tapToSwipeConstraint.constant = 30
        scrollToSwipeConstraint.constant = 30
    }
}
