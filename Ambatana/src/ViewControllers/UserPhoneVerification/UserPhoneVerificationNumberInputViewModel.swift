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
    let name: String

    init(regionCode: String,
         callingCode: String,
         locale: Locale = Locale.current) {
        self.regionCode = regionCode
        self.callingCode = callingCode
        self.name = locale.localizedString(forRegionCode: regionCode) ?? ""
    }
}

final class UserPhoneVerificationNumberInputViewModel: BaseViewModel {

    weak var navigator: UserPhoneVerificationNavigator?
    weak var delegate: BaseViewModelDelegate?

    private let myUserRepository: MyUserRepository
    private let locationManager: LocationManager
    private let locationRepository: LocationRepository
    private let telephonyNetworkInfo: CTTelephonyNetworkInfo
    private let countryHelper: CountryHelper

    var country = Variable<PhoneVerificationCountry?>(nil)
    var isContinueActionEnabled = Variable<Bool>(false)

    init(myUserRepository: MyUserRepository = Core.myUserRepository,
         locationManager: LocationManager = Core.locationManager,
         locationRepository: LocationRepository = Core.locationRepository,
         countryHelper: CountryHelper = Core.countryHelper,
         telephonyNetworkInfo: CTTelephonyNetworkInfo = CTTelephonyNetworkInfo()) {
        self.myUserRepository = myUserRepository
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
            case .failure(_): break
            }
        }
    }

    private func updateCurrentLocationCountry(with countryCode: String) {
        guard let callingCode = retrieveCallingCode(for: countryCode) else { return }
        country.value = PhoneVerificationCountry(regionCode: countryCode, callingCode: callingCode)
    }

    private func retrieveCallingCode(for regionCode: String) -> String? {
        let countryInfo = countryHelper.countryInfoForCountryCode(regionCode.uppercased())
        return countryInfo?.countryPhoneCode
    }

    // MARK: - Actions

    func didChangePhone(number: String?) {
        isContinueActionEnabled.value = number?.isValidPhoneNumber ?? false
    }

    func didTapCountryButton() {
        navigator?.openCountrySelector(withDelegate: self)
    }

    func didTapContinueButton(with phoneNumber: String) {
        guard let callingCode = country.value?.callingCode else { return }
        requestCode(withCallingCode: callingCode, phoneNumber: phoneNumber) { [weak self] in
            self?.navigator?.openCodeInput(sentTo: phoneNumber, with: callingCode)
        }
    }

    private func requestCode(withCallingCode callingCode: String, phoneNumber: String, completion: (()->())?) {
        delegate?.vmShowLoading(LGLocalizedString.phoneVerificationNumberInputViewSendingMessage)
        myUserRepository.requestSMSCode(prefix: "+\(callingCode)", phone: phoneNumber) { [weak self] result in
            switch result {
            case .success:
                let title = LGLocalizedString.phoneVerificationNumberInputViewConfirmationTitle
                let message = LGLocalizedString.phoneVerificationNumberInputViewConfirmationMessage(callingCode, phoneNumber)
                self?.delegate?.vmHideLoading(nil) {
                    self?.delegate?.vmShowAutoFadingMessage(title: title,
                                                            message: message,
                                                            time: 5,
                                                            completion: completion)
                }
            case .failure(_):
                self?.delegate?.vmHideLoading(LGLocalizedString.phoneVerificationNumberInputViewErrorMessage,
                                              afterMessageCompletion: nil)
            }
        }
    }
}

extension UserPhoneVerificationNumberInputViewModel: UserPhoneVerificationCountryPickerDelegate {
    func didSelect(country: PhoneVerificationCountry) {
        self.country.value = country
    }
}

// MARK: - Validators

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