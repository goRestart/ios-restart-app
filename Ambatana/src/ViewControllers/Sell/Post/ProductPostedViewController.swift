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

    // incentivize items
    @IBOutlet weak var incentiveContainer: UIView!
    @IBOutlet weak var incentiveLabel: UILabel!
    @IBOutlet weak var firstImage: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var firstCountLabel: UILabel!
    @IBOutlet weak var secondImage: UIImageView!
    @IBOutlet weak var secondNameLabel: UILabel!
    @IBOutlet weak var secondCountLabel: UILabel!
    @IBOutlet weak var thirdImage: UIImageView!
    @IBOutlet weak var thirdNameLabel: UILabel!
    @IBOutlet weak var thirdCountLabel: UILabel!


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

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        setStatusBarHidden(false)
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
        setStatusBarHidden(true)
        mainButton.setPrimaryStyle()
//        editButton.setSecondaryStyle()

        editOrLabel.text = LGLocalizedString.productPostConfirmationAnother.uppercase
        editButton.setTitle(LGLocalizedString.productPostConfirmationEdit, forState: UIControlState.Normal)

        mainIconImage.tintColor = StyleHelper.primaryColor
        loadingIndicator.color = StyleHelper.primaryColor
    }

    private func setupStatic(correct: Bool) {
        loadingIndicator.hidden = true
        mainTextLabel.text = viewModel.mainText
        secondaryTextLabel.text = viewModel.secondaryText
        mainButton.setTitle(viewModel.mainButtonText, forState: UIControlState.Normal)

        setupIncentiviseView()

        if !correct {
            editContainer.hidden = true
            editContainerHeight.constant = 0
            shareButton.hidden = true
            incentiveContainer.hidden = true
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

// MARK: - Incentivise methods

extension ProductPostedViewController {

    func setupIncentiviseView() {

        let itemPack = PostIncentiviserItem.incentiviserPack()

        guard itemPack.count == 3 else {
            incentiveContainer.hidden = true
            return
        }

        let firstItem = itemPack[0]
        let secondItem = itemPack[1]
        let thirdItem = itemPack[2]

        firstImage.image = firstItem.image
        firstNameLabel.text = firstItem.name
        firstCountLabel.text = firstItem.searchCount

        secondImage.image = secondItem.image
        secondNameLabel.text = secondItem.name
        secondCountLabel.text = secondItem.searchCount

        thirdImage.image = thirdItem.image
        thirdNameLabel.text = thirdItem.name
        thirdCountLabel.text = thirdItem.searchCount

        incentiveLabel.attributedText = incentiveText
    }

    var incentiveText: NSAttributedString {


//        var gotAnyTextAttributes = [String : AnyObject]()
//        gotAnyTextAttributes[NSForegroundColorAttributeName] = UIColor.darkTextColor()
//        gotAnyTextAttributes[NSFontAttributeName] = UIFont.systemSemiBoldFont(size: 15)
//
//        let newText = NSAttributedString(string: LGLocalizedString.productPostIncentiveGotAny, attributes: gotAnyTextAttributes)
//
//        var titleTextAttributes = [String : AnyObject]()
//        titleTextAttributes[NSForegroundColorAttributeName] = UIColor.whiteColor()
//        titleTextAttributes[NSFontAttributeName] = UIFont.systemSemiBoldFont(size: 17)
//
//        let titleText = NSAttributedString(string: LGLocalizedString.productPostIncentiveLookingFor(newText), attributes: titleTextAttributes)
//
//        let fullTitle: NSMutableAttributedString = NSMutableAttributedString(attributedString: newText)
//        fullTitle.appendAttributedString(NSAttributedString(string: " "))
//        fullTitle.appendAttributedString(titleText)


        let gotAnyTextAttributes: [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.darkTextColor(),
                                                       NSFontAttributeName : UIFont.systemBoldFont(size: 15)]
        let lookingForTextAttributes: [String : AnyObject] = [ NSForegroundColorAttributeName : UIColor.darkTextColor(),
                                                         NSFontAttributeName : UIFont.systemRegularFont(size: 15)]
        let plainText = LGLocalizedString.productPostIncentiveLookingFor(LGLocalizedString.productPostIncentiveGotAny)
        let resultText = NSMutableAttributedString(string: plainText, attributes: lookingForTextAttributes)
        let boldRange = NSString(string: plainText).rangeOfString(LGLocalizedString.productPostIncentiveGotAny,
                                                                  options: .CaseInsensitiveSearch)
        resultText.addAttributes(gotAnyTextAttributes, range: boldRange)

        return resultText
    }

}
