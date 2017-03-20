//
//  EditProductViewModel.swift
//  LetGo
//
//  Created by Dídac on 23/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import FBSDKShareKit
import LGCoreKit
import Result
import RxSwift



enum TitleDisclaimerStatus {
    case completed  // title autogenerated and selected
    case ready      // no title yet, just received an autogenerated one
    case loading    // no title, waiting for response
    case clean      // user edits title
}

protocol EditProductViewModelDelegate : BaseViewModelDelegate {
    func vmDidSelectCategoryWithName(_ categoryName: String)
    func vmShouldUpdateDescriptionWithCount(_ count: Int)
    func vmDidAddOrDeleteImage()
    func vmShouldOpenMapWithViewModel(_ locationViewModel: EditLocationViewModel)
    func vmShareOnFbWith(content: FBSDKShareLinkContent)
    func vmHideKeyboard()
}

enum EditProductImageType {
    case local(image: UIImage)
    case remote(file: File)
}

class ProductImages {
    var images: [EditProductImageType] = []
    var localImages: [UIImage] {
        return images.flatMap {
            switch $0 {
            case .local(let image):
                return image
            case .remote:
                return nil
            }
        }
    }
    var remoteImages: [File] {
        return images.flatMap {
            switch $0 {
            case .local:
                return nil
            case .remote(let file):
                return file
            }
        }
    }

    func append(_ image: UIImage) {
        images.append(.local(image: image))
    }

    func append(_ file: File) {
        images.append(.remote(file: file))
    }

    func removeAtIndex(_ index: Int) {
        images.remove(at: index)
    }
}

class EditProductViewModel: BaseViewModel, EditLocationDelegate {

    // real time cloudsight
    let proposedTitle = Variable<String>("")
    let titleDisclaimerStatus = Variable<TitleDisclaimerStatus>(.completed)
    fileprivate var userIsEditingTitle: Bool
    fileprivate var hasTitle: Bool {
        return (title != nil && title != "")
    }
    fileprivate var productIsNew: Bool {
        guard let creationDate = initialProduct.createdAt else { return true }
        return creationDate.isNewerThan(Constants.cloudsightTimeThreshold)
    }
    fileprivate var shouldAskForAutoTitle: Bool {
        // we ask for title if the product has less than 1h (or doesn't has creation date)
        // AND doesn't has one, or the user is editing the field
        return (!hasTitle || userIsEditingTitle) && productIsNew
    }
    fileprivate var requestTitleTimer: Timer?

    // Input
    var title: String? {
        didSet {
            checkChanges()
        }
    }
    var currency: Currency?
    var price: String? {
        didSet {
            checkChanges()
        }
    }
    var postalAddress: PostalAddress?
    var location: LGLocationCoordinates2D? {
        didSet {
            checkChanges()
        }
    }
    var category: ProductCategory? {
        didSet {
            checkChanges()
        }
    }
    var shouldShareInFB: Bool
    let maxImageCount = Constants.maxImageCount
    var descr: String? {
        didSet {
            checkChanges()
            delegate?.vmShouldUpdateDescriptionWithCount(descriptionCharCount)
        }
    }


    // Rx in-out
    let isFreePosting =  Variable<Bool>(false)

    // Rx output
    let titleAutogenerated = Variable<Bool>(false)
    let titleAutotranslated = Variable<Bool>(false)
    let locationInfo = Variable<String>("")
    let loadingProgress = Variable<Float?>(nil)
    let saveButtonEnabled = Variable<Bool>(false)

    // Data
    var productImages: ProductImages
    var images: [EditProductImageType] {
        return productImages.images
    }
    fileprivate let initialProduct: Product
    fileprivate var savedProduct: Product?
    fileprivate var categories: [ProductCategory] = []
    fileprivate var shouldTrack: Bool = true
    
    // Repositories
    let myUserRepository: MyUserRepository
    let productRepository: ProductRepository
    let categoryRepository: CategoryRepository
    let locationManager: LocationManager
    let tracker: Tracker
    let featureFlags: FeatureFlaggeable

    // Delegate
    weak var delegate: EditProductViewModelDelegate?
    var closeCompletion: ((Product?) -> Void)?

    // Rx
    let disposeBag = DisposeBag()

    
    // MARK: - Lifecycle
    
