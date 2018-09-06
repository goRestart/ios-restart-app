import RxSwift

final class LGServicesInfoRepository: ServicesInfoRepository {
    typealias ServicesInfoCache = ServicesInfoDAO & ServicesInfoRetrievable
    
    private let dataSource: ServicesInfoDataSource
    private let cache: ServicesInfoCache
    private let locationManager: LocationManager
    private var disposeBag = DisposeBag()
    
    init(dataSource: ServicesInfoDataSource, cache: ServicesInfoCache, locationManager: LocationManager) {
        self.dataSource = dataSource
        self.cache = cache
        self.locationManager = locationManager
        setupRX()
    }
    
    func loadFirstRunCacheIfNeeded(jsonURL: URL) {
        guard cache.servicesTypes.isEmpty else { return }
        do {
            let data = try Data(contentsOf: jsonURL)
            let jsonServiceTypesList = try JSONSerialization.jsonObject(with: data, options: [])
            guard let serviceTypes = decoder(jsonServiceTypesList) else { return }
            cache.save(servicesInfo: serviceTypes, localeId: nil)
        } catch let error {
            logMessage(.verbose, type: CoreLoggingOptions.database, message: "Failed to create Services Info first run cache: \(error)")
        }
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
    
    func serviceAllSubtypesSorted() -> [ServiceSubtype] {
        return cache.serviceAllSubtypesSorted()
    }
    
    private func requestServicesFile(for localeId: String) {
        dataSource.index(locale: localeId) { [weak self] result in
            if case let .success(value) = result {
                if !value.isEmpty {
                    self?.cache.save(servicesInfo: value, localeId: localeId)
                }
            }
        }
    }
    
    private func localeIdentifier(forLanguageCode languageCode: String?, countryCode: String?) -> String? {
        guard let languageCode = languageCode, let countryCode = countryCode else { return nil }
        return Locale.identifier(fromComponents: [NSLocale.Key.languageCode.rawValue: languageCode,
                                                  NSLocale.Key.countryCode.rawValue: countryCode])
    }
    
    private func decoder(_ object: Any) -> [ServiceType]? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        do {
            let serviceTypes = try JSONDecoder().decode(FailableDecodableArray<LGServiceType>.self, from: data)
            return serviceTypes.validElements
        } catch {
            logMessage(.debug, type: .parsing, message: "could not parse LGServiceTypes \(object)")
        }
        return nil
    }
}


// MARK:- RX

extension LGServicesInfoRepository {
    
    private func setupRX() {
        locationManager.locationEvents.filter { $0 == .locationUpdate }.subscribeNext { [weak self] _ in
            guard
                let cache = self?.cache,
                let newLocationCountryCode = self?.locationManager.currentLocation?.postalAddress?.countryCode,
                let localeId = self?.localeIdentifier(forLanguageCode: Locale.autoupdatingCurrent.languageCode,
                                                      countryCode: newLocationCountryCode)
                else {
                    return
            }
            let localeHasChanged = localeId != cache.localeId
            if localeHasChanged || cache.isExpired {
                self?.requestServicesFile(for: localeId)
            }
        }.disposed(by: disposeBag)
    }
}
