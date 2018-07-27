import RxSwift
import LGCoreKit
import LGComponents

protocol PostListingBasicDetailViewModelDelegate: class {
    func postListingDetailDone(_ viewModel: PostListingBasicDetailViewModel)
}

class PostListingBasicDetailViewModel: BaseViewModel {
    weak var delegate: PostListingBasicDetailViewModelDelegate?

    // In variables
    let price = Variable<String>("")
    let title = Variable<String>("")
    let description = Variable<String>("")

    // In&Out variables
    let isFree = Variable<Bool>(false)
    let shareOnFacebook = Variable<Bool?>(nil)
    
    // Out variables
    var listingPrice: ListingPrice {
        guard !isFree.value else { return .free }
        return .normal(price.value.toPriceDouble())
    }
    
    var listingTitle: String? {
        return title.value.isEmpty ? nil : title.value
    }
    var listingDescription: String? {
        return description.value.isEmpty ? nil : description.value
    }
    let currencySymbol: String?
    private let featureFlags: FeatureFlaggeable
    private let keyValueStorage: KeyValueStorageable
    private let disposeBag = DisposeBag()
    var freeOptionAvailable: Bool {
        return featureFlags.freePostingModeAllowed
    }
    var shareOnFacebookAvailable: Bool {
        return featureFlags.frictionlessShare.isActive
    }

    override convenience  init() {
        var currencySymbol: String? = nil
        let featureFlags = FeatureFlags.sharedInstance
        if let countryCode = Core.locationManager.currentLocation?.countryCode {
            currencySymbol = Core.currencyHelper.currencyWithCountryCode(countryCode).symbol
        }
        let keyValueStorage = KeyValueStorage.sharedInstance
        self.init(currencySymbol: currencySymbol, featureFlags: featureFlags, keyValueStorage: keyValueStorage)
    }

    init(currencySymbol: String?, featureFlags: FeatureFlaggeable, keyValueStorage: KeyValueStorageable) {
        self.currencySymbol = currencySymbol
        self.featureFlags = featureFlags
        self.keyValueStorage = keyValueStorage
        super.init()
        updateShareOnFacebookFromKeyValueStorage()
    }

    private func updateShareOnFacebookFromKeyValueStorage() {
        guard shareOnFacebookAvailable else { return }
        shareOnFacebook.value = keyValueStorage[.sellAutoShareOnFacebook] ?? true
        shareOnFacebook.asObservable().subscribeNext { [weak self] shareOnFacebook in
            self?.keyValueStorage[.sellAutoShareOnFacebook] = shareOnFacebook
        }.disposed(by: disposeBag)
    }

    func freeCellPressed() {
        isFree.value = !isFree.value
    }

    func doneButtonPressed() {
        delegate?.postListingDetailDone(self)
    }

    func shareOnFacebookPressed() {
        guard let shareOnFacebook = shareOnFacebook.value else { return }
        self.shareOnFacebook.value = !shareOnFacebook
    }
}
