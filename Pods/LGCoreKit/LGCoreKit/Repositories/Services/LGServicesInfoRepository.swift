import RxSwift

final class LGServicesInfoRepository: ServicesInfoRepository {
    typealias ServicesInfoCache = ServicesInfoDAO & ServicesInfoRetrievable
    
    private let dataSource: ServicesInfoDataSource
    private let cache: ServicesInfoCache
    private let locationManager: LocationManager
    
    private var countryCode: String?
    private var disposeBag = DisposeBag()
    
    
    init(dataSource: ServicesInfoDataSource,
         cache: ServicesInfoCache,
         locationManager: LocationManager) {
        self.dataSource = dataSource
        self.cache = cache
        self.locationManager = locationManager
        setupRX()
    }
    
    func loadFirstRunCacheIfNeeded(jsonURL: URL) {
        cache.loadFirstRunCacheIfNeeded(jsonURL: jsonURL)
    }
    
    func refreshServicesFile() {
        /*
        let languageCode = Locale.autoupdatingCurrent.languageCode
        countryCode = locationManager.currentLocation?.postalAddress?.countryCode
        
        let localeId = localeIdentifier(forLanguageCode: languageCode,
                                        countryCode: countryCode)
        dataSource.index(locale: localeId) { [weak self] result in
            switch result {
            case .success(let value):
                if !value.isEmpty {
                    self?.cache.save(servicesInfo: value)
                }
            case .failure: break
            }
        }
         */
    }
    
    private func localeIdentifier(forLanguageCode languageCode: String?,
                                  countryCode: String?) -> String? {
        
        guard let languageCode = languageCode,
            let countryCode = countryCode else {
                return nil
        }
        
        return Locale.identifier(fromComponents: [NSLocale.Key.languageCode.rawValue: languageCode,
                                                  NSLocale.Key.countryCode.rawValue: countryCode])
    }
    
    func retrieveServiceTypes() -> [ServiceType] {
        return cache.servicesTypes
    }
    
    func serviceSubtypes(forServiceTypeId serviceTypeId: String) -> [ServiceSubtype] {
        return cache.serviceSubtypes(forServiceTypeId: serviceTypeId)
    }
    
    func serviceType(forServiceTypeId serviceTypeId: String) -> ServiceType? {
        return cache.serviceType(forServiceTypeId: serviceTypeId)
    }
    
    func serviceSubtype(forServiceSubtypeId serviceSubtypeId: String) -> ServiceSubtype? {
        return cache.serviceSubtype(forServiceSubtypeId: serviceSubtypeId)
    }
}


// MARK:- RX

extension LGServicesInfoRepository {
    
    private func setupRX() {
        locationManager.locationEvents.filter { $0 == .locationUpdate }.subscribeNext { [weak self] _ in
            guard let locationCountryCode = self?.locationManager.currentLocation?.postalAddress?.countryCode,
                locationCountryCode != self?.countryCode else { return }
            self?.refreshServicesFile()
            }.disposed(by: disposeBag)
    }
}
