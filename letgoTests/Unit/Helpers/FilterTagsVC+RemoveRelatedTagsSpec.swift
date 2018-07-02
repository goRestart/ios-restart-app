@testable import LetGoGodMode
import Quick
import Nimble

class FilterTagsVCRemoveRelatedTagsSpec: QuickSpec {
    override func spec() {

        var sut: FilterTagsView!
        var relatedTagsToRemove: [IndexPath]!

        describe("Remove Related Tags") {
            beforeEach {
                sut = FilterTagsView()
                relatedTagsToRemove = []
            }
            context("Removing not-category, no related tags to remove") {
                beforeEach {
                    sut.tags = [.within(.week), .category(.homeAndGarden), .distance(distance: 10), .make(id: "makeId", name: "makeName"), .model(id: "modelId", name: "modelName")]
                    relatedTagsToRemove = sut.removeRelatedTags(forTag: .within(.week))
                }
                it ("tagsToRemove should be empty") {
                    expect(relatedTagsToRemove.isEmpty) == true
                }
            }
            context("Removing category, no related tags to remove") {
                beforeEach {
                    sut.tags = [.within(.week), .category(.homeAndGarden), .distance(distance: 10), .make(id: "makeId", name: "makeName"), .model(id: "modelId", name: "modelName")]
                    relatedTagsToRemove = sut.removeRelatedTags(forTag: .category(.homeAndGarden))
                }
                it ("tagsToRemove should be empty") {
                    expect(relatedTagsToRemove.isEmpty) == true
                }
            }
            context("Removing category cars, no related tags to remove") {
                beforeEach {
                    sut.tags = [.within(.week), .category(.cars), .distance(distance: 10)]
                    relatedTagsToRemove = sut.removeRelatedTags(forTag: .category(.cars))
                }
                it ("tagsToRemove should be empty") {
                    expect(relatedTagsToRemove.isEmpty) == true
                }
            }
            context("Removing category cars, 2 related tags to remove") {
                beforeEach {
                    sut.tags = [.within(.week), .category(.cars), .distance(distance: 10), .make(id: "makeId", name: "makeName"), .model(id: "modelId", name: "modelName")]
                    relatedTagsToRemove = sut.removeRelatedTags(forTag: .category(.cars))
                }
                it ("tagsToRemove should not be empty") {
                    expect(relatedTagsToRemove.isEmpty) == false
                }
                it ("tagsToRemove has indexes for make & model") {
                    expect(relatedTagsToRemove) == [IndexPath(item: 3, section: 0), IndexPath(item: 4, section: 0)]
                }
            }
            context("Removing make tag, 1 related tags to remove") {
                beforeEach {
                    sut.tags = [.within(.week), .category(.cars), .distance(distance: 10), .make(id: "makeId", name: "makeName"), .model(id: "modelId", name: "modelName")]
                    relatedTagsToRemove = sut.removeRelatedTags(forTag: .make(id: "makeId", name: "makeName"))
                }
                it ("tagsToRemove should not be empty") {
                    expect(relatedTagsToRemove.isEmpty) == false
                }
                it ("tagsToRemove has indexes for make & model") {
                    expect(relatedTagsToRemove) == [IndexPath(item: 4, section: 0)]
                }
            }
            context("Removing category real estate, 1 related tags to remove") {
                beforeEach {
                    sut.tags = [.within(.week), .category(.realEstate), .distance(distance: 10), .realEstatePropertyType(.room), .realEstateOfferType(.sale)]
                    relatedTagsToRemove = sut.removeRelatedTags(forTag: .category(.realEstate))
                }
                it ("tagsToRemove should not be empty") {
                    expect(relatedTagsToRemove.isEmpty) == false
                }
                it ("tagsToRemove has indexes for make & model") {
                    expect(relatedTagsToRemove) == [IndexPath(item: 3, section: 0), IndexPath(item: 4, section: 0)]
                }
            }
        }
    }
}
