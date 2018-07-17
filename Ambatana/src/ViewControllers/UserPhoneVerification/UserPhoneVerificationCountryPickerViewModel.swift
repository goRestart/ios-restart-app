import LGCoreKit
import RxSwift
import RxCocoa
import LGComponents

protocol UserPhoneVerificationCountryPickerDelegate: class {
    func didSelect(country: PhoneVerificationCountry)
}

final class UserPhoneVerificationCountryPickerViewModel: BaseViewModel {

    weak var navigator: UserPhoneVerificationNavigator?
    weak var delegate: UserPhoneVerificationCountryPickerDelegate?

    private let countryHelper: CountryHelper

    let filteredCountries = Variable<[PhoneVerificationCountry]>([])
    private var allCountries: [PhoneVerificationCountry] = []

    init(countryHelper: CountryHelper = Core.countryHelper) {
        self.countryHelper = countryHelper
        super.init()
    }

    func filterCountries(by query: String) {
        filteredCountries.value = allCountries.filter { country -> Bool in
            return country.name.lowercased().contains(query.lowercased())
                || String(country.callingCode).contains(query.lowercased())
        }
    }

    func didSelect(country: PhoneVerificationCountry) {
        delegate?.didSelect(country: country)
        navigator?.closeCountrySelector()
    }


    func loadCountriesList() {
        allCountries = getCountriesList()
        filteredCountries.value = allCountries
    }

    private func getCountriesList() -> [PhoneVerificationCountry] {
        return countryHelper
            .fullCountryInfoList()
            .filter { $0.countryPhoneCode != "" }
            .map { PhoneVerificationCountry(regionCode: $0.countryCode,
                                            callingCode: $0.countryPhoneCode) }
            .sorted { $0.name < $1.name }
    }
}
