//
//  MockCountryConfigurable.swift
//  LetGo
//
//  Created by Albert Hernández López on 09/06/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode

class MockCountryConfigurable: CountryConfigurable {
    var countryCode: String?
    
    init() {
        countryCode = ["US", "TR", "ES", "CA", "SE", "FI", "FR"].random()
    }
}
