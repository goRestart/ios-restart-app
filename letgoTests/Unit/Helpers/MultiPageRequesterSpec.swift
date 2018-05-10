//
//  MultiPageRequesterSpec.swift
//  LetGo
//
//  Created by Eli Kohen on 23/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble
import Result

fileprivate typealias StringResult = Result<[String], RepositoryError>
fileprivate typealias DelayedStringResult = (delay: Int, result: Result<[String], RepositoryError>)
fileprivate typealias StringCompletion = (StringResult) -> Void

class MultipageRequesterSpec: QuickSpec {
    override func spec() {
        var sut: MultiPageRequester<String>!

        describe("MultipageRequesterSpec") {
            var pageResults: [Int: DelayedStringResult]!
            var testExecutionId: Int!
            let pageRequestBlock = { (page: Int, completion: StringCompletion?) in
                // Check the test execution id to prevent tests influencing in others
                guard let currentTestExecutionId = testExecutionId else { return }

                // Simulates an async operations that runs on background and callbacks in foreground
                DispatchQueue.global(qos: .background).async {
                    guard currentTestExecutionId == testExecutionId else { return }

                    let delayedResult = pageResults[page] ?? (0, StringResult(error: .internalError(message: "result not found")))
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delayedResult.delay)) {
                        completion?(delayedResult.result)
                    }
                }
            }

            beforeEach {
                sut = MultiPageRequester<String>(pageRequestBlock: pageRequestBlock)
                testExecutionId = Int.makeRandom(min: 0, max: 9999)
                pageResults = [:]
            }

            describe("request") {
                var result: StringResult!
                let completion: StringCompletion? = { r in
                    result = r
                }
                var pages: [Int]!

                beforeEach {
                    pageResults[0] = (10, StringResult(["a"]))
                    pageResults[1] = (10, StringResult(["b"]))
                    pageResults[2] = (10, StringResult(["c"]))
                    pageResults[3] = (10, StringResult(["d"]))
                    pageResults[4] = (10, StringResult(["e"]))
                    pageResults[5] = (10, StringResult(error: .notFound))
                    pageResults[6] = (10, StringResult(error: .tooManyRequests))
                    pageResults[7] = (10, StringResult(error: .internalError(message: "oh my god")))
                    pageResults[8] = (10, StringResult(error: .userNotVerified))
                    pageResults[9] = (10, StringResult(error: .unauthorized(code: 1992, description: "oh my god")))
                    result = nil
                    pages = []
                }

                context("a single successful page") {
                    beforeEach {
                        pages = [0]
                        sut.request(pages: pages, completion: completion)
                        expect(result).toEventuallyNot(beNil())
                    }

                    it("calls the completion block with a value result") {
                        expect(result.value).notTo(beNil())
                    }
                    it("calls the completion block with [a] value result") {
                        expect(result.value) == ["a"]
                    }
                }

                context("a single failing page") {
                    beforeEach {
                        pages = [5]
                        sut.request(pages: pages, completion: completion)
                        expect(result).toEventuallyNot(beNil())
                    }

                    it("calls the completion block with an error result") {
                        expect(result.error).notTo(beNil())
                    }
                    it("calls the completion block with notFound error result") {
                        expect(result.error!._code) == RepositoryError.notFound._code
                    }
                }

                context("5 successful pages") {
                    beforeEach {
                        pages = [0,1,2,3,4]
                        sut.request(pages: pages, completion: completion)
                        expect(result).toEventuallyNot(beNil())
                    }

                    it("calls the completion block with a value result") {
                        expect(result.value).notTo(beNil())
                    }
                    it("calls the completion block with [a,b,c,d,e] value result") {
                        expect(result.value) == ["a","b","c","d","e"]
                    }
                }

                context("5 failing pages with all pages taking the same time to call back") {
                    beforeEach {
                        pages = [5,6,7,8,9]
                        sut.request(pages: pages, completion: completion)
                        expect(result).toEventuallyNot(beNil())
                    }

                    it("calls the completion block with an error result") {
                        expect(result.error).notTo(beNil())
                    }
                    it("calls the completion block with the first received error") {
                        expect(result.error!._code) == RepositoryError.notFound._code
                    }
                }

                context("5 failing pages which each takes longer to call back") {
                    beforeEach {
                        pageResults[5]?.delay = 10
                        pageResults[6]?.delay = 20
                        pageResults[7]?.delay = 30
                        pageResults[8]?.delay = 40
                        pageResults[9]?.delay = 50
                        pages = [5,6,7,8,9]
                        sut.request(pages: pages, completion: completion)
                        expect(result).toEventuallyNot(beNil())
                    }

                    it("calls the completion block with an error result") {
                        expect(result.error).notTo(beNil())
                    }
                    it("calls the completion block with the first received error") {
                        expect(result.error!._code) == RepositoryError.notFound._code
                    }
                }

                context("5 successful pages and 1 failing page") {
                    beforeEach {
                        pages = [0,1,2,3,4,5]
                        sut.request(pages: pages, completion: completion)
                        expect(result).toEventuallyNot(beNil())
                    }

                    it("calls the completion block with an error result") {
                        expect(result.error).notTo(beNil())
                    }
                    it("calls the completion block with the failing page error") {
                        expect(result.error!._code) == RepositoryError.notFound._code
                    }
                }

                context("3 successful pages and 3 failing pages") {
                    beforeEach {
                        pages = [0,1,2,5,6,7]
                        sut.request(pages: pages, completion: completion)
                        expect(result).toEventuallyNot(beNil())
                    }

                    it("calls the completion block with an error result") {
                        expect(result.error).notTo(beNil())
                    }
                    it("calls the completion block with the first received error") {
                        expect(result.error!._code) == RepositoryError.notFound._code
                    }
                }

                context("3 successful pages and 3 failing pages which each takes longer to call back") {
                    beforeEach {
                        pageResults[0]?.delay = 10
                        pageResults[1]?.delay = 20
                        pageResults[2]?.delay = 30
                        pageResults[5]?.delay = 40
                        pageResults[6]?.delay = 50
                        pageResults[7]?.delay = 60
                        pages = [0,1,2,5,6,7]
                        sut.request(pages: pages, completion: completion)
                        expect(result).toEventuallyNot(beNil())
                    }

                    it("calls the completion block with an error result") {
                        expect(result.error).notTo(beNil())
                    }
                    it("calls the completion block with the first received error") {
                        expect(result.error!._code) == RepositoryError.notFound._code
                    }
                }
            }
        }
    }
}
