//
//  ProductPostedViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 14/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

class ProductPostedViewController: BaseViewController, SellProductViewController, ProductPostedViewModelDelegate {

    weak var delegate: SellProductViewControllerDelegate?

    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var mainIconImage: UIImageView!
    @IBOutlet weak var loadingIndicator: LoadingIndicator!
    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var secondaryTextLabel: UILabel!

    // Edit Container
    @IBOutlet weak var editContainer: UIView!
    @IBOutlet weak var editContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var editOrLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var mainButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var mainButton: UIButton!


    private static let contentContainerShownHeight: CGFloat = 80
    private var viewModel: ProductPostedViewModel!


    // MARK: - View lifecycle

    convenience init(viewModel: ProductPostedViewModel) {
        self.init(viewModel: viewModel, nibName: "ProductPostedViewController")
    }

    required init(viewModel: ProductPostedViewModel, nibName nibNameOrNil: String?) {
        super.init(viewModel: viewModel, nibName: nibNameOrNil,
                   statusBarStyle: UIApplication.sharedApplication().statusBarStyle)
        self.viewModel = viewModel
        viewModel.delegate = self
        modalPresentationStyle = .OverCurrentContext
        modalTransitionStyle = .CrossDissolve
        setReachabilityEnabled(false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    

    // MARK: - IBActions

    @IBAction func onCloseButton(sender: AnyObject) {
        viewModel.closeActionPressed()
    }

    @IBAction func onMainButton(sender: AnyObject) {
        viewModel.mainActionPressed()
    }

    @IBAction func onSharebutton(sender: AnyObject) {
        shareButtonPressed()
    }
    
    @IBAction func onEditButton(sender: AnyObject) {
        viewModel.editActionPressed()
    }


    // MARK: - ProductPostedViewModelDelegate

    func productPostedViewModelSetupLoadingState(viewModel: ProductPostedViewModel) {
        setupLoading()
    }

    func productPostedViewModel(viewModel: ProductPostedViewModel, finishedLoadingState correct: Bool) {
        finishedLoading(correct)
    }

    func productPostedViewModel(viewModel: ProductPostedViewModel, setupStaticState correct: Bool) {
        setupStatic(correct)
    }

    func productPostedViewModelDidFinishPosting(viewModel: ProductPostedViewModel, correctly: Bool) {
        dismissViewControllerAnimated(true) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.sellProductViewController(strongSelf, didCompleteSell: correctly,
                withPromoteProductViewModel: viewModel.promoteProductViewModel)
        }
    }

    func productPostedViewModelDidEditPosting(viewModel: ProductPostedViewModel,
        editViewModel: EditProductViewModel) {
            dismissViewControllerAnimated(true) { [weak self] in
                guard let strongSelf = self else { return }

                let editVC = EditProductViewController(viewModel: editViewModel, updateDelegate: nil)
                editVC.sellDelegate = self?.delegate

                strongSelf.delegate?.sellProductViewController(strongSelf, didEditProduct: editVC)
            }
    }

    func productPostedViewModelDidRestartPosting(viewModel: ProductPostedViewModel) {
        dismissViewControllerAnimated(true) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.sellProductViewControllerDidTapPostAgain(strongSelf)
        }
    }


    // MARK: - Private methods

    private func setupView() {

        contentContainer.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        mainButton.setPrimaryStyle()
        editButton.setSecondaryStyle()

        editOrLabel.text = LGLocalizedString.productPostConfirmationAnother.uppercase
        editButton.setTitle(LGLocalizedString.productPostConfirmationEdit, forState: UIControlState.Normal)

        mainIconImage.tintColor = UIColor.primaryColor
        loadingIndicator.color = UIColor.primaryColor
    }

    private func setupStatic(correct: Bool) {
        loadingIndicator.hidden = true
        mainTextLabel.text = viewModel.mainText
        secondaryTextLabel.text = viewModel.secondaryText
        mainButton.setTitle(viewModel.mainButtonText, forState: UIControlState.Normal)

        if !correct {
            editContainer.hidden = true
            editContainerHeight.constant = 0
            shareButton.hidden = true
        }
    }

    private func setupLoading() {
        mainIconImage.hidden = true
        mainTextLabel.alpha = 0
        mainTextLabel.text = nil
        secondaryTextLabel.alpha = 0
        secondaryTextLabel.text = nil
        editContainer.alpha = 0
        shareButton.alpha = 0
        mainButton.alpha = 0
        editContainerHeight.constant = 0
        mainButtonHeight.constant = 0
        loadingIndicator.startAnimating()
    }

    private func finishedLoading(correct: Bool) {
        mainButton.setTitle(viewModel.mainButtonText, forState: UIControlState.Normal)
        loadingIndicator.stopAnimating(correct) { [weak self] in
            if correct {
                self?.editContainerHeight.constant = ProductPostedViewController.contentContainerShownHeight
            }
            self?.mainButtonHeight.constant = LGUIKitConstants.enabledButtonHeight
            UIView.animateWithDuration(0.2,
                animations: { [weak self] in
                    self?.mainTextLabel.text = self?.viewModel.mainText
                    self?.secondaryTextLabel.text = self?.viewModel.secondaryText
                    self?.mainTextLabel.alpha = 1
                    self?.secondaryTextLabel.alpha = 1
                    if correct {
                        self?.editContainer.alpha = 1
                        self?.shareButton.alpha = 1
                    }
                    self?.mainButton.alpha = 1
                    self?.view.layoutIfNeeded()
                },
                completion: { finished in
                }
            )
        }
    }

    private func shareButtonPressed() {
        guard let shareInfo = viewModel.shareInfo else { return }

        presentNativeShare(socialMessage: shareInfo, delegate: self)
    }
}


// MARK: - NativeShareDelegate

extension ProductPostedViewController: NativeShareDelegate {

    func nativeShareInFacebook() {
        viewModel.nativeShareInFacebook()
        viewModel.nativeShareInFacebookFinished(.Completed)
    }

    func nativeShareInTwitter() {
        viewModel.nativeShareInTwitter()
    }

    func nativeShareInEmail() {
        viewModel.nativeShareInEmail()
    }

    func nativeShareInWhatsApp() {
        viewModel.nativeShareInWhatsApp()
    }
}
