//
//  CountryInfoDAO.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 01/10/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public protocol CountryInfoDAO {
    func fetchCountryInfoWithCurrencyCode(currencyCode: String) -> CountryInfo?
    func fetchCountryInfoWithCountryCode(countryCode: String) -> CountryInfo?
}
