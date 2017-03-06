//
//  LGConfigRetrieveServiceSpec.swift
//  LGCoreKit
//
//  Created by Dídac on 10/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Quick
@testable import LetGoGodMode
import Nimble
import Argo
import OHHTTPStubs
import Result

class LGConfigRetrieveServiceSpec: QuickSpec {
    
    override func spec() {
        var sut : ConfigRetrieveService!
        var result: ConfigRetrieveServiceResult?
        let completion = { (r: ConfigRetrieveServiceResult) in
            result = r
        }
        beforeEach {
            result = nil
            OHHTTPStubs.removeAllStubs()
        }
        afterEach {
            result = nil
            OHHTTPStubs.removeAllStubs()
        }

        describe("initialization") {
           
            context("default init") {
                it("is initialized with the given url") {
                    let convenienceSut = LGConfigRetrieveService(url: "http://google.com")
                    expect(convenienceSut.configURL).to(equal("http://google.com"))
                }
            }
            context("convenience init") {
                it("is initialized with the default url") {
                    let convenienceSut = LGConfigRetrieveService()
                    expect(convenienceSut.configURL).to(equal(EnvironmentProxy.sharedInstance.configURL))
                }
            }
        }
        
        describe("retrieval") {
            context("OK") {
                beforeEach {
                    let path = Bundle(for: self.classForCoder).path(forResource: "iOScfgMockOK", ofType: "json")
                    let data = try! Data(contentsOf: URL(fileURLWithPath: path!))

                    let cfgFile = Config(data: data)
                    expect(cfgFile).notTo(beNil())

                    stub(condition: isPath("/config/ios.json")) { _ in
                        let path = OHPathForFile("iOScfgMockOK.json", LGConfigRetrieveServiceSpec.self)!
                        return fixture(filePath: path, status: 200, headers: nil)
                        }.name = "iOScfgMockOK"

                    sut = LGConfigRetrieveService()
                    sut.retrieveConfigWithCompletion(completion)
                    expect(result).toEventuallyNot(beNil())
                }
                it("should receive a result") {
                    expect(result).notTo(beNil())
                }
                it("should receive a result with value") {
                    expect(result?.value).notTo(beNil())
                }
            }

            context("ERROR") {
                beforeEach {
                    sut = LGConfigRetrieveService()
                }
                context("network error") {
                    beforeEach {
                        stub(condition: isPath("/config/ios.json")) { _ in
                            let notConnectedError = NSError(domain:NSURLErrorDomain, code:Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue), userInfo:nil)
                            return OHHTTPStubsResponse(error:notConnectedError)
                            }.name = "iOScfgMockKONetworkError"

                        sut.retrieveConfigWithCompletion(completion)
                        expect(result).toEventuallyNot(beNil())
                    }
                    it("should not receive a value") {
                        expect(result?.value).to(beNil())
                    }
                    it("should receive a network error") {
                        expect(result?.error).notTo(beNil())
                    }
                    it("should receive a network error") {
                        expect(result?.error).to(equal(ConfigRetrieveServiceError.network))
                    }
                }

                context("unexpected format") {
                    beforeEach {
                        stub(condition: isPath("/config/ios.json")) { _ in
                            let path = OHPathForFile("No_JSON.txt", LGConfigRetrieveServiceSpec.self)!
                            return fixture(filePath: path, status: 200, headers: nil)
                            }.name = "iOScfgMockNoJSON"
                        
                        sut.retrieveConfigWithCompletion(completion)
                        expect(result).toEventuallyNot(beNil())
                    }
                    it("should not receive a value") {
                        expect(result?.value).to(beNil())
                    }
                    it("should receive an error") {
                        expect(result?.error).notTo(beNil())
                    }
                    it("should receive an internal error") {
                        expect(result?.error).to(equal(ConfigRetrieveServiceError.internalError))
                    }
                }

                context("incomplete JSON (well formatted, missing data)") {
                    beforeEach {
                        stub(condition: isPath("/config/ios.json")) { _ in
                            let path = OHPathForFile("iOScfgMockKOIncomplete.json", LGConfigRetrieveServiceSpec.self)!
                            return fixture(filePath: path, status: 200, headers: nil)
                            }.name = "iOScfgMockJSONIncomplete"
                        
                        sut.retrieveConfigWithCompletion(completion)
                        expect(result).toEventuallyNot(beNil())
                    }
                    it("should receive a value") {
                        expect(result?.value).notTo(beNil())
                    }
                    it("should not receive any error") {
                        expect(result?.error).to(beNil())
                    }
                }
            }
        }
    }
}
