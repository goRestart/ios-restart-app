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
    func productDetailOnboardingDidAppear()
    func productDetailOnboardingDidDisappear()
}

class ProductDetailOnboardingView: UIView {

    @IBOutlet weak var fingersView: UIVisualEffectView!
    @IBOutlet weak var tapToGoLabel: UILabel!
    @IBOutlet weak var swipeToGoLabel: UILabel!
    @IBOutlet weak var scrollToSeeLabel: UILabel!

    private var showChatsStep = false

    private let disposeBag = DisposeBag()

    weak var delegate: ProductDetailOnboardingViewDelegate?

    // MARK: - Lifecycle

    open static func instanceFromNibWithState() -> ProductDetailOnboardingView { 
        let view = Bundle.main.loadNibNamed("ProductDetailOnboardingView", owner: self, options: nil)!
            .first as! ProductDetailOnboardingView
        return view
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open func setupUI() {
        setupFingersView()
        setupViewsVisibility()
        setupTapRecognizers()
        setAccessibilityIds()
    }


    // MARK: -Tap actions

    dynamic private func closeView() {
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
        removeFromSuperview()
        delegate?.productDetailOnboardingDidDisappear()
    }


    // MARK: - private methods

    private func setupFingersView() {
        tapToGoLabel.text = LGLocalizedString.productOnboardingFingerTapLabel
        swipeToGoLabel.text = LGLocalizedString.productOnboardingFingerSwipeLabel
        scrollToSeeLabel.text = LGLocalizedString.productOnboardingFingerScrollLabel
    }

    private func setupViewsVisibility() {
        UIApplication.shared.setStatusBarHidden(true, with: .fade)
        fingersView.alpha = 1
        KeyValueStorage.sharedInstance[.didShowProductDetailOnboarding] = true
        delegate?.productDetailOnboardingDidAppear()
    }

    private func setupTapRecognizers() {
        let fingersViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeView))
        fingersView.addGestureRecognizer(fingersViewTapGestureRecognizer)
    }

    private func animateViewTransition() {
        UIView.animate(withDuration: 0.35, animations: { [weak self] in
            self?.setupViewsVisibility()
        }) 
    }

    private func setAccessibilityIds() {
        self.accessibilityId = .ProductDetailOnboarding
    }
}
