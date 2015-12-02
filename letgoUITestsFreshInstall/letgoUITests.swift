//
//  letgoUITests.swift
//  letgoUITests
//
//  Created by Albert Hernández López on 27/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import XCTest

class letgoUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let app = XCUIApplication()
        app.launch()
        app.skipOnBoarding()
        
        // Wait the collection to have cells
        let collectionViewsQuery = app.collectionViews
        let predicate = NSPredicate(format: "count > 0")
        expectationForPredicate(predicate, evaluatedWithObject: collectionViewsQuery, handler: nil)
        waitForExpectationsWithTimeout(10, handler: nil)
        
        let resultsCount = collectionViewsQuery.cells.count
        XCTAssert(resultsCount > 0, "There should be products.")
        
    }
 }