    convenience init(product: Product) {
        let myUserRepository = Core.myUserRepository
        let productRepository = Core.productRepository
        let categoryRepository = Core.categoryRepository
        let locationManager = Core.locationManager
        let tracker = TrackerProxy.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        self.init(myUserRepository: myUserRepository,
                  productRepository: productRepository,
                  categoryRepository: categoryRepository,
                  locationManager: locationManager,
                  tracker: tracker, product: product,
                  featureFlags: featureFlags)
    }
    
    init(myUserRepository: MyUserRepository,
         productRepository: ProductRepository,
         categoryRepository: CategoryRepository,
         locationManager: LocationManager,
         tracker: Tracker,
         product: Product,
         featureFlags: FeatureFlaggeable) {
        self.myUserRepository = myUserRepository
        self.productRepository = productRepository
        self.categoryRepository = categoryRepository
        self.locationManager = locationManager
        self.tracker = tracker
        self.featureFlags = featureFlags
        self.initialProduct = product

        self.title = product.title
        
        self.titleAutotranslated.value = product.isTitleAutoTranslated(Core.countryHelper)
        self.titleAutogenerated.value = product.isTitleAutoGenerated

        self.proposedTitle.value = product.nameAuto ?? ""
        self.userIsEditingTitle = false

        self.price = product.price.value > 0 ? String.fromPriceDouble(product.price.value) : nil

        currency = product.currency
        if let descr = product.description {
            self.descr = descr
        }

        self.postalAddress = product.postalAddress
        self.location = product.location

        self.locationInfo.value = product.postalAddress.zipCodeCityString ?? ""

        self.category = product.category

        self.productImages = ProductImages()
        for file in product.images { productImages.append(file) }

        self.shouldShareInFB = myUserRepository.myUser?.facebookAccount != nil
        self.isFreePosting.value = featureFlags.freePostingModeAllowed && product.price.free
        super.init()

        setupCategories()
        setupRxBindings()
        trackStart()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        startTimer()
    }

    override func didBecomeInactive() {
        super.didBecomeInactive()
        stopTimer()
    }
    
    
    // MARK: - methods

    func closeButtonPressed() {
        if saveButtonEnabled.value {
            showCloseWChangesAlert()
        } else {
            closeEdit()
        }
    }

    var numberOfImages: Int {
        return images.count
    }
    
    func imageAtIndex(_ index: Int) -> EditProductImageType {
        return images[index]
    }
    
    var categoryName: String? {
        return category?.name
    }
    
    var descriptionCharCount: Int {
        guard let descr = descr else { return Constants.productDescriptionMaxLength }
        return Constants.productDescriptionMaxLength-descr.characters.count
    }
    
    func appendImage(_ image: UIImage) {
        productImages.append(image)
        delegate?.vmDidAddOrDeleteImage()
        checkChanges()
    }

    func deleteImageAtIndex(_ index: Int) {
        productImages.removeAtIndex(index)
        delegate?.vmDidAddOrDeleteImage()
        checkChanges()
    }

    func sendButtonPressed() {
        let error = validate()
        if let actualError = error {
            showError(actualError)
            trackValidationFailedWithError(actualError)
        } else {
            updateProduct()
        }
    }

    var fbShareContent: FBSDKShareLinkContent? {
        if let product = savedProduct {
            return ProductSocialMessage(product: product, fallbackToStore: false).fbShareContent
        }
        return nil
    }

    func openMap() {
        var shouldAskForPermission = true
        var permissionsActionBlock: ()->() = {}
        // check location enabled
        switch locationManager.locationServiceStatus {
        case let .enabled(authStatus):
            switch authStatus {
            case .notDetermined:
                shouldAskForPermission = true
                permissionsActionBlock = {  [weak self] in self?.locationManager.startSensorLocationUpdates() }
            case .restricted, .denied:
                shouldAskForPermission = true
                permissionsActionBlock = { [weak self] in self?.openLocationAppSettings() }
            case .authorized:
                shouldAskForPermission = false
            }
        case .disabled:
            shouldAskForPermission = true
            permissionsActionBlock = { [weak self] in self?.openLocationAppSettings() }
        }

        if shouldAskForPermission {
            // not enabled
            let okAction = UIAction(interface: UIActionInterface.styledText(LGLocalizedString.commonOk,
                .standard), action: permissionsActionBlock)
            let alertIcon = UIImage(named: "ic_location_alert")
            delegate?.vmShowAlertWithTitle(LGLocalizedString.editProductLocationAlertTitle,
                                           text: LGLocalizedString.editProductLocationAlertText,
                                           alertType: .iconAlert(icon: alertIcon), actions: [okAction])
        } else {
            // enabled
            let initialPlace = Place(postalAddress: nil, location: locationManager.currentAutoLocation?.location)
            let locationVM = EditLocationViewModel(mode: .editProductLocation, initialPlace: initialPlace)
            locationVM.locationDelegate = self
            delegate?.vmShouldOpenMapWithViewModel(locationVM)
        }
    }

