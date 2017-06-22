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
        newLabel.isHidden = viewModel.newLabelIsHidden

        setupFingersView()
        setupViewsVisibility()
        setupTapRecognizers()
        setAccessibilityIds()
        active = true
    }


    // MARK: - Tap actions

    dynamic private func closeView() {
        active = false
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
        removeFromSuperview()
        viewModel.close()
    }


    // MARK: - private methods

    private func setupFingersView() {
        firstImage.image = viewModel.firstImage
        firstLabel.attributedText = viewModel.firstText
        secondImage.image = viewModel.secondImage
        secondLabel.attributedText = viewModel.secondText
        thirdImage.image = viewModel.thirdImage
        thirdLabel.attributedText = viewModel.thirdText
    }

    private func setupViewsVisibility() {
        UIApplication.shared.setStatusBarHidden(true, with: .fade)
        fingersView.alpha = 1
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
