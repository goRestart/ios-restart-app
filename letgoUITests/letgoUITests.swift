//
//  letgoUITests.swift
//  letgoUITests
//
//  Created by Albert Hernández López on 02/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import XCTest

class letgoUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.

//        let app = XCUIApplication()
//        app.staticTexts["Sell Your Stuff"].tap()
//        app.scrollViews.otherElements.buttons["postingCameraCloseButton"].tap()
//        app.collectionViews["productListViewCollection"].staticTexts["Free"].tap()
//
//        let productcarouseldirectchattableTable = app.tables["productCarouselDirectChatTable"]
//        productcarouseldirectchattableTable.tap()
//        productcarouseldirectchattableTable.tap()
//        productcarouseldirectchattableTable.tap()
//        productcarouseldirectchattableTable.tap()
//        productcarouseldirectchattableTable.tap()
//        productcarouseldirectchattableTable.tap()
//        productcarouseldirectchattableTable.tap()
//        productcarouseldirectchattableTable.tap()
//
//        let letgogodmodeProductcarouselviewNavigationBar = app.navigationBars["LetGoGodMode.ProductCarouselView"]
//        let icCloseCarouselButton = letgogodmodeProductcarouselviewNavigationBar.buttons["ic close carousel"]
//        icCloseCarouselButton.tap()
//        letgogodmodeProductcarouselviewNavigationBar.buttons["navbar fav off"].tap()
//
//        let letgogodmodeMainsignupviewNavigationBar = app.navigationBars["LetGoGodMode.MainSignUpView"]
//        let mainsignupclosebuttonButton = letgogodmodeMainsignupviewNavigationBar.buttons["mainSignupCloseButton"]
//        mainsignupclosebuttonButton.tap()
//        letgogodmodeProductcarouselviewNavigationBar.buttons["navbar more"].tap()
//        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element(boundBy: 1).tap()
//        icCloseCarouselButton.tap()
//        icCloseCarouselButton.press(forDuration: 0.7);
//
//        let tabBarsQuery = app.tabBars
//        tabBarsQuery.buttons["1 item"].tap()
//        mainsignupclosebuttonButton.tap()
//        tabBarsQuery.children(matching: .button).element(boundBy: 3).tap()
//        mainsignupclosebuttonButton.tap()
//        tabBarsQuery.children(matching: .button).element(boundBy: 4).tap()
//        app.buttons["mainSignupLogInButton"].tap()
//        app.navigationBars["Log In"].buttons["navbar back"].tap()
//        letgogodmodeMainsignupviewNavigationBar.buttons["mainSignupHelpButton"].tap()
//        app.navigationBars["Help"].buttons["navbar back"].tap()
//        mainsignupclosebuttonButton.tap()
//
//        let letgogodmodeMainproductsviewNavigationBar = app.navigationBars["LetGoGodMode.MainProductsView"]
//        let textField = letgogodmodeMainproductsviewNavigationBar.otherElements["mainProductsNavBarSearch"].children(matching: .textField).element
//        textField.tap()
//        textField.tap()
//        letgogodmodeMainproductsviewNavigationBar.buttons["Cancel"].tap()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
}