    func fbSharingFinishedOk() {
        shouldTrack = true
        trackSharedFB()
        delay(Constants.fbSdkRequiredDelay) { [weak self] in
            self?.showSuccessMessageAndClose()
        }
    }

    func fbSharingFinishedWithError() {
        shouldTrack = true
        delay(Constants.fbSdkRequiredDelay) { [weak self] in
            self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.sellSendErrorSharingFacebook) { [weak self] in
                self?.showSuccessMessageAndClose()
            }
        }
    }

    func fbSharingCancelled() {
        shouldTrack = true
        delay(Constants.fbSdkRequiredDelay) { [weak self] in
            self?.showSuccessMessageAndClose()
        }
    }


    // MARK: - Private methods

    private func startTimer() {
        guard shouldAskForAutoTitle else { return }
        requestTitleTimer = Timer.scheduledTimer(timeInterval: Constants.cloudsightRequestRepeatInterval, target: self,
                                                                   selector: #selector(getAutoGeneratedTitle),
                                                                   userInfo: nil, repeats: true)
        requestTitleTimer?.fire()
    }

    fileprivate func stopTimer() {
        requestTitleTimer?.invalidate()
    }

    private func setupRxBindings() {
        isFreePosting.asObservable().bindNext { [weak self] _ in self?.checkChanges() }.addDisposableTo(disposeBag)
    }

    private func checkChanges() {
        var hasChanges = false
        if productImages.localImages.count > 0 || initialProduct.images.count != productImages.remoteImages.count  {
            hasChanges = true
        }
        else if (initialProduct.title ?? "") != (title ?? "") {
            hasChanges = true
        }
        else if initialProduct.price.value != Double(price ?? "0") {
            hasChanges = true
        }
        else if (initialProduct.descr ?? "") != (descr ?? "") {
            hasChanges = true
        }
        else if initialProduct.category != category {
            hasChanges = true
        }
        else if initialProduct.location != location {
            hasChanges = true
        }
        else if initialProduct.price.free != isFreePosting.value {
            hasChanges = true
        }
        saveButtonEnabled.value = hasChanges
    }

    private func validate() -> ProductCreateValidationError? {
        
        if images.count < 1 {
            return .noImages
        } else if descriptionCharCount < 0 {
            return .longDescription
        } else if category == nil {
            return .noCategory
        }
        return nil
    }

    private func updateProduct() {
        guard let category = category else {
            showError(.noCategory)
            return
        }
        let name = title ?? ""
        let description = (descr ?? "").stringByRemovingEmoji()

        let priceAmount = isFreePosting.value && featureFlags.freePostingModeAllowed ? ProductPrice.free : ProductPrice.normal((price ?? "0").toPriceDouble())
        let currency = initialProduct.currency

        let editedProduct = productRepository.updateProduct(initialProduct, name: name, description: description,
                                                            price: priceAmount, currency: currency, location: location,
                                                            postalAddress: postalAddress, category: category)
        saveTheProduct(editedProduct, withImages: productImages)
    }
    
    private func saveTheProduct(_ product: Product, withImages images: ProductImages) {

        loadingProgress.value = 0
        
        let localImages = images.localImages
        let remoteImages = images.remoteImages
        
        let commonCompletion: ListingCompletion = { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.loadingProgress.value = nil
            if let actualProduct = result.value {
                strongSelf.savedProduct = actualProduct
                strongSelf.trackComplete(actualProduct)
                strongSelf.finishedSaving()
            } else if let error = result.error {
                let newError = ProductCreateValidationError(repoError: error)
                strongSelf.showError(newError)
            }
        }

        let progressBlock: (Float) -> Void = { [weak self] progress in self?.loadingProgress.value = progress }
        
        if let _ = product.objectId {
            productRepository.update(product, oldImages: remoteImages, newImages: localImages, progress: progressBlock, completion: commonCompletion)
        } else {
            if localImages.isEmpty {
                productRepository.create(product, images: remoteImages, completion: commonCompletion)
            } else {
                productRepository.create(product, images: localImages, progress: progressBlock, completion: commonCompletion)
            }
        }
    }

    private func finishedSaving() {
        if let fbShareContent = fbShareContent, shouldShareInFB {
            shouldTrack = false
            delegate?.vmShareOnFbWith(content: fbShareContent)
        } else {
            showSuccessMessageAndClose()
        }
    }

    private func showSuccessMessageAndClose() {
        delegate?.vmShowAutoFadingMessage(LGLocalizedString.editProductSendOk) { [weak self] in
            self?.closeEdit()
        }
    }

    private func showCloseWChangesAlert() {
        let cancelAction = UIAction(
            interface: .button(LGLocalizedString.commonCancel, .secondary(fontSize: .medium, withBorder: true)),
            action: {})
        let discardAction = UIAction(
            interface: .button(LGLocalizedString.editProductUnsavedChangesAlertOk, .primary(fontSize: .medium)),
            action: { [weak self] in
                self?.closeEdit()
        })

        delegate?.vmHideKeyboard()
        delegate?.vmShowAlertWithTitle(nil, text: LGLocalizedString.editProductUnsavedChangesAlert,
                                       alertType: .plainAlert, actions: [cancelAction, discardAction])
    }

    private func closeEdit() {
        delegate?.vmHideKeyboard()
        delegate?.vmDismiss { [weak self] in
            self?.closeCompletion?(self?.savedProduct)
        }
    }

    private func showError(_ error: ProductCreateValidationError) {
        var completion: ((Void) -> Void)? = nil
        if !error.isFieldError {
            shouldTrack = false
            completion = { [weak self] in self?.shouldTrack = true }
        }
        delegate?.vmShowAutoFadingMessage(error.errorMessage, completion: completion)
    }

    private func openLocationAppSettings() {
        guard let settingsURL = URL(string:UIApplicationOpenSettingsURLString) else { return }
        UIApplication.shared.openURL(settingsURL)
    }
}


