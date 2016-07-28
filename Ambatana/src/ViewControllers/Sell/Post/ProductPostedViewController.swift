//
//  ProductPostedViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 14/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

class ProductPostedViewController: BaseViewController, ProductPostedViewModelDelegate {
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var contentContainer: UIView!
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


    // MARK: - Private methods

    private func setupView() {
        setStatusBarHidden(true)
        mainButton.setStyle(.Primary(fontSize: .Big))
        editOrLabel.text = LGLocalizedString.productPostConfirmationAnother.uppercase
        editButton.setTitle(LGLocalizedString.productPostConfirmationEdit, forState: UIControlState.Normal)
        loadingIndicator.color = UIColor.primaryColor

        setupIncentiviseView()
    }

    private func setupStatic(loadingSuccessful: Bool) {
        loadingIndicator.hidden = true
        mainTextLabel.text = viewModel.mainText
        secondaryTextLabel.text = viewModel.secondaryText
        mainButton.setTitle(viewModel.mainButtonText, forState: UIControlState.Normal)

        if !loadingSuccessful {
            editContainer.hidden = true
            editContainerHeight.constant = 0
            shareButton.hidden = true
            incentiveContainer.hidden = true
        }
    }

    private func setupLoading() {
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
        incentiveContainer.hidden = true
    }

    private func finishedLoading(correct: Bool) {
        mainButton.setTitle(viewModel.mainButtonText, forState: UIControlState.Normal)
        loadingIndicator.hidden = true
        loadingIndicator.stopAnimating(correct) { [weak self] in
            if correct {
                self?.editContainerHeight.constant = ProductPostedViewController.contentContainerShownHeight
                self?.incentiveContainer.hidden = false
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
        firstNameLabel.textColor = UIColor.blackText
        firstCountLabel.text = firstItem.searchCount
        firstCountLabel.textColor = UIColor.darkGrayText

        secondImage.image = secondItem.image
        secondNameLabel.text = secondItem.name
        secondNameLabel.textColor = UIColor.blackText
        secondCountLabel.text = secondItem.searchCount
        secondCountLabel.textColor = UIColor.darkGrayText

        thirdImage.image = thirdItem.image
        thirdNameLabel.text = thirdItem.name
        thirdNameLabel.textColor = UIColor.blackText
        thirdCountLabel.text = thirdItem.searchCount
        thirdCountLabel.textColor = UIColor.darkGrayText

        incentiveLabel.attributedText = incentiveText
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onMainButton(_:)))
        incentiveContainer.addGestureRecognizer(tap)
    }

    var incentiveText: NSAttributedString {
        let gotAnyTextAttributes: [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.darkGrayText,
                                                       NSFontAttributeName : UIFont.systemBoldFont(size: 15)]
        let lookingForTextAttributes: [String : AnyObject] = [ NSForegroundColorAttributeName : UIColor.darkGrayText,
                                                         NSFontAttributeName : UIFont.mediumBodyFont]
        let plainText = LGLocalizedString.productPostIncentiveLookingFor(LGLocalizedString.productPostIncentiveGotAny)
        let resultText = NSMutableAttributedString(string: plainText, attributes: lookingForTextAttributes)
        let boldRange = NSString(string: plainText).rangeOfString(LGLocalizedString.productPostIncentiveGotAny,
                                                                  options: .CaseInsensitiveSearch)
        resultText.addAttributes(gotAnyTextAttributes, range: boldRange)

        return resultText
    }
}
