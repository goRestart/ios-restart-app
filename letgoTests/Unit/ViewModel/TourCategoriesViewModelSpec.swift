//
//  TourCategoriesViewModelSpec.swift
//  LetGo
//
//  Created by Juan Iglesias on 17/08/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

class TourCategoriesViewModelSpec: BaseViewModelSpec {
    
    override func spec() {
        var sut: TourCategoriesViewModel!
        var tracker: MockTracker!
        
        describe("TourCategoriesViewModelSpec") {
            
            beforeEach {
                let taxonomies = [MockTaxonomy.makeMock(), MockTaxonomy.makeMock()]
                sut = TourCategoriesViewModel(tracker: tracker, taxonomies: taxonomies)
            }
            
            describe("initialization") {
                context("no items selected") {
                    it("categoriesSelected is 0") {
                        
                    }
                    it("categories is the same taxonomies passed") {
                        
                    }
                }
            }
        }
    }
}

