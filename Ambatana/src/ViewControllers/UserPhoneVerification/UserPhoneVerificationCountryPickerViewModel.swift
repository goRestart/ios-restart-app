//
//  UserPhoneVerificationCountryPickerViewModel.swift
//  LetGo
//
//  Created by Sergi Gracia on 05/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift
import RxCocoa

final class UserPhoneVerificationCountryPickerViewModel: BaseViewModel {

    weak var navigator: UserPhoneVerificationNavigator?

    let filteredCountries = Variable<[Country]>([])
    private var allCountries: [Country] = []

    init(fake: String? = "") {
        super.init()
    }

    func filterCountries(by query: String) {
        filteredCountries.value = allCountries.filter { country -> Bool in
            return country.name.lowercased().contains(query.lowercased())
                || String(country.callingCode).contains(query.lowercased())
        }
    }

    func didSelect(country: Country) {
        // FIXME: implement it
    }


    func loadCountriesList() {
        allCountries = getCountriesList()
        filteredCountries.value = allCountries // FIXME: fake data
    }

    private func getCountriesList() -> [Country] {
        return [
            Country(regionCode: "US", callingCode: 355),
            Country(regionCode: "ES", callingCode: 342),
            Country(regionCode: "AN", callingCode: 342),
            Country(regionCode: "AL", callingCode: 342),
        ]
    }
}
