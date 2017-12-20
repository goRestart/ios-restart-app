//
//  EditListingViewController.swift
//  LetGo
//
//  Created by Dídac on 23/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import FBSDKShareKit
import LGCoreKit
import Result
import RxSwift
import KMPlaceholderTextView


class EditListingViewController: BaseViewController, UITextFieldDelegate,
    UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {
    
    // UI
    private static let loadingTitleDisclaimerLeadingConstraint: CGFloat = 8
    private static let completeTitleDisclaimerLeadingConstraint: CGFloat = -20
    private static let titleDisclaimerHeightConstraint: CGFloat = 16
    private static let titleDisclaimerBottomConstraintVisible: CGFloat = 24
    private static let titleDisclaimerBottomConstraintHidden: CGFloat = 8
    private static let separatorOptionsViewDistance = LGUIKitConstants.onePixelSize
    private static let viewOptionGenericHeight: CGFloat = 50
    private static let carsInfoContainerHeight: CGFloat = 134 // (3 x 44 + 2 separators)
    private static let realEstateInfoContainerHeight: CGFloat = 179 // (4 x 44 + 3 separators)
    
    enum TextFieldTag: Int {
        case listingTitle = 1000, listingPrice, listingDescription
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var containerEditOptionsView: UIView!
    
    @IBOutlet var separatorContainerViewsConstraints: [NSLayoutConstraint]!
    @IBOutlet weak var priceViewSeparatorTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var freePostViewSeparatorTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var titleContainerView: UIView!
    @IBOutlet weak var titleTextField: LGTextField!
    @IBOutlet weak var titleDisclaimer: UILabel!
    @IBOutlet weak var autoGeneratedTitleButton: UIButton!
    @IBOutlet weak var titleDisclaimerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleDisclaimerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleDisclaimerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var updateButtonBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var postFreeView: UIView!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var priceContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var postFreeViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var freePostingSwitch: UISwitch!
    
    @IBOutlet weak var postFreeLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var priceTextField: LGTextField!
    
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var descriptionCharCountLabel: UILabel!
    @IBOutlet weak var titleDisclaimerActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var descriptionTextView: KMPlaceholderTextView!

    @IBOutlet weak var setLocationTitleLabel: UILabel!
    @IBOutlet weak var setLocationLocationLabel: UILabel!
    @IBOutlet weak var setLocationButton: UIButton!

    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var categorySelectedLabel: UILabel!
    @IBOutlet weak var categoryButton: UIButton!
    
    @IBOutlet weak var verticalFieldsContainer: UIView!
    @IBOutlet weak var verticalFieldsContainerConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var carInfoContainer: UIView!
    @IBOutlet weak var realEstateInfoContainer: UIView!

    @IBOutlet weak var carsMakeTitleLabel: UILabel!
    @IBOutlet weak var carsMakeSelectedLabel: UILabel!
    @IBOutlet weak var carsMakeButton: UIButton!

    @IBOutlet weak var carsModelTitleLabel: UILabel!
    @IBOutlet weak var carsModelSelectedLabel: UILabel!
    @IBOutlet weak var carsModelButton: UIButton!

    @IBOutlet weak var carsYearTitleLabel: UILabel!
    @IBOutlet weak var carsYearSelectedLabel: UILabel!
    @IBOutlet weak var carsYearButton: UIButton!
    
    @IBOutlet weak var realEstatePropertyTypeTitleLabel: UILabel!
    @IBOutlet weak var realEstatePropertyTypeSelectedLabel: UILabel!
    @IBOutlet weak var realEstatePropertyTypeButton: UIButton!
    
    @IBOutlet weak var realEstateOfferTypeTitleLabel: UILabel!
    @IBOutlet weak var realEstateOfferTypeSelectedLabel: UILabel!
    @IBOutlet weak var realEstateOfferTypeButton: UIButton!
    
    @IBOutlet weak var realEstateNumberOfBedroomsTitleLabel: UILabel!
    @IBOutlet weak var realEstateNumberOfBedroomsSelectedLabel: UILabel!
    @IBOutlet weak var realEstateNumberOfBedroomsButton: UIButton!
    
    @IBOutlet weak var realEstateNumberOfBathroomsTitleLabel: UILabel!
    @IBOutlet weak var realEstateNumberOfBathroomsSelectedLabel: UILabel!
    @IBOutlet weak var realEstateNumberOfBathroomsButton: UIButton!
    

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var shareFBSwitch: UISwitch!
    @IBOutlet weak var shareFBLabel: UILabel!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loadingProgressView: UIProgressView!

    var hideKbTapRecognizer: UITapGestureRecognizer?

    // viewModel
    fileprivate var viewModel : EditListingViewModel
    fileprivate var keyboardHelper: KeyboardHelper
    private var featureFlags: FeatureFlaggeable
    // Rx
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate var activeField: UIView? = nil

    // MARK: - Lifecycle
    
    convenience init(viewModel: EditListingViewModel) {
        self.init(viewModel: viewModel, keyboardHelper: KeyboardHelper(), featureFlags: FeatureFlags.sharedInstance)
    }
    
    required init(viewModel: EditListingViewModel, keyboardHelper: KeyboardHelper, featureFlags: FeatureFlaggeable) {
        self.keyboardHelper = keyboardHelper
        self.viewModel = viewModel
        self.featureFlags = featureFlags
        super.init(viewModel: viewModel, nibName: "EditListingViewController")
        self.viewModel.delegate = self
        automaticallyAdjustsScrollViewInsets = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setAccesibilityIds()
        setupRxBindings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        descriptionTextView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
    }
    
    // MARK: - Public methods
    
    // MARK: > Actions
  
    @IBAction func categoryButtonPressed(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: LGLocalizedString.sellChooseCategoryDialogTitle, message: nil,
            preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = categoryButton
        alert.popoverPresentationController?.sourceRect = categoryButton.frame

        for i in 0..<viewModel.numberOfCategories {
            alert.addAction(UIAlertAction(title: viewModel.categoryNameAtIndex(i), style: .default,
                handler: { (categoryAction) -> Void in
                    self.viewModel.selectCategoryAtIndex(i)
            }))
        }
        
        alert.addAction(UIAlertAction(title: LGLocalizedString.sellChooseCategoryDialogCancelButton,
            style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
    
    @IBAction func sendButtonPressed(_ sender: AnyObject) {
        viewModel.sendButtonPressed()
    }
    
    @IBAction func shareFBSwitchChanged(_ sender: AnyObject) {
        viewModel.shouldShareInFB = shareFBSwitch.isOn
    }

    // MARK: - TextField Delegate Methods
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // textField is inside a container, so we need to know which container is focused (to scroll to visible when keyboard was up)
        activeField = textField.superview
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let tag = TextFieldTag(rawValue: textField.tag), tag == .listingTitle else { return }
        if let text = textField.text {
            viewModel.userFinishedEditingTitle(text)
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if textField == priceTextField && !textField.shouldChangePriceInRange(range, replacementString: string,
                                                                              acceptsSeparator: true) {
             return false
        }

        let cleanReplacement = string.stringByRemovingEmoji()

        let text = textField.textReplacingCharactersInRange(range, replacementString: cleanReplacement)
        if let tag = TextFieldTag(rawValue: textField.tag) {
            switch (tag) {
            case .listingTitle:
                viewModel.title = text.isEmpty ? nil : text
                if string.hasEmojis() {
                    //Forcing the new text (without emojis) by returning false
                    textField.text = text
                    return false
                }
                viewModel.userWritesTitle(text)
            case .listingPrice:
                viewModel.price = text.isEmpty ? nil : text
            case .listingDescription:
                break
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == TextFieldTag.listingTitle.rawValue && !freePostingSwitch.isOn {
            let nextTag = textField.tag + 1
            if let nextView = view.viewWithTag(nextTag) {
                nextView.becomeFirstResponder()
            }
        }
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if let tag = TextFieldTag(rawValue: textField.tag), tag == .listingTitle {
            viewModel.title = ""
            viewModel.userWritesTitle(textField.text)
        }
        return true
    }

    // MARK: - UITextViewDelegate Methods
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        // textView is inside a container, so we need to know which container is focused (to scroll to visible when keyboard was up)
        activeField = textView.superview
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let textViewText = textView.text {
            let cleanReplacement = text.stringByRemovingEmoji()
            let finalText = (textViewText as NSString).replacingCharacters(in: range, with: cleanReplacement)
            viewModel.descr = finalText.isEmpty ? nil : finalText
            if text.hasEmojis() {
                //Forcing the new text (without emojis) by returning false
                textView.text = finalText
                return false
            }
        }
        return true
    }
    
    
    // MARK: - Collection View Data Source methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.maxImageCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
        
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SellListingCell.reusableID,
                for: indexPath) as? SellListingCell else { return UICollectionViewCell() }
            cell.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
            if indexPath.item < viewModel.numberOfImages {
                cell.setupCellWithImageType(viewModel.imageAtIndex(indexPath.item))
                cell.label.text = ""
            } else if indexPath.item == viewModel.numberOfImages {
                cell.setupAddPictureCell()
            } else {
                cell.setupEmptyCell()
            }
            return cell
    }
    
    
    // MARK: - Collection View Delegate methods

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == viewModel.numberOfImages {
            // add image
            let cell = collectionView.cellForItem(at: indexPath) as? SellListingCell
            cell?.highlight()
            MediaPickerManager.showImagePickerIn(self)
            if indexPath.item > 1 && indexPath.item < 4 {
                collectionView.scrollToItem(at: IndexPath(item: indexPath.item+1, section: 0),
                                            at: .right,
                                            animated: true)
            }
            
        } else if (indexPath.item < viewModel.numberOfImages) {
            // remove image
            let alert = UIAlertController(title: LGLocalizedString.sellPictureSelectedTitle,
                                          message: nil,
                                          preferredStyle: .actionSheet)
            
            let cell = collectionView.cellForItem(at: indexPath) as? SellListingCell
            alert.popoverPresentationController?.sourceView = cell
            alert.popoverPresentationController?.sourceRect = cell?.bounds ?? .zero
            
            alert.addAction(UIAlertAction(title: LGLocalizedString.sellPictureSelectedDeleteButton,
                                          style: .destructive,
                                          handler: { [weak self] _ in
                                            self?.deleteAlreadyUploadedImageWithIndex(indexPath.item)
                                            guard indexPath.item > 0 else { return }
                                            collectionView.scrollToItem(at: IndexPath(item: indexPath.item-1, section: 0),
                                                                        at: .right, animated: true)
            }))
            alert.addAction(UIAlertAction(title: LGLocalizedString.sellPictureSelectedSaveIntoCameraRollButton,
                                          style: .default,
                                          handler: { [weak self] _ in
                                            self?.saveProductImageToDiskAtIndex(indexPath.item)
            }))
            alert.addAction(UIAlertAction(title: LGLocalizedString.sellPictureSelectedCancelButton, style: .cancel))
            present(alert, animated: true)
        }
    }
    
    
    // MARK: UIImagePicker Delegate
 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo
        info: [String : Any]) {
            var image = info[UIImagePickerControllerEditedImage] as? UIImage
            if image == nil { image = info[UIImagePickerControllerOriginalImage] as? UIImage }
            
            self.dismiss(animated: true, completion: nil)

            if let theImage = image {
                viewModel.appendImage(theImage)
            }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    
    // MARK: - Managing images.
    
    func deleteAlreadyUploadedImageWithIndex(_ index: Int) {
        // delete the image file locally
        viewModel.deleteImageAtIndex(index)
    }
    
    func saveProductImageToDiskAtIndex(_ index: Int) {
        showLoadingMessageAlert(LGLocalizedString.sellPictureSaveIntoCameraRollLoading)
        
        // get the image and launch the saving action.
        let imageTypeAtIndex = viewModel.imageAtIndex(index)
        switch imageTypeAtIndex {
        case .local(let image):
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(EditListingViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        case .remote(let file):
            guard let fileUrl = file.fileURL else {
                self.dismissLoadingMessageAlert(){
                    self.showAutoFadingOutMessageAlert(LGLocalizedString.sellPictureSaveIntoCameraRollErrorGeneric)
                }
                return
            }
            ImageDownloader.sharedInstance.downloadImageWithURL(fileUrl) { [weak self] (result, _) in
                guard let strongSelf = self, let image = result.value?.image else { return }
                UIImageWriteToSavedPhotosAlbum(image, strongSelf, #selector(EditListingViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    
    @objc func image(_ image: UIImage!, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
        self.dismissLoadingMessageAlert(){
            if error == nil { // success
                self.showAutoFadingOutMessageAlert(LGLocalizedString.sellPictureSaveIntoCameraRollOk)
            } else {
                self.showAutoFadingOutMessageAlert(LGLocalizedString.sellPictureSaveIntoCameraRollErrorGeneric)
            }
        }
    }


    // MARK: - Private methods

    func setupUI() {

        setNavBarTitle(LGLocalizedString.editProductTitle)
        let closeButton = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: UIBarButtonItemStyle.plain,
                                          target: self, action: #selector(EditListingViewController.closeButtonPressed))
        self.navigationItem.leftBarButtonItem = closeButton;
        
        separatorContainerViewsConstraints.forEach { $0.constant = EditListingViewController.separatorOptionsViewDistance }
        containerEditOptionsView.layer.cornerRadius = LGUIKitConstants.containerCornerRadius
        updateButtonBottomConstraint.constant = 0
        
        titleTextField.placeholder = LGLocalizedString.sellTitleFieldHint
        titleTextField.text = viewModel.title
        titleTextField.tag = TextFieldTag.listingTitle.rawValue
        titleDisclaimer.textColor = UIColor.darkGrayText
        titleDisclaimer.font = UIFont.smallBodyFont

        autoGeneratedTitleButton.rounded = true
        titleDisclaimerActivityIndicator.transform = titleDisclaimerActivityIndicator.transform.scaledBy(x: 0.8, y: 0.8)

        postFreeLabel.text = LGLocalizedString.sellPostFreeLabel
        
        currencyLabel.text = viewModel.currency?.code

        priceTextField.placeholder = LGLocalizedString.productNegotiablePrice
        priceTextField.text = viewModel.price
        priceTextField.tag = TextFieldTag.listingPrice.rawValue
        priceTextField.insetX = 16.0

        descriptionTextView.text = viewModel.descr ?? ""
        descriptionTextView.textColor = UIColor.blackText
        descriptionTextView.placeholder = LGLocalizedString.sellDescriptionFieldHint
        descriptionTextView.placeholderColor = UIColor.gray
        descriptionTextView.textContainerInset = UIEdgeInsetsMake(12.0, 11.0, 12.0, 11.0)
        descriptionTextView.tintColor = UIColor.primaryColor
        descriptionTextView.tag = TextFieldTag.listingDescription.rawValue
        descriptionCharCountLabel.text = "\(viewModel.descriptionCharCount)"

        setLocationTitleLabel.text = LGLocalizedString.settingsChangeLocationButton

        categoryTitleLabel.text = LGLocalizedString.sellCategorySelectionLabel
        categorySelectedLabel.text = viewModel.categoryName ?? ""

        carsMakeTitleLabel.text = LGLocalizedString.postCategoryDetailCarMake
        carsModelTitleLabel.text = LGLocalizedString.postCategoryDetailCarModel
        carsYearTitleLabel.text = LGLocalizedString.postCategoryDetailCarYear
        
        realEstatePropertyTypeTitleLabel.text = LGLocalizedString.realEstateTypePropertyTitle
        realEstateOfferTypeTitleLabel.text = LGLocalizedString.realEstateOfferTypeTitle
        realEstateNumberOfBedroomsTitleLabel.text = LGLocalizedString.realEstateBedroomsTitle
        realEstateNumberOfBathroomsTitleLabel.text = LGLocalizedString.realEstateBathroomsTitle
        
        sendButton.setTitle(LGLocalizedString.editProductSendButton, for: .normal)
        sendButton.setStyle(.primary(fontSize:.big))
        
        shareFBSwitch.isOn = viewModel.shouldShareInFB
        shareFBLabel.text = LGLocalizedString.sellShareOnFacebookLabel

        if featureFlags.freePostingModeAllowed {
            postFreeViewHeightConstraint.constant = EditListingViewController.viewOptionGenericHeight
            freePostViewSeparatorTopConstraint.constant = EditListingViewController.separatorOptionsViewDistance
        } else {
            postFreeViewHeightConstraint.constant = 0
            freePostViewSeparatorTopConstraint.constant = 0
        }
        
        // CollectionView
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        let cellNib = UINib(nibName: SellListingCell.reusableID, bundle: nil)
        self.imageCollectionView.register(cellNib, forCellWithReuseIdentifier: SellListingCell.reusableID)
        
        loadingLabel.text = LGLocalizedString.sellUploadingLabel
        view.bringSubview(toFront: loadingView)
        
        // hide keyboard on tap
        hideKbTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
    }

    fileprivate func setupRxBindings() {
        Observable.combineLatest(
            viewModel.titleAutogenerated.asObservable(),
            viewModel.titleAutotranslated.asObservable()) { (titleAutogenerated, titleAutotranslated) -> String? in
                if titleAutogenerated && titleAutotranslated {
                    return LGLocalizedString.sellTitleAutogenAutotransLabel
                } else if titleAutogenerated {
                    return LGLocalizedString.sellTitleAutogenLabel
                } else {
                    return nil
                }
            }
            .bind(to: titleDisclaimer.rx.text)
            .disposed(by: disposeBag)

        viewModel.titleDisclaimerStatus.asObservable().bind { [weak self] status in
            guard let strongSelf = self else { return }
            switch status {
            case .completed:
                strongSelf.autoGeneratedTitleButton.isHidden = true
                strongSelf.titleDisclaimerActivityIndicator.stopAnimating()

                if strongSelf.viewModel.titleAutogenerated.value || strongSelf.viewModel.titleAutotranslated.value {
                    strongSelf.titleDisclaimer.isHidden = false
                    strongSelf.titleDisclaimerLeadingConstraint.constant = EditListingViewController.completeTitleDisclaimerLeadingConstraint
                    strongSelf.titleDisclaimerHeightConstraint.constant = EditListingViewController.titleDisclaimerHeightConstraint
                    strongSelf.titleDisclaimerBottomConstraint.constant = EditListingViewController.titleDisclaimerBottomConstraintVisible
                } else {
                    strongSelf.titleDisclaimer.isHidden = true
                    strongSelf.titleDisclaimerLeadingConstraint.constant = EditListingViewController.loadingTitleDisclaimerLeadingConstraint
                    strongSelf.titleDisclaimerHeightConstraint.constant = 0
                    strongSelf.titleDisclaimerBottomConstraint.constant = EditListingViewController.titleDisclaimerBottomConstraintHidden
                }
            case .ready:
                strongSelf.autoGeneratedTitleButton.isHidden = false
                strongSelf.titleDisclaimerActivityIndicator.stopAnimating()
                strongSelf.titleDisclaimer.isHidden = true
                strongSelf.titleDisclaimerHeightConstraint.constant = EditListingViewController.titleDisclaimerHeightConstraint
                strongSelf.titleDisclaimerBottomConstraint.constant = EditListingViewController.titleDisclaimerBottomConstraintVisible
            case .loading:
                strongSelf.autoGeneratedTitleButton.isHidden = true
                strongSelf.titleDisclaimerActivityIndicator.startAnimating()
                strongSelf.titleDisclaimerLeadingConstraint.constant = 8
                strongSelf.titleDisclaimer.isHidden = false
                strongSelf.titleDisclaimerHeightConstraint.constant = EditListingViewController.titleDisclaimerHeightConstraint
                strongSelf.titleDisclaimerBottomConstraint.constant = EditListingViewController.titleDisclaimerBottomConstraintVisible
                strongSelf.titleDisclaimer.text = LGLocalizedString.editProductSuggestingTitle
            case .clean:
                strongSelf.autoGeneratedTitleButton.isHidden = true
                strongSelf.titleDisclaimerActivityIndicator.stopAnimating()
                strongSelf.titleDisclaimer.isHidden = true
                strongSelf.titleDisclaimerHeightConstraint.constant = 0
                strongSelf.titleDisclaimerBottomConstraint.constant = EditListingViewController.titleDisclaimerBottomConstraintHidden
            }
            strongSelf.view.layoutIfNeeded()
        }.disposed(by: disposeBag)

        viewModel.proposedTitle.asObservable().bind(to: autoGeneratedTitleButton.rx.title()).disposed(by: disposeBag)

        autoGeneratedTitleButton.rx.tap.bind { [weak self] in
            self?.titleTextField.text = self?.autoGeneratedTitleButton.titleLabel?.text
            self?.viewModel.title = self?.titleTextField.text
            self?.viewModel.userSelectedSuggestedTitle()
        }.disposed(by: disposeBag)


        viewModel.locationInfo.asObservable().bind(to: setLocationLocationLabel.rx.text).disposed(by: disposeBag)
        setLocationButton.rx.tap.bind { [weak self] in
            self?.viewModel.openMap()
        }.disposed(by: disposeBag)
        
        viewModel.isFreePosting.asObservable().bind(to: freePostingSwitch.rx.value).disposed(by: disposeBag)
        freePostingSwitch.rx.value.bind(to: viewModel.isFreePosting).disposed(by: disposeBag)
        viewModel.isFreePosting.asObservable().bind{[weak self] active in
            self?.updateFreePostViews(active)
            }.disposed(by: disposeBag)

        viewModel.category.asObservable().bind{ [weak self] category in
            guard let strongSelf = self else { return }
            strongSelf.categorySelectedLabel.text = category?.name ?? LGLocalizedString.categoriesUnassigned
            strongSelf.updateVerticalFields(category: category)
        }.disposed(by: disposeBag)

        let categoryIsRealEstate = viewModel.category.asObservable().flatMap { x in
            return x.map(Observable.just) ?? Observable.empty()
            }.map { $0.isRealEstate }
        let categoryIsEnabled = categoryIsRealEstate.asObservable().filter { !$0 }
        categoryIsEnabled.bind(to: categoryButton.rx.isEnabled).disposed(by: disposeBag)
        categoryIsEnabled.bind(to: categoryTitleLabel.rx.isEnabled).disposed(by: disposeBag) 
        
        viewModel.category.asObservable().filter { $0 == .realEstate }.bind { [weak self] _ in
            self?.categoryButton.isEnabled = false
            self?.categoryTitleLabel.isEnabled = false
        }.disposed(by: disposeBag)

        viewModel.carMakeName.asObservable().bind(to: carsMakeSelectedLabel.rx.text).disposed(by: disposeBag)
        viewModel.carMakeId.asObservable().bind{ [weak self] makeId in
            if let _ = makeId {
                self?.carsModelButton.isEnabled = true
                self?.carsModelTitleLabel.isEnabled = true
            } else {
                self?.carsModelButton.isEnabled = false
                self?.carsModelTitleLabel.isEnabled = false
            }
        }.disposed(by: disposeBag)

        viewModel.carModelName.asObservable().bind(to: carsModelSelectedLabel.rx.text).disposed(by: disposeBag)

        viewModel.carYear.asObservable().bind{ [weak self] year in
            guard let year = year, year != CarAttributes.emptyYear else {
                self?.carsYearSelectedLabel.text = ""
                return
            }
            self?.carsYearSelectedLabel.text = String(year)
        }.disposed(by: disposeBag)
        
        viewModel.realEstateOfferType.asObservable()
            .map {$0?.localizedString }
            .bind(to: realEstateOfferTypeSelectedLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.realEstatePropertyType.asObservable()
            .map {$0?.localizedString }
            .bind(to: realEstatePropertyTypeSelectedLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.realEstateNumberOfBedrooms.asObservable()
            .map {$0?.localizedString }
            .bind(to: realEstateNumberOfBedroomsSelectedLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.realEstateNumberOfBathrooms.asObservable()
            .map {$0?.localizedString }
            .bind(to: realEstateNumberOfBathroomsSelectedLabel.rx.text)
            .disposed(by: disposeBag)

        carsMakeButton.rx.tap.bind { [weak self] in
            self?.viewModel.carMakeButtonPressed()
            }.disposed(by: disposeBag)
        carsModelButton.rx.tap.bind { [weak self] in
            self?.viewModel.carModelButtonPressed()
            }.disposed(by: disposeBag)
        carsYearButton.rx.tap.bind { [weak self] in
            self?.viewModel.carYearButtonPressed()
            }.disposed(by: disposeBag)
        
        realEstatePropertyTypeButton.rx.tap.bind { [weak self] in
            self?.viewModel.realEstatePropertyTypeButtonPressed()
            }.disposed(by: disposeBag)
        realEstateOfferTypeButton.rx.tap.bind { [weak self] in
            self?.viewModel.realEstateOfferTypeButtonPressed()
            }.disposed(by: disposeBag)
        realEstateNumberOfBedroomsButton.rx.tap.bind { [weak self] in
            self?.viewModel.realEstateNumberOfBedroomsButtonPressed()
            }.disposed(by: disposeBag)
        realEstateNumberOfBathroomsButton.rx.tap.bind { [weak self] in
            self?.viewModel.realEstateNumberOfBathroomsButtonPressed()
            }.disposed(by: disposeBag)

        viewModel.loadingProgress.asObservable().map { $0 == nil }.bind(to: loadingView.rx.isHidden).disposed(by: disposeBag)
        viewModel.loadingProgress.asObservable().ignoreNil().bind(to: loadingProgressView.rx.progress).disposed(by: disposeBag)

        viewModel.saveButtonEnabled.asObservable().bind(to: sendButton.rx.isEnabled).disposed(by: disposeBag)
        
        var previousKbOrigin: CGFloat = CGFloat.greatestFiniteMagnitude
        keyboardHelper.rx_keyboardOrigin.asObservable().skip(1).distinctUntilChanged().bind { [weak self] origin in
            guard let strongSelf = self else { return }
            let viewHeight = strongSelf.view.height
            let animationTime = strongSelf.keyboardHelper.animationTime
            guard viewHeight >= origin else { return }

            self?.updateButtonBottomConstraint.constant = viewHeight - origin
            UIView.animate(withDuration: Double(animationTime)) {
                strongSelf.view.layoutIfNeeded()
                if let active = strongSelf.activeField, origin < previousKbOrigin {
                    var frame = active.frame
                    frame.top = frame.top + strongSelf.containerEditOptionsView.top
                    strongSelf.scrollView.scrollRectToVisible(frame, animated: false)
                }
                previousKbOrigin = origin
            }
        }.disposed(by: disposeBag)

        keyboardHelper.rx_keyboardVisible.asObservable().distinctUntilChanged().bind { [weak self] kbVisible in
            self?.updateTapRecognizer(kbVisible)
        }.disposed(by: disposeBag)
    }

    private func updateTapRecognizer(_ add: Bool) {
        guard let tapRec = hideKbTapRecognizer else { return }
        scrollView.removeGestureRecognizer(tapRec)
        if add {
            scrollView.addGestureRecognizer(tapRec)
        }
    }
    
    
    // MARK: - Private methods
    
    private func updateFreePostViews(_ active: Bool) {
        if active {
            priceContainerHeightConstraint.constant = 0
            priceViewSeparatorTopConstraint.constant = 0
        } else {
            priceContainerHeightConstraint.constant = EditListingViewController.viewOptionGenericHeight
            priceViewSeparatorTopConstraint.constant = EditListingViewController.separatorOptionsViewDistance
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    private func hideVerticalFields() {
        verticalFieldsContainerConstraint.constant = 0
    }
    
    private func updateVerticalFields(category: ListingCategory?) {
        guard let category = category else {
            hideVerticalFields()
            return
        }
        switch category {
        case .cars:
            carInfoContainer.isHidden = false
            realEstateInfoContainer.isHidden = true
            verticalFieldsContainerConstraint.constant = EditListingViewController.carsInfoContainerHeight
        case .realEstate:
            carInfoContainer.isHidden = true
            realEstateInfoContainer.isHidden = false
            verticalFieldsContainerConstraint.constant = EditListingViewController.realEstateInfoContainerHeight
        case .babyAndChild, .electronics, .fashionAndAccesories, .homeAndGarden, .motorsAndAccessories, .moviesBooksAndMusic, .other, .sportsLeisureAndGames, .unassigned:
            hideVerticalFields()
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }

    @objc func closeButtonPressed() {
        viewModel.closeButtonPressed()
    }
    
    @objc private dynamic func scrollViewTapped() {
        activeField?.endEditing(true)
    }
}


// MARK: - EditListingViewModelDelegate Methods

extension EditListingViewController: EditListingViewModelDelegate {

    func vmShouldUpdateDescriptionWithCount(_ count: Int) {
        if count <= 0 {
            descriptionCharCountLabel.textColor = UIColor.primaryColor
        } else {
            descriptionCharCountLabel.textColor = UIColor.black
        }
        descriptionCharCountLabel.text = "\(count)"
    }

    func vmDidAddOrDeleteImage() {
        imageCollectionView.reloadSections(IndexSet(integer: 0))
    }

    func vmShareOnFbWith(content: FBSDKShareLinkContent) {
        FBSDKShareDialog.show(from: self, with: content, delegate: self)
    }

    func openCarAttributeSelectionsWithViewModel(attributesChoiceViewModel: CarAttributeSelectionViewModel) {
        let vc = CarAttributeSelectionViewController(viewModel: attributesChoiceViewModel)
        navigationController?.pushViewController(vc, animated: true)
    }

    func vmShouldOpenMapWithViewModel(_ locationViewModel: EditLocationViewModel) {
        let vc = EditLocationViewController(viewModel: locationViewModel)
        navigationController?.pushViewController(vc, animated: true)
    }

    func vmHideKeyboard() {
        activeField?.endEditing(true)
    }
}


// MARK: - FBSDKSharingDelegate 

extension EditListingViewController: FBSDKSharingDelegate {
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable: Any]!) {
        viewModel.fbSharingFinishedOk()
    }

    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        viewModel.fbSharingFinishedWithError()
    }

    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        viewModel.fbSharingCancelled()
    }
}


// MARK: - Accesibility 

extension EditListingViewController {
    func setAccesibilityIds() {
        navigationItem.leftBarButtonItem?.accessibilityId = .editListingCloseButton
        scrollView.accessibilityId = .editListingScroll
        titleTextField.accessibilityId = .editListingTitleField
        autoGeneratedTitleButton.accessibilityId = .editListingAutoGenTitleButton
        imageCollectionView.accessibilityId = .editListingImageCollection
        currencyLabel.accessibilityId = .editListingCurrencyLabel
        priceTextField.accessibilityId = .editListingPriceField
        descriptionTextView.accessibilityId = .editListingDescriptionField
        setLocationButton.accessibilityId = .editListingLocationButton
        categoryButton.accessibilityId = .editListingCategoryButton
        carsMakeButton.accessibilityId = .editListingCarsMakeButton
        carsModelButton.accessibilityId = .editListingCarsModelButton
        carsYearButton.accessibilityId = .editListingCarsYearButton
        sendButton.accessibilityId = .editListingSendButton
        shareFBSwitch.accessibilityId = .editListingShareFBSwitch
        loadingView.accessibilityId = .editListingLoadingView
        freePostingSwitch.accessibilityId = .editListingPostFreeSwitch
    }
}