// MARK: - Categories

extension EditProductViewModel {

    var numberOfCategories: Int {
        return categories.count
    }

    func categoryNameAtIndex(_ index: Int) -> String {
        guard 0..<categories.count ~= index else { return "" }
        return categories[index].name
    }

    func selectCategoryAtIndex(_ index: Int) {
        guard 0..<categories.count ~= index else { return }
        category = categories[index]
        delegate?.vmDidSelectCategoryWithName(category?.name ?? "")
    }

    fileprivate func setupCategories() {
        categoryRepository.index(filterVisible: true) { [weak self] result in
            guard let categories = result.value else { return }
            self?.categories = categories
        }
    }
}


// MARK: - EditLocationDelegate

extension EditProductViewModel {
    func editLocationDidSelectPlace(_ place: Place) {
        location = place.location
        postalAddress = place.postalAddress
        locationInfo.value = place.postalAddress?.zipCodeCityString ?? ""
    }
}


// MARK: - Cloudsight in real time

extension EditProductViewModel {
    dynamic func getAutoGeneratedTitle() {
        guard let productId = initialProduct.objectId, shouldAskForAutoTitle else {
            stopTimer()
            return
        }
        titleDisclaimerStatus.value = .loading
        productRepository.retrieve(productId) { [weak self] result in
            if let value = result.value {
                guard let proposedTitle = value.nameAuto else { return }
                self?.stopTimer()
                self?.titleDisclaimerStatus.value = .ready
                self?.proposedTitle.value = proposedTitle
            }
        }
    }

    /**
     Method called when the title textfield gets the focus
     */
    func userWritesTitle(_ text: String?) {
        guard productIsNew else { return }
        userIsEditingTitle = true
        titleAutotranslated.value = false
        titleAutogenerated.value = false
        titleDisclaimerStatus.value = proposedTitle.value.isEmpty ? .loading : .ready
    }

    func userFinishedEditingTitle(_ text: String) {
        guard productIsNew else { return }
        if text.isEmpty {
            titleLeftBlank()
        } else if text == proposedTitle.value {
            titleAutotranslated.value = true
            titleAutogenerated.value = true
            titleDisclaimerStatus.value = .completed
        } else {
            titleAutotranslated.value = false
            titleAutogenerated.value = false
            titleDisclaimerStatus.value = proposedTitle.value.isEmpty ? .loading : .ready
        }
    }

    /**
     Method called when the title textfield loses the focus, and is empty
     */
    func titleLeftBlank() {
        guard productIsNew else { return }
        userIsEditingTitle = false
        titleDisclaimerStatus.value = proposedTitle.value.isEmpty ? .loading : .ready
    }

