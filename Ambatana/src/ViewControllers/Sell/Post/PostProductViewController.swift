//
//  PostProductViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 11/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import FastttCamera

class PostProductViewController: BaseViewController, PostProductViewModelDelegate, UITextFieldDelegate {
    @IBOutlet weak var cameraGalleryContainer: UIView!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var photoButtonCenterX: NSLayoutConstraint!

    @IBOutlet weak var selectPriceContainer: UIView!
    @IBOutlet weak var selectPriceContentContainerCenterY: NSLayoutConstraint!
    @IBOutlet weak var customLoadingView: LoadingIndicator!
    @IBOutlet weak var postedInfoLabel: UILabel!
    @IBOutlet weak var addPriceLabel: UILabel!
    @IBOutlet weak var priceFieldContainer: UIView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var postErrorLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!

    private var viewPager: LGViewPager
    private var cameraView: PostProductCameraView
    private var galleryView: PostProductGalleryView
    private var viewDidAppear: Bool = false

    private let forceCamera: Bool
    private var initialTab: Int {
        if forceCamera { return 1 }
        return KeyValueStorage.sharedInstance.userPostProductLastTabSelected
    }


    // ViewModel
    private var viewModel: PostProductViewModel


    // MARK: - Lifecycle

    convenience init(forceCamera: Bool) {
        self.init(viewModel: PostProductViewModel(source: .SellButton), forceCamera: forceCamera)
    }

