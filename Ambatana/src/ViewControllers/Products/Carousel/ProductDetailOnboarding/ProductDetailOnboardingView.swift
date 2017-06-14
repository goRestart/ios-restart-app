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

protocol ProductDetailOnboardingViewDelegate: class {
    func productDetailOnboardingDidAppear()
    func productDetailOnboardingDidDisappear()
}

class ProductDetailOnboardingView: BaseView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var fingersView: UIVisualEffectView!
    @IBOutlet weak var newLabel: UILabel!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var firstImage: UIImageView!
    @IBOutlet weak var secondImage: UIImageView!
    @IBOutlet weak var thirdImage: UIImageView!

    private var viewModel: ProductDetailOnboardingViewModel

    private var showChatsStep = false

    private let disposeBag = DisposeBag()

    weak var delegate: ProductDetailOnboardingViewDelegate?


    // MARK: - Lifecycle

    init(viewModel: ProductDetailOnboardingViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        Bundle.main.loadNibNamed("ProductDetailOnboardingView", owner: self, options: nil)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.backgroundColor = UIColor.listBackgroundColor
        addSubview(contentView)

        newLabel.text = viewModel.newText

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
        firstLabel.attributedText = viewModel.firstText
        secondLabel.attributedText = viewModel.secondText
        thirdLabel.attributedText = viewModel.thirdText
    }

    private func setupViewsVisibility() {
        UIApplication.shared.setStatusBarHidden(true, with: .fade)
        fingersView.alpha = 1
        KeyValueStorage.sharedInstance[.didShowProductDetailOnboarding] = true // 🦄 use view model and add didShowHorizontalProductDetailOnboarding
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
        self.accessibilityId = .productDetailOnboarding
    }
}
