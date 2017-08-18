//
//  TourCategoriesViewModelSpec.swift
//  LetGo
//
//  Created by Juan Iglesias on 17/08/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble
import Result

class TourCategoriesViewModelSpec: BaseViewModelSpec {
    
    override func spec() {
        var sut: TourCategoriesViewModel!
        var keyValueStorage: KeyValueStorage!
        var tracker: MockTracker!
        
        describe("TourCategoriesViewModelSpec") {
            
            beforeEach {
                keyValueStorage = KeyValueStorage()
                tracker = MockTracker()
                let taxonomies = [MockTaxonomy.makeMock(), MockTaxonomy.makeMock()]
                sut = TourCategoriesViewModel(tracker: tracker, keyValueStorage: keyValueStorage, taxonomies: taxonomies)
            }
            
            describe("initialization") {
                context("no items selected") {
                    it("categoriesSelected is 0") {
                        expect(sut.categoriesSelected.value.count) == 0
                    }
                    it("keyValueStorage does not contain favoriteCategories") {
                        expect(keyValueStorage[.favoriteCategories]) == []
                    }
                    it("keyValueStorage does not contain favoriteCategories") {
                        expect(keyValueStorage.favoriteCategoriesSelected.value) == false
                    }
                }
            }
            describe("press okButton with 4 selected") {
                beforeEach {
                    sut.categoriesSelected.value = MockTaxonomyChild.makeMocks(count: 4)
                    sut.okButtonPressed()
                }
                it("categoriesSelected is 4") {
                    expect(sut.categoriesSelected.value.count) == 4
                }
                it("keyValueStorage does not contain favoriteCategories") {
                    expect(keyValueStorage[.favoriteCategories]) == sut.categoriesSelected.value.flatMap{ $0.id }
                }
                it("keyValueStorage does not contain favoriteCategories") {
                    expect(keyValueStorage.favoriteCategoriesSelected.value) == true
                }
            }
        }
    }
}

