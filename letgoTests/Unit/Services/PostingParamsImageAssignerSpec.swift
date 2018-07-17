
import Foundation
@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble

final class PostingParamsImageAssignerSpec: QuickSpec {
    
    override func spec() {
        let mockFiles: [MockFile] = MockFile.makeMocks(count: 10)
        var mockParams: [ListingCreationParams]!
        describe("PostingParamsImageAssignerSpec") {
            
            context("has files to assign") {
                beforeEach {
                    mockParams = PostingParamsImageAssigner.assign(images: mockFiles,
                                                                   toFirstItemInParams: ListingCreationParams.makeMocks())
                }
                
                it("first param item should have all files") {
                    expect(mockParams.first?.images.compactMap({ $0.objectId }))
                        .to(contain(mockFiles.compactMap({ $0.objectId })))
                }
            }
            
            context("has no files to assign") {
                beforeEach {
                    mockParams = PostingParamsImageAssigner.assign(images: nil,
                                                                   toFirstItemInParams: ListingCreationParams.makeMocks())
                }
                
                it("all param items are unmodified") {
                    for param in mockParams {
                        let paramFileIds = param.images.compactMap({ $0.objectId })
                        let mockFileIds = mockFiles.compactMap({ $0.objectId })
                        
                        expect(paramFileIds).notTo(contain(mockFileIds))
                    }
                }
            }
        }
    }
}
