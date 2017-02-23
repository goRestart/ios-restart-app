//
//  MultiPageRequesterSpec.swift
//  LetGo
//
//  Created by Eli Kohen on 23/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGo
import LGCoreKit
import Quick
import Nimble
import Result

fileprivate typealias StringResult = Result<[String], RepositoryError>
fileprivate typealias StringCompletion = (StringResult) -> Void

class MultipageRequesterSpec: QuickSpec {
    override func spec() {
        var sut: MultiPageRequester<String>!

        var results: [Int: StringResult]!
        var firstErrorSent: RepositoryError!
        let requestPageBlock: (_ page: Int,_ completion: StringCompletion?) -> Void = { (page, completion) in
            let msRandom = Int.random(10, 100)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(msRandom)) {
                guard let result = results[page] else { return }
                if firstErrorSent == nil, let error = result.error {
                    firstErrorSent = error
                }
                completion?(result)
            }
        }

        var finalResult: StringResult!
        let completion: StringCompletion = { r in
            finalResult = r
        }

        describe("MultipageRequester Spec") {
            beforeEach {
                finalResult = nil
                results = nil
                firstErrorSent = nil
                sut = MultiPageRequester<String>(pageRequestBlock: requestPageBlock)
            }
            context("just one success page") {
                beforeEach {
                    results = [1: StringResult(["a", "b", "c"])]
                    sut.request(pages: [1], completion: completion)
                    expect(finalResult).toEventuallyNot(beNil())
                }
                it("returns success") {
                    expect(finalResult.value).notTo(beNil())
                }
                it("returns a,b,c") {
                    expect(finalResult.value) == ["a", "b", "c"]
                }
            }
            context("just one error page") {
                beforeEach {
                    results = [1: StringResult(error: .notFound)]
                    sut.request(pages: [1], completion: completion)
                    expect(finalResult).toEventuallyNot(beNil())
                }
                it("returns error") {
                    expect(finalResult.error).notTo(beNil())
                }
                it("returns not found error") {
                    expect(finalResult.error!._code) == RepositoryError.notFound._code
                }
            }
            context("10 success pages") {
                beforeEach {
                    results = [:]
                    let allValues: [String] = Array(1...30).map { String($0) }
                    var counter = 0
                    for i in 1...10 {
                        var subArray = [String]()
                        for _ in 0...2 {
                            subArray.append(allValues[counter])
                            counter = counter + 1
                        }
                        results[i] = StringResult(subArray)
                    }
                    sut.request(pages: [1,2,3,4,5,6,7,8,9,10], completion: completion)
                    expect(finalResult).toEventuallyNot(beNil())
                }
                it("returns success") {
                    expect(finalResult.value).notTo(beNil())
                }
                it("returns numbers from 1 to 30") {
                    let result: [String] = Array(1...30).map { String($0) }
                    expect(finalResult.value) == result
                }
            }
            context("9 success pages, one error") {
                beforeEach {
                    results = [:]
                    let allValues: [String] = Array(1...30).map { String($0) }
                    var counter = 0
                    for i in 1...10 {
                        var subArray = [String]()
                        for _ in 0...2 {
                            subArray.append(allValues[counter])
                            counter = counter + 1
                        }
                        results[i] = StringResult(subArray)
                    }
                    results[7] = StringResult(error: .notFound)
                    sut.request(pages: [1,2,3,4,5,6,7,8,9,10], completion: completion)
                    expect(finalResult).toEventuallyNot(beNil())
                }
                it("returns error") {
                    expect(finalResult.error).notTo(beNil())
                }
                it("returns not found error") {
                    expect(finalResult.error!._code) == RepositoryError.notFound._code
                }
            }
            context("5 success pages, 5 errors") {
                beforeEach {
                    results = [:]
                    let allValues: [String] = Array(1...30).map { String($0) }
                    var counter = 0
                    for i in 1...10 {
                        var subArray = [String]()
                        for _ in 0...2 {
                            subArray.append(allValues[counter])
                            counter = counter + 1
                        }
                        results[i] = StringResult(subArray)
                    }
                    results[7] = StringResult(error: .notFound)
                    results[2] = StringResult(error: .tooManyRequests)
                    results[9] = StringResult(error: .internalError(message: ""))
                    results[1] = StringResult(error: .userNotVerified)
                    results[4] = StringResult(error: .unauthorized(code: nil))
                    sut.request(pages: [1,2,3,4,5,6,7,8,9,10], completion: completion)
                    expect(finalResult).toEventuallyNot(beNil())
                }
                it("returns error") {
                    expect(finalResult.error).notTo(beNil())
                }
                it("returns first error") {
                    expect(finalResult.error!._code) == firstErrorSent._code
                }
            }
        }
    }
}
