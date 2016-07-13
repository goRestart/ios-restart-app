//
//  LGConfigRetrieveServiceSpec.swift
//  LGCoreKit
//
//  Created by Dídac on 10/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Quick
@testable import LetGo
import Nimble
import Argo
import Result

class LGConfigRetrieveServiceSpec: QuickSpec {
    
    override func spec() {
//        var sut : ConfigRetrieveService!
//        var result: ConfigRetrieveServiceResult?
//        let completion = { (r: ConfigRetrieveServiceResult) in
//            result = r
//        }
//        beforeEach {
//            result = nil
//            self.removeAllStubs()
//        }
//        afterEach {
//            self.removeAllStubs()
//        }

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
        
//        describe("retrieval") {
//            context("OK") {
//                beforeEach {
//                    let path = NSBundle(forClass: self.classForCoder).pathForResource("iOScfgMockOK", ofType: "json")
//                    let data = NSData(contentsOfFile: path!)!
//                    var body: AnyObject!
//                    expect { body = try NSJSONSerialization.JSONObjectWithData(data, options: []) }.notTo(raiseException())
//                    
//                    let cfgFile = Config(data: data)
//                    expect(cfgFile).notTo(beNil())
//                    
//                    self.stub(uri(cfgFile!.configURL), builder: json(body, status: 200))
//                    
//                    sut = LGConfigRetrieveService()
//                    sut.retrieveConfigWithCompletion(completion)
//                    expect(result).toEventuallyNot(beNil())
//                }
//                
//                it("should receive a valid result") {
//                    expect(result?.value).notTo(beNil())
//                }
//            }
//
//             context("ERROR") {
//                beforeEach {
//                    sut = LGConfigRetrieveService()
//                }
//                context("network error") {
//                    beforeEach {
//                        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
//                        self.stub(uri(EnvironmentProxy.sharedInstance.configURL), builder: failure(error))
//
//                        sut.retrieveConfigWithCompletion(completion)
//                        expect(result).toEventuallyNot(beNil())
//                    }
//                    it("should not receive a value") {
//                        expect(result!.value).to(beNil())
//                    }
//                    it("should receive a network error") {
//                        expect(result!.error).notTo(beNil())
//                        expect(result!.error).to(equal(ConfigRetrieveServiceError.Network))
//                    }
//                }
//                
//                context("unexpected format") {
//                    beforeEach {
//                        let path = NSBundle(forClass: self.classForCoder).pathForResource("No_JSON", ofType: "txt")
//                        let data = NSData(contentsOfFile: path!)!
//                        self.stub(uri(EnvironmentProxy.sharedInstance.configURL), builder: http(200, data: data))
//                        
//                        sut.retrieveConfigWithCompletion(completion)
//                        expect(result).toEventuallyNot(beNil())
//                    }
//                    it("should not receive a value") {
//                        expect(result!.value).to(beNil())
//                    }
//                    it("should receive an internal error") {
//                        expect(result!.error).notTo(beNil())
//                        expect(result!.error).to(equal(ConfigRetrieveServiceError.Internal))
//                    }
//                }
//                
//                context("incomplete JSON") {
//                    beforeEach {
//                        let path = NSBundle(forClass: self.classForCoder).pathForResource("iOScfgMockKOIncomplete", ofType: "json")
//                        let data = NSData(contentsOfFile: path!)!
//                        var body: AnyObject!
//                        expect { body = try NSJSONSerialization.JSONObjectWithData(data, options: []) }.notTo(raiseException())
//                        
//                        sut = LGConfigRetrieveService()
//                        self.stub(uri(EnvironmentProxy.sharedInstance.configURL), builder: json(body, status: 200))
//                        
//                        sut.retrieveConfigWithCompletion(completion)
//                        expect(result).toEventuallyNot(beNil())
//                    }
//                    it("should receive a value") {
//                        expect(result!.value).notTo(beNil())
//                    }
//                    it("should not receive an internal error") {
//                        expect(result!.error).to(beNil())
//                    }
//                }
//            }
//        }
    }
   
}