    required init(viewModel: PostProductViewModel, forceCamera: Bool) {
        let viewPagerConfig = LGViewPagerConfig(tabPosition: .Hidden, tabLayout: .Fixed, tabHeight: 54)
        self.viewPager = LGViewPager(config: viewPagerConfig, frame: CGRect.zero)
        self.cameraView = PostProductCameraView()
        self.galleryView = PostProductGalleryView()
        self.viewModel = viewModel
        self.forceCamera = forceCamera
        super.init(viewModel: viewModel, nibName: "PostProductViewController",
                   statusBarStyle: UIApplication.sharedApplication().statusBarStyle)
        modalPresentationStyle = .OverCurrentContext
        self.viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PostProductViewController.keyboardWillShow(_:)),
            name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PostProductViewController.keyboardWillHide(_:)),
            name: UIKeyboardWillHideNotification, object: nil)

        viewModel.onViewLoaded()
        setupView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !viewDidAppear {
            viewPager.delegate = self
            viewPager.selectTabAtIndex(initialTab)
            updateButtonsForPagerScroll(CGFloat(initialTab))
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarHidden(true)
        cameraView.active = true
        galleryView.active = true
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppear = true
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        setStatusBarHidden(false)
        galleryView.active = false
        cameraView.active = false
    }


    // MARK: - Actions
    
    @IBAction func onCloseButton(sender: AnyObject) {
        priceTextField.resignFirstResponder()
        viewModel.closeButtonPressed()
    }

    @IBAction func galleryButtonPressed(sender: AnyObject) {
        guard viewPager.scrollEnabled else { return }
        viewPager.selectTabAtIndex(0, animated: true)
    }

    @IBAction func photoButtonPressed(sender: AnyObject) {
        if viewPager.currentPage == 1 {
            cameraView.takePhoto()
        } else {
            viewPager.selectTabAtIndex(1, animated: true)
        }
    }

    @IBAction func onCurrencyButton(sender: AnyObject) {
        //Not implemented right now
    }

    @IBAction func onDoneButton(sender: AnyObject) {
        priceTextField.resignFirstResponder()

        viewModel.doneButtonPressed(priceText: priceTextField.text)
    }

    @IBAction func onRetryButton(sender: AnyObject) {
        viewModel.retryButtonPressed()
    }


    // MARK: - PostProductViewModelDelegate

    func postProductViewModelDidRestartTakingImage(viewModel: PostProductViewModel) {
        selectPriceContainer.hidden = true
    }

    func postProductViewModelDidStartUploadingImage(viewModel: PostProductViewModel) {
        setSelectPriceState(loading: true, error: nil)
    }

    func postProductViewModelDidFinishUploadingImage(viewModel: PostProductViewModel, error: String?) {
        setSelectPriceState(loading: false, error: error)
    }

    func postProductviewModelShouldClose(viewModel: PostProductViewModel, animated: Bool, completion: (() -> Void)?) {
        dismissViewControllerAnimated(animated, completion: completion)
    }

    func postProductviewModel(viewModel: PostProductViewModel, shouldAskLoginWithCompletion completion: () -> Void) {
        ifLoggedInThen(.Sell, loginStyle: .Popup(LGLocalizedString.productPostLoginMessage),
            preDismissAction: { [weak self] in
                self?.view.hidden = true
            },
            loggedInAction: completion,
            elsePresentSignUpWithSuccessAction: completion)
    }


    // MARK: - UITextFieldDelegate

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
        replacementString string: String) -> Bool {
            guard textField == priceTextField else { return true }
            return textField.shouldChangePriceInRange(range, replacementString: string)
    }


    // MARK: - Private methods

    private func setupView() {
        
        cameraView.delegate = self
        cameraView.usePhotoButtonText = viewModel.usePhotoButtonText

        galleryView.delegate = self
        galleryView.usePhotoButtonText = viewModel.usePhotoButtonText

        setupViewPager()

        //i18n
        addPriceLabel.text = LGLocalizedString.productPostPriceLabel.uppercase
        priceTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.productNegotiablePrice,
            attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        doneButton.setTitle(LGLocalizedString.productPostDone, forState: UIControlState.Normal)
        retryButton.setTitle(LGLocalizedString.commonErrorListRetryButton, forState: UIControlState.Normal)

        //Layers
        retryButton.setStyle(.Primary(fontSize: .Medium))
        doneButton.setStyle(.Primary(fontSize: .Medium))
        priceFieldContainer.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        priceFieldContainer.layer.borderColor = UIColor.whiteColor().CGColor
        priceFieldContainer.layer.borderWidth = 1

        currencyButton.setTitle(viewModel.currency?.symbol, forState: UIControlState.Normal)
    }

    private func updateButtonsForPagerScroll(scroll: CGFloat) {
        galleryButton.alpha = scroll

        let movement = (view.width/2) * (1.0 - scroll)
        photoButtonCenterX.constant = movement
    }

    private func setSelectPriceState(loading loading: Bool, error: String?) {
        selectPriceContainer.hidden = false
        let hasError = error != nil

        if(loading) {
            customLoadingView.startAnimating()
            setSelectPriceItems(loading, error: error)
        }
        else {
            customLoadingView.stopAnimating(!hasError) { [weak self] in
                self?.setSelectPriceItems(loading, error: error)
            }
        }
    }

    private func setSelectPriceItems(loading: Bool, error: String?) {

        postedInfoLabel.alpha = 0
        postedInfoLabel.text = error != nil ?
            LGLocalizedString.commonErrorTitle.capitalizedString : viewModel.confirmationOkText
        postErrorLabel.text = error

        if (loading) {
            setSelectPriceBottomItems(loading, error: error)
        } else {
            UIView.animateWithDuration(0.2,
                animations: { [weak self] in
                    self?.postedInfoLabel.alpha = 1
                },
                completion: { [weak self] completed in
                    self?.postedInfoLabel.alpha = 1
                    self?.setSelectPriceBottomItems(loading, error: error)
                }
            )
        }
    }

    private func setSelectPriceBottomItems(loading: Bool, error: String?) {
        addPriceLabel.alpha = 0
        priceFieldContainer.alpha = 0
        doneButton.alpha = 0
        postErrorLabel.alpha = 0
        retryButton.alpha = 0

        guard !loading else { return }

        let okItemsAlpha: CGFloat = error != nil ? 0 : 1
        let wrongItemsAlpha: CGFloat = error == nil ? 0 : 1
        let finalAlphaBlock = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.addPriceLabel.alpha = okItemsAlpha
            strongSelf.priceFieldContainer.alpha = okItemsAlpha
            strongSelf.doneButton.alpha = okItemsAlpha
            strongSelf.postErrorLabel.alpha = wrongItemsAlpha
            strongSelf.retryButton.alpha = wrongItemsAlpha
        }
        UIView.animateWithDuration(0.2, delay: 0.8, options: UIViewAnimationOptions(),
            animations: { () -> Void in
                finalAlphaBlock()
            }, completion: { [weak self] (completed: Bool) -> Void in
                finalAlphaBlock()

                if okItemsAlpha == 1 {
                    self?.priceTextField.becomeFirstResponder()
                } else {
                    self?.priceTextField.resignFirstResponder()
                }
            }
        )
    }
}


// MARK: - PostProductCameraViewDelegate

extension PostProductViewController: PostProductCameraViewDelegate {
    func productCameraCloseButton() {
        onCloseButton(cameraView)
    }

    func productCameraDidTakeImage(image: UIImage) {
        viewModel.imageSelected(image, source: .Camera)
    }

    func productCameraRequestHideTabs(hide: Bool) {
        galleryButton.hidden = hide
        photoButton.hidden = hide
    }

    func productCameraRequestsScrollLock(lock: Bool) {
        viewPager.scrollEnabled = !lock
    }
}


