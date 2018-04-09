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

    let filteredCountries = Variable<[CountryPhoneCode]>([])
    private var allCountries: [CountryPhoneCode] = []

    init(fake: String? = "") {
        super.init()
    }

    func filterCountries(by query: String) {
        filteredCountries.value = allCountries.filter { country -> Bool in
            return country.name.lowercased().contains(query.lowercased())
                || String(country.code).contains(query.lowercased())
        }
    }

    func didSelect(country: CountryPhoneCode) {
        // FIXME: implement it
    }


    func loadCountriesList() {
        allCountries = getCountriesList()
        filteredCountries.value = allCountries // FIXME: fake data
    }

    private func getCountriesList() -> [CountryPhoneCode] {
        return [
            CountryPhoneCode(code: 355, name: "Albania"),
            CountryPhoneCode(code: 342, name: "Chile"),
            CountryPhoneCode(code: 342, name: "Nigeria"),
            CountryPhoneCode(code: 342, name: "Lesotho"),
        ]
    }
}
