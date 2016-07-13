//
//  ConfigManagerSpec.swift
//  LGCoreKit
//
//  Created by Dídac on 10/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Quick
import Nimble
@testable import LGCoreKit
import Result

class ConfigFileManagerSpec: QuickSpec {
   
    override func spec() {
        
        var sut : ConfigManager!
        var service : MockConfigRetrieveService!
        var dao : MockConfigDAO!

        beforeEach {
            service = MockConfigRetrieveService()
            dao = MockConfigDAO()
        }
        
        describe("initialization") {
            context("with dao that cannot load any data") {
                beforeEach {
                    sut = ConfigManager(service: service, dao: dao, appCurrentVersion: "18")
                }
                it("should not force an update") {
                    expect(sut.shouldForceUpdate).to(beFalse())
                }
            }
            context("with dao that loads data with a config that does not have the current app version as a force update version") {
                beforeEach {
                    let config = Config()
                    config.forceUpdateVersions = [1,2,3,4,5]
                    dao.config = config
                    sut = ConfigManager(service: service, dao: dao, appCurrentVersion: "18")
                }
                it("should not force an update") {
                    expect(sut.shouldForceUpdate).to(beFalse())
                }
            }
            context("with dao that loads data with a config that has the current app version as a force update version") {
                beforeEach {
                    let config = Config()
                    config.forceUpdateVersions = [1,2,3,4,18]
                    dao.config = config
                    sut = ConfigManager(service: service, dao: dao, appCurrentVersion: "18")
                }
                it("should force an update") {
                    expect(sut.shouldForceUpdate).to(beTrue())
                }
            }
            context("messages count with dao that cannot load any data") {
                beforeEach {
                    sut = ConfigManager(service: service, dao: dao, appCurrentVersion: "18")
                }
                it("should have default value for my messages") {
                    expect(sut.myMessagesCountForRating) == 1       // 1 is the default value
                }
                it("should have default value for other user messages") {
                    expect(sut.otherMessagesCountForRating) == 1    // 1 is the default value
                }
            }
            context("messages count with dao that worked ok") {
                beforeEach {
                    let config = Config()
                    config.myMessagesCountForRating = 2
                    config.otherMessagesCountForRating = 3
                    dao.config = config
                    sut = ConfigManager(service: service, dao: dao, appCurrentVersion: "18")
                }
                it("should have default value for my messages") {
                    expect(sut.myMessagesCountForRating) == 2
                }
                it("should have default value for other user messages") {
                    expect(sut.otherMessagesCountForRating) == 3
                }
            }
        }
        
        describe("update") {
            
            var didExecuteCompletion: Bool!
            let completion = {
                didExecuteCompletion = true
            }
            
            beforeEach {
                didExecuteCompletion = false
            }
            
            it("should execute completion block") {
                dao.config = nil
                service.mockResult = ConfigRetrieveServiceResult(error: .Internal)
                
                sut = ConfigManager(service: service, dao: dao, appCurrentVersion: "18")
                sut.updateWithCompletion(completion)
                expect(didExecuteCompletion).toEventually(beTrue())
            }
            
            it("should execute completion block if service times out") {
                sut = ConfigManager(service: service, dao: dao, appCurrentVersion: "18")
                sut.updateWithCompletion(completion)
                expect(didExecuteCompletion).toEventually(beTrue(), timeout: 4)
            }
            
            context("with service that cannot load any data and did NOT have a force update before") {
                beforeEach {
                    dao.config = nil
                    service.mockResult = ConfigRetrieveServiceResult(error: .Network)
                    
                    sut = ConfigManager(service: service, dao: dao, appCurrentVersion: "18")
                    
                    sut.updateWithCompletion(completion)
                    expect(didExecuteCompletion).toEventually(beTrue())
                }
                
                it("should not force an update") {
                    expect(sut.shouldForceUpdate).to(beFalse())
                }
            }
            context("with service that cannot load any data and did have a force update before") {
                beforeEach {
                    let config = Config()
                    config.buildNumber = 0
                    config.configURL = "www.letgo.com"
                    config.forceUpdateVersions = [1,2,3,18]
                    dao.config = config
                    
                    service.mockResult = ConfigRetrieveServiceResult(error: .Network)
                    
                    sut = ConfigManager(service: service, dao: dao, appCurrentVersion: "18")
                    
                    sut.updateWithCompletion(completion)
                    expect(didExecuteCompletion).toEventually(beTrue())
                }
                
                it("should force an update") {
                    expect(sut.shouldForceUpdate).to(beTrue())
                }
            }
            context("with service that loads data with a config that does not have the current app version as a force update version") {
                beforeEach {
                    dao.config = Config()
                    
                    let config = Config()
                    config.buildNumber = 0
                    config.configURL = "www.letgo.com"
                    config.forceUpdateVersions = [1,2,3,24]
                    service.mockResult = ConfigRetrieveServiceResult(value: config)
                    
                    sut = ConfigManager(service: service, dao: dao, appCurrentVersion: "18")
                    
                    sut.updateWithCompletion(completion)
                    expect(didExecuteCompletion).toEventually(beTrue())
                }
                
                it("should not force an update") {
                    expect(sut.shouldForceUpdate).to(beFalse())
                }
            }
            context("with service that loads data with a config that has the current app version as a force update version") {
                beforeEach {
                    dao.config = Config()
                    
                    let config = Config()
                    config.buildNumber = 0
                    config.configURL = "www.letgo.com"
                    config.forceUpdateVersions = [1,2,3,18]
                    service.mockResult = ConfigRetrieveServiceResult(value: config)
                    
                    sut = ConfigManager(service: service, dao: dao, appCurrentVersion: "18")
                    
                    sut.updateWithCompletion(completion)
                    expect(didExecuteCompletion).toEventually(beTrue())
                }
                
                it("should force an update") {
                    expect(sut.shouldForceUpdate).to(beTrue())
                }
            }
        }
    }
}