// MARK: - PostProductGalleryViewDelegate

extension PostProductViewController: PostProductGalleryViewDelegate {
    func productGalleryCloseButton() {
        onCloseButton(galleryView)
    }

    func productGalleryDidSelectImage(image: UIImage) {
        viewModel.imageSelected(image, source: .Gallery)
    }

    func productGalleryRequestsScrollLock(lock: Bool) {
        viewPager.scrollEnabled = !lock
    }

    func productGalleryDidPressTakePhoto() {
        viewPager.selectTabAtIndex(1)
    }

    func productGalleryShowActionSheet(cancelAction: UIAction, actions: [UIAction]) {
        showActionSheet(cancelAction, actions: actions, sourceView: galleryView.albumButton,
                        sourceRect: galleryView.albumButton.frame, completion: nil)
    }
}


// MARK: - LGViewPager

extension PostProductViewController: LGViewPagerDataSource, LGViewPagerDelegate, LGViewPagerScrollDelegate {

    func setupViewPager() {
        viewPager.dataSource = self
        viewPager.scrollDelegate = self
        viewPager.indicatorSelectedColor = UIColor.primaryColor
        viewPager.tabsBackgroundColor = UIColor.black
        viewPager.tabsSeparatorColor = UIColor.clearColor()
        viewPager.translatesAutoresizingMaskIntoConstraints = false
        cameraGalleryContainer.insertSubview(viewPager, atIndex: 0)
        setupViewPagerConstraints()

        viewPager.reloadData()
    }

    private func setupViewPagerConstraints() {
        let views = ["viewPager": viewPager]
        cameraGalleryContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[viewPager]|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        cameraGalleryContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[viewPager]|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }

    func viewPager(viewPager: LGViewPager, willDisplayView view: UIView, atIndex index: Int) {
        KeyValueStorage.sharedInstance.userPostProductLastTabSelected = index
    }

    func viewPager(viewPager: LGViewPager, didEndDisplayingView view: UIView, atIndex index: Int) {}

    func viewPager(viewPager: LGViewPager, didScrollToPagePosition pagePosition: CGFloat) {
        cameraView.showHeader(pagePosition == 1.0)
        galleryView.showHeader(pagePosition == 0.0)

        updateButtonsForPagerScroll(pagePosition)
    }

    func viewPagerNumberOfTabs(viewPager: LGViewPager) -> Int {
        return 2
    }

    func viewPager(viewPager: LGViewPager, viewForTabAtIndex index: Int) -> UIView {
        if index == 0 {
            return galleryView
        }
        else {
            return cameraView
        }
    }

    func viewPager(viewPager: LGViewPager, showInfoBadgeAtIndex index: Int) -> Bool {
        return false
    }

    func viewPager(viewPager: LGViewPager, titleForUnselectedTabAtIndex index: Int) -> NSAttributedString {
        if index == 0 {
            return NSAttributedString(string: LGLocalizedString.productPostGalleryTab, attributes: tabTextAttributes(false))
        } else {
            return NSAttributedString(string: LGLocalizedString.productPostCameraTab, attributes: tabTextAttributes(false))
        }
    }

    func viewPager(viewPager: LGViewPager, titleForSelectedTabAtIndex index: Int) -> NSAttributedString {
        if index == 0 {
            return NSAttributedString(string: LGLocalizedString.productPostGalleryTab, attributes: tabTextAttributes(true))
        } else {
            return NSAttributedString(string: LGLocalizedString.productPostCameraTab, attributes: tabTextAttributes(true))
        }
    }

    private func tabTextAttributes(selected: Bool)-> [String : AnyObject] {
        var titleAttributes = [String : AnyObject]()
        titleAttributes[NSForegroundColorAttributeName] = selected ? UIColor.primaryColor : UIColor.white
        titleAttributes[NSFontAttributeName] = selected ? UIFont.activeTabFont : UIFont.inactiveTabFont
        return titleAttributes
    }
}


// MARK: - Keyboard notifications

extension PostProductViewController {
    
    func keyboardWillShow(notification: NSNotification) {
        centerPriceContentContainer(notification)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        centerPriceContentContainer(notification)
    }
    
    func centerPriceContentContainer(keyboardNotification: NSNotification) {
        let kbAnimation = KeyboardAnimation(keyboardNotification: keyboardNotification)
        UIView.animateWithDuration(kbAnimation.duration, delay: 0, options: kbAnimation.options, animations: {
            [weak self] in
            self?.selectPriceContentContainerCenterY.constant = -(kbAnimation.size.height/2)
            self?.selectPriceContainer.layoutIfNeeded()
        }, completion: nil)
    }
}
