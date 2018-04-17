//
//  SMSPhoneInputViewModel.swift
//  LetGo
//
//  Created by Sergi Gracia on 03/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift
import RxCocoa
import CoreTelephony

struct PhoneVerificationCountry {
    let regionCode: String
    let callingCode: String

    private let currentLocale: Locale

    init(regionCode: String,
         callingCode: String,
         locale: Locale = Locale.current) {
        self.regionCode = regionCode
        self.callingCode = callingCode
        self.currentLocale = locale
    }

    var name: String {
        return currentLocale.localizedString(forRegionCode: regionCode) ?? ""
    }
}

final class UserPhoneVerificationNumberInputViewModel: BaseViewModel {

    weak var navigator: UserPhoneVerificationNavigator?

    private let locationManager: LocationManager
    private let locationRepository: LocationRepository
    private let telephonyNetworkInfo: CTTelephonyNetworkInfo
    private let countryHelper: CountryHelper

    var country = Variable<PhoneVerificationCountry?>(nil)
    var isContinueActionEnabled = Variable<Bool>(false)

    init(locationManager: LocationManager = Core.locationManager,
         locationRepository: LocationRepository = Core.locationRepository,
         countryHelper: CountryHelper = Core.countryHelper,
         telephonyNetworkInfo: CTTelephonyNetworkInfo = CTTelephonyNetworkInfo()) {
        self.locationManager = locationManager
        self.locationRepository = locationRepository
        self.telephonyNetworkInfo = telephonyNetworkInfo
        self.countryHelper = countryHelper
        super.init()
        retrieveCurrentLocationCountry()
    }

    private func retrieveCurrentLocationCountry() {
        let hasRetrievedFromTelephonyNetwork = retrieveCountryFromTelephonyNetwork()
        guard !hasRetrievedFromTelephonyNetwork else { return }
        retrieveCountryFromLocationManager()
    }

    private func retrieveCountryFromTelephonyNetwork() -> Bool {
        guard let countryCode = telephonyNetworkInfo.countryCode else { return false }
        updateCurrentLocationCountry(with: countryCode)
        return true
    }

    private func retrieveCountryFromLocationManager() {
        guard let location = locationManager.currentAutoLocation?.location else { return }
        locationRepository.retrievePostalAddress(location: location) { [weak self] result in
            switch result {
            case .success(let place):
                guard let countryCode = place.postalAddress?.countryCode else { return }
                self?.updateCurrentLocationCountry(with: countryCode)
            case .failure(_):
                // FIXME: waiting for product specs
                break
            }
        }
    }

    private func updateCurrentLocationCountry(with countryCode: String) {
        guard let callingCode = retrieveCallingCode(for: countryCode) else { return }
        country.value = PhoneVerificationCountry(regionCode: countryCode, callingCode: callingCode)
    }

    private func retrieveCallingCode(for regionCode: String) -> String? {
        let countryInfo = countryHelper.countryInfoForCountryCode(regionCode)
        return countryInfo?.countryPhoneCode
    }

    // MARK: - Actions

    func didChangePhone(number: String?) {
        isContinueActionEnabled.value = number?.isValidPhoneNumber ?? false
    }

    func didTapCountryButton() {
        navigator?.openCountrySelector()
    }

    func didTapContinueButton(with phoneNumber: String) {
        guard let callingCode = country.value?.callingCode else { return }
        let fullNumber = "+\(callingCode) \(phoneNumber)"
        navigator?.openCodeInput(sentTo: fullNumber)
    }
}

// MARK: - Validtors

private extension String {
    var isValidPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber
                    && res.range.location == 0
                    && res.range.length == self.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
}
