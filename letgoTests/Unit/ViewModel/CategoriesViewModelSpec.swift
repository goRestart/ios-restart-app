//
//  CategoriesViewModelSpec.swift
//  LetGo
//
//  Created by Dídac on 22/10/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Quick
import LetGo
import LGCoreKit
import Nimble
import Result

class CategoriesViewModelSpec: QuickSpec, CategoriesViewModelDelegate {
    
    var receivedViewModel: CategoriesViewModel!
    
    override func spec() {
        var sut: CategoriesViewModel!
        
//        var resultCategories : [ProductCategory]!
        
        describe ("initial state") {
            
            context("default init") {
                
                beforeEach {
                    sut = CategoriesViewModel()
                }
                
                it ("should not have categories yet") {
                    expect(sut.numOfCategories).to(equal(0))
                }
                
                it ("does not return a category in any index") {
                    expect(sut.categoryAtIndex(1)).to(beNil())
                }
                
                it ("does not return a product list view model for category in any index") {
                    expect(sut.productsViewModelForCategoryAtIndex(1)).to(beNil())
                }
            }
            
            context("init with params") {
                
                beforeEach {
                    let categoriesManager = CategoriesManager.sharedInstance
                    let categoriesList = [ProductCategory.Electronics, ProductCategory.CarsAndMotors, ProductCategory.SportsLeisureAndGames]
                    
                    sut = CategoriesViewModel(categoriesManager: categoriesManager, categories: categoriesList)
                }

                it ("should have the categories passed by parameter") {
                    expect(sut.numOfCategories).to(equal(3))
                }
                
                it ("does return a category in any index inside categories params bounds") {
                    expect(sut.categoryAtIndex(1)).to(equal(ProductCategory.CarsAndMotors))
                    expect(sut.categoryAtIndex(100)).to(beNil())
                }
                
                it ("does return a product list view model for category in any index inside categories params bounds") {
                    expect(sut.productsViewModelForCategoryAtIndex(1)).toNot(beNil())
                    expect(sut.productsViewModelForCategoryAtIndex(100)).to(beNil())
                }
            }
        }
        
        describe("categories retrieval") {
            beforeEach {
                sut = CategoriesViewModel()
                self.receivedViewModel = nil
                sut.delegate = self
            }
            context("categories restrieved OK") {
                
                beforeEach {
                    sut.retrieveCategories()
                }
                
                it("should receive categories") {
                    
                    expect(sut.retrieveCategories()).toEventuallyNot(beNil())
                    expect(sut.numOfCategories).to(beGreaterThan(0))
                    
                }
                
                it ("does return a category in any index inside categories params bounds") {
                    expect(sut.categoryAtIndex(1)).to(equal(ProductCategory.CarsAndMotors))
                    expect(sut.categoryAtIndex(100)).to(beNil())
                }
                
                it ("does return a product list view model for category in any index inside categories params bounds") {
                    expect(sut.productsViewModelForCategoryAtIndex(1)).toNot(beNil())
                    expect(sut.productsViewModelForCategoryAtIndex(100)).to(beNil())
                }
                
                it("notifies the delegate") {
                    expect(sut).to(beIdenticalTo(self.receivedViewModel))
                }
            }
            
            context("categories are not retrieved") {

                it("shouldn't receive categories") {
                    expect(sut.numOfCategories).to(equal(0))
                }
                
                it ("doesn't return a category in any index inside categories params bounds") {
                    expect(sut.categoryAtIndex(1)).to(beNil())
                }
                
                it ("does return a product list view model for category in any index inside categories params bounds") {
                    expect(sut.productsViewModelForCategoryAtIndex(1)).to(beNil())
                }
                it("doesn't notify the delegate") {
                    expect(self.receivedViewModel).to(beNil())
                }
            }
            
        }
    }
    
    // MARK: - CategoriesViewModelDelegate
    
    func viewModelDidUpdate(viewModel: CategoriesViewModel) {
        self.receivedViewModel = viewModel
    }
}