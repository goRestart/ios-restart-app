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

    // Share container: hidden on this version //TODO: Remove if not used in further versions
    @IBOutlet weak var shareContainer: UIView!
    @IBOutlet weak var shareContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var socialShareView: SocialShareView!
    @IBOutlet weak var shareItLabel: UILabel!
    @IBOutlet weak var orLabel: UILabel!

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
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        self.viewModel = viewModel
        viewModel.delegate = self
        modalPresentationStyle = .OverCurrentContext
        modalTransitionStyle = .CrossDissolve
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        viewModel.onViewLoaded()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.onViewWillAppear()
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
            strongSelf.delegate?.sellProductViewController(strongSelf, didCompleteSell: correctly)
        }
    }

    func productPostedViewModelDidEditPosting(viewModel: ProductPostedViewModel,
        editViewModel: EditSellProductViewModel) {
            dismissViewControllerAnimated(true) { [weak self] in
                guard let strongSelf = self else { return }

                strongSelf.delegate?.sellProductViewController(strongSelf,
                    didEditProduct: EditSellProductViewController(viewModel: editViewModel, updateDelegate: nil))
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

        contentContainer.layer.cornerRadius = StyleHelper.defaultCornerRadius
        mainButton.setPrimaryStyle()
        editButton.setSecondaryStyle()

        shareItLabel.text = LGLocalizedString.productPostConfirmationShare.uppercaseString
        orLabel.text = LGLocalizedString.productPostConfirmationAnother.uppercaseString
        editOrLabel.text = LGLocalizedString.productPostConfirmationAnother.uppercaseString
        editButton.setTitle(LGLocalizedString.productPostConfirmationEdit, forState: UIControlState.Normal)

        mainIconImage.tintColor = StyleHelper.primaryColor
        loadingIndicator.color = StyleHelper.primaryColor
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
            self?.mainButtonHeight.constant = StyleHelper.enabledButtonHeight
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

        presentNativeShareWith(shareText: shareInfo.shareText, delegate: self)
    }
}


// MARK: - SocialShareViewDelegate

extension ProductPostedViewController: SocialShareViewDelegate {

    func shareInEmail(){
        viewModel.shareInEmail()
    }

    func shareInFacebook() {
        viewModel.shareInFacebook()
    }

    func shareInFacebookFinished(state: SocialShareState) {
        viewModel.shareInFacebookFinished(state)
    }

    func shareInFBMessenger() {
        viewModel.shareInFBMessenger()
    }

    func shareInFBMessengerFinished(state: SocialShareState) {
        viewModel.shareInFBMessengerFinished(state)
    }

    func shareInWhatsApp() {
        viewModel.shareInWhatsApp()
    }

    func viewController() -> UIViewController? {
        return self
    }
}


// MARK: - NativeShareDelegate

extension ProductPostedViewController: NativeShareDelegate {

    func nativeShareInFacebook() {
        viewModel.shareInFacebook()
        viewModel.shareInFacebookFinished(.Completed)
    }

    func nativeShareInTwitter() {
        viewModel.shareInTwitter()
    }

    func nativeShareInEmail() {
        viewModel.shareInEmail()
    }

    func nativeShareInWhatsApp() {
        viewModel.shareInWhatsApp()
    }
}