    /**
     Method called when the user presses the suggested title button
     */
    func userSelectedSuggestedTitle() {
        titleAutotranslated.value = true
        titleAutogenerated.value = true
        titleDisclaimerStatus.value = .completed
    }
}


// MARK: - Trackings

extension EditProductViewModel {

    fileprivate func trackStart() {
        let myUser = myUserRepository.myUser
        let event = TrackerEvent.productEditStart(myUser, product: initialProduct)
        trackEvent(event)
    }

    fileprivate func trackValidationFailedWithError(_ error: ProductCreateValidationError) {
        let myUser = myUserRepository.myUser
        let event = TrackerEvent.productEditFormValidationFailed(myUser, product: initialProduct,
                                                                 description: error.description)
        trackEvent(event)
    }

    fileprivate func trackSharedFB() {
        let myUser = myUserRepository.myUser
        let event = TrackerEvent.productEditSharedFB(myUser, product: savedProduct)
        trackEvent(event)
    }

    fileprivate func trackComplete(_ product: Product) {
        // if nothing is changed, we don't track the edition
        let editedFields = editFieldsComparedTo(product)
        guard !editedFields.isEmpty  else { return }

        let myUser = myUserRepository.myUser
        let event = TrackerEvent.productEditComplete(myUser, product: product, category: category,
                                                     editedFields: editedFields)
        trackEvent(event)
    }

    fileprivate func trackEvent(_ event: TrackerEvent) {
        if shouldTrack {
            tracker.trackEvent(event)
        }
    }

    fileprivate func editFieldsComparedTo(_ product: Product) -> [EventParameterEditedFields] {
        var editedFields: [EventParameterEditedFields] = []

        if productImages.localImages.count > 0 || initialProduct.images.count != productImages.remoteImages.count  {
            editedFields.append(.picture)
        }
        if (initialProduct.name ?? "") != (product.name ?? "") {
            editedFields.append(.title)
        }
        if initialProduct.priceString() != product.priceString() {
            editedFields.append(.price)
        }
        if (initialProduct.descr ?? "") != (product.descr ?? "") {
            editedFields.append(.description)
        }
        if initialProduct.category != product.category {
            editedFields.append(.category)
        }
        if initialProduct.location != product.location {
            editedFields.append(.location)
        }
        if shareInFbChanged() {
            editedFields.append(.share)
        }
        if initialProduct.price.free != product.price.free {
            editedFields.append(.freePosting)
        }
        return editedFields
    }

    private func shareInFbChanged() -> Bool {
        let fbLogin = myUserRepository.myUser?.facebookAccount != nil
        return fbLogin != shouldShareInFB
    }
}


// MARK: - ProductCreateValidationError helper

private enum ProductCreateValidationError: Error {
    case network
    case internalError
    case noImages
    case noTitle
    case noPrice
    case noDescription
    case longDescription
    case noCategory
    case serverError(code: Int?)

    init(repoError: RepositoryError) {
        switch repoError {
        case .internalError:
            self = .internalError
        case .network:
            self = .network
        case .serverError, .notFound, .forbidden, .unauthorized, .tooManyRequests, .userNotVerified:
            self = .serverError(code: repoError.errorCode)
        }
    }

    var isFieldError: Bool {
        switch (self) {
        case .network, .internalError, .serverError:
            return false
        case .noImages, .noTitle, .noPrice, .noDescription, .longDescription, .noCategory:
            return true
        }
    }

    var description: String {
        switch self {
        case .network:
            return "network"
        case .internalError:
            return "internal"
        case .noImages:
            return "no images present"
        case .noTitle:
            return "no title"
        case .noPrice:
            return "invalid price"
        case .noDescription:
            return "no description"
        case .longDescription:
            return "description too long"
        case .noCategory:
            return "no category selected"
        case .serverError:
            return "internal server error"
        }
    }

    var errorMessage: String {
        switch (self) {
        case .network, .internalError, .serverError:
            return LGLocalizedString.editProductSendErrorUploadingProduct
        case .noImages:
            return LGLocalizedString.sellSendErrorInvalidImageCount
        case .noTitle:
            return LGLocalizedString.sellSendErrorInvalidTitle
        case .noPrice:
            return LGLocalizedString.sellSendErrorInvalidPrice
        case .noDescription:
            return LGLocalizedString.sellSendErrorInvalidDescription
        case .longDescription:
            return LGLocalizedString.sellSendErrorInvalidDescriptionTooLong(Constants.productDescriptionMaxLength)
        case .noCategory:
            return LGLocalizedString.sellSendErrorInvalidCategory
        }
    }
}
