//
//  FilterTagsVC+RemoveRelatedTags.swift
//  LetGo
//
//  Created by Dídac on 09/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import Quick
import Nimble

class FilterTagsVCRemoveRelatedTagsSpec: QuickSpec {
    override func spec() {

        var sut: FilterTagsViewController!
        var relatedTagsToRemove: [IndexPath]!

        fdescribe("Remove Related Tags") {
            beforeEach {
                sut = FilterTagsViewController(collectionView: UICollectionView())
                relatedTagsToRemove = []
            }
            context("No related tags to remove") {
                beforeEach {
                    sut.tags = [.within(.week), .category(.homeAndGarden), .distance(distance: 10), .make(id: "makeId", name: "makeName"), .model(id: "modelId", name: "modelName")]

                    relatedTagsToRemove = sut.removeRelatedTags(forTag: .within(.week))

                }
                it ("tagsToRemove should be empty") {
                    expect(relatedTagsToRemove.isEmpty) == true
                }
            }

        }
    }
}
