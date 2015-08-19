//
//  CountryCurrencyInfoDAO.swift
//  LGCoreKit
//
//  Created by AHL on 23/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public protocol CountryCurrencyInfoDAO {
    func fetchCountryCurrencyInfoWithCurrencyCode(currencyCode: String) -> CountryCurrencyInfo?
    func fetchCountryCurrencyInfoWithCountryCode(countryCode: String) -> CountryCurrencyInfo?
}
