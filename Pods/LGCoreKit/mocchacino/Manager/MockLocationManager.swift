import CoreLocation
import Result
import RxSwift

open class MockLocationManager: LocationManager {
    public var myUserResult: MyUserResult
    public var locationEventsPublishSubject: PublishSubject<LocationEvent>
    public var hasLocationUpdates: Bool


    // MARK: - Lifecycle

    public init() {
        self.myUserResult = MyUserResult(value: MockMyUser.makeMock())
        self.locationEventsPublishSubject = PublishSubject<LocationEvent>()
        self.hasLocationUpdates = false
        self.didAcceptPermissions = Bool.makeRandom()
        self.isManualLocationEnabled = Bool.makeRandom()
        self.manualLocationThreshold = Double.makeRandom()
        self.currentLocation = LGLocation.makeMock()
        self.currentAutoLocation = LGLocation.makeMock()
        self.locationServiceStatus = .enabled(.notDetermined)
    }


    // MARK: - LocationManager

    public var locationEvents: Observable<LocationEvent> {
        return locationEventsPublishSubject.asObserver()
    }

    public var didAcceptPermissions: Bool
    public var isManualLocationEnabled: Bool
    public var manualLocationThreshold: Double

    public func initialize() {
    }

    public var currentLocation: LGLocation?

    public var currentAutoLocation: LGLocation?

    public func setManualLocation(_ location: CLLocation,
                                  postalAddress: PostalAddress,
                                  completion: MyUserCompletion?) {
        delay(result: myUserResult, completion: completion)
    }

    public func setAutomaticLocation(_ userUpdateCompletion: MyUserCompletion?) {
        delay(result: myUserResult, completion: userUpdateCompletion)
    }

    public var locationServiceStatus: LocationServiceStatus

    @discardableResult
    public func startSensorLocationUpdates() -> LocationServiceStatus {
        switch locationServiceStatus {
        case .disabled:
            break
        case .enabled(let authStatus):
            switch authStatus {
            case .notDetermined, .restricted, .denied:
                break
            case .authorized:
                hasLocationUpdates = true
            }
        }
        return locationServiceStatus
    }

    public func stopSensorLocationUpdates() {
        hasLocationUpdates = false
    }
    
    public func shouldAskForLocationPermissions() -> Bool {
        switch locationServiceStatus {
        case .disabled:
            return false
        case .enabled(let authStatus):
            switch authStatus {
            case .notDetermined:
                return true
            case .restricted, .denied, .authorized:
                return false
            }
        }
    }
}
