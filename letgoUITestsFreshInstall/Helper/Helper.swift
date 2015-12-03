//
//  Helper.swift
//  LetGo
//
//  Created by Albert Hernández López on 02/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import XCTest

struct Helper {
    let app: XCUIApplication
    
    func skipOnBoarding() {
        app.buttons["Skip"].tap()
    }
}
