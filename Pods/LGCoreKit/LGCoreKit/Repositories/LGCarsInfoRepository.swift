import Result
import RxSwift

final class LGCarsInfoRepository: CarsInfoRepository {
    private let dataSource: CarsInfoDataSource
    private let cache: CarsInfoDAO
    private let locationManager: LocationManager

    private var disposeBag = DisposeBag()


    // MARK: - Lifecycle

    init(dataSource: CarsInfoDataSource, cache: CarsInfoDAO, locationManager: LocationManager) {
        self.dataSource = dataSource
        self.cache = cache
        self.locationManager = locationManager
        setupRx()
    }

    func loadFirstRunCacheIfNeeded(jsonURL: URL) {
        guard cache.carsMakesList.isEmpty else { return }
        do {
            let data = try Data(contentsOf: jsonURL)
            let jsonCarMakesList = try JSONSerialization.jsonObject(with: data, options: [])
            guard let carMakesList = decoder(jsonCarMakesList) else { return }
            cache.save(carsInfo: carMakesList, countryCode: nil)
        } catch let error {
            logMessage(.verbose, type: CoreLoggingOptions.database, message: "Failed to create Cars Info first run cache: \(error)")
        }
    }

    func retrieveCarsMakes() -> [CarsMake] {
        return cache.carsMakesList
    }

    func retrieveCarsModelsFormake(makeId: String) -> [CarsModel] {
        return cache.modelsForMake(makeId: makeId)
    }

    func retrieveValidYears(withFirstYear firstYear: Int? = LGCoreKitConstants.carsFirstYear, ascending: Bool) -> [Int] {
        
        let nextYear = Date().nextYear()
        
        let yearsRange: CountableClosedRange<Int>
        
        if let firstYear = firstYear {
            // limited between 1900 and nextYear
            var modelFirstYear = max(LGCoreKitConstants.carsFirstYear, firstYear)
            modelFirstYear = min(modelFirstYear, nextYear)
            yearsRange = modelFirstYear...nextYear
        } else {
            yearsRange = LGCoreKitConstants.carsFirstYear...nextYear
        }
        
        let yearsList = Array(yearsRange)
        return ascending ? yearsList : yearsList.reversed()
        
    }
    
    func retrieveModelName(with makeId: String?, modelId: String?) -> String? {
        return cache.retrieveModelName(with: makeId, modelId: modelId)
    }
    func retrieveMakeName(with makeId: String?) -> String? {
        return cache.retrieveMakeName(with: makeId)
    }
    
    private func decoder(_ object: Any) -> [CarsMakeWithModels]? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        
        // Ignore cars makes that can't be decoded
        do {
            let carMakes = try JSONDecoder().decode(FailableDecodableArray<ApiCarsMake>.self, from: data)
            return carMakes.validElements
        } catch {
            logMessage(.debug, type: .parsing, message: "could not parse ApiCarsMake \(object)")
        }
        return nil
    }
    
    private func requestCarsInfoFile(for countryCode: String) {
        dataSource.index(countryCode: countryCode) { [weak self] result in
            if let value = result.value, !value.isEmpty {
                self?.cache.save(carsInfo: value, countryCode: countryCode)
            }
        }
    }


    // Rx

    private func setupRx() {
        locationManager.locationEvents.filter { $0 == .locationUpdate }.subscribeNext { [weak self] _ in
            guard
                let cache = self?.cache,
                let newLocationCountryCode = self?.locationManager.currentLocation?.postalAddress?.countryCode
                else {
                    return
            }
            let countryHasChanged = newLocationCountryCode != cache.countryCode
            if countryHasChanged || cache.isExpired {
                self?.requestCarsInfoFile(for: newLocationCountryCode)
            }
        }.disposed(by: disposeBag)
    }
}
