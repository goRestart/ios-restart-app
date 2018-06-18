import Quick
import Nimble
@testable import LGCoreKit
@testable import LetGoGodMode
import Result
import LGComponents

class ConfigFileManagerSpec: QuickSpec {
   
    override func spec() {
        
        var sut : LGConfigManager!
        var service : MockConfigRetrieveService!
        var dao : MockConfigDAO!

        beforeEach {
            service = MockConfigRetrieveService()
            dao = MockConfigDAO()
        }
        
        describe("initialization") {
            context("with dao that cannot load any data") {
                beforeEach {
                    sut = LGConfigManager(service: service, dao: dao, appCurrentVersion: "18")
                }
                it("should not force an update") {
                    expect(sut.shouldForceUpdate).to(beFalse())
                }
            }
            context("with dao that loads data with a config that does not have the current app version as a force update version") {
                beforeEach {
                    let config = Config(buildNumber: 0,
                                        forceUpdateVersions: [1,2,3,4,5],
                                        configURL: "",
                                        quadKeyZoomLevel: SharedConstants.defaultQuadKeyZoomLevel)
                    dao.config = config
                    sut = LGConfigManager(service: service, dao: dao, appCurrentVersion: "18")
                }
                it("should not force an update") {
                    expect(sut.shouldForceUpdate).to(beFalse())
                }
            }
            context("with dao that loads data with a config that has the current app version as a force update version") {
                beforeEach {
                    let config = Config(buildNumber: 0,
                                        forceUpdateVersions: [1,2,3,4,18],
                                        configURL: "",
                                        quadKeyZoomLevel: SharedConstants.defaultQuadKeyZoomLevel)
                    dao.config = config
                    sut = LGConfigManager(service: service, dao: dao, appCurrentVersion: "18")
                }
                it("should force an update") {
                    expect(sut.shouldForceUpdate).to(beTrue())
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
                service.mockResult = ConfigRetrieveServiceResult(error: .internalError)
                
                sut = LGConfigManager(service: service, dao: dao, appCurrentVersion: "18")
                sut.updateWithCompletion(completion)
                expect(didExecuteCompletion).toEventually(beTrue())
            }
            
            it("should execute completion block if service times out") {
                sut = LGConfigManager(service: service, dao: dao, appCurrentVersion: "18")
                sut.updateWithCompletion(completion)
                expect(didExecuteCompletion).toEventually(beTrue(), timeout: 4)
            }
            
            context("with service that cannot load any data and did NOT have a force update before") {
                beforeEach {
                    dao.config = nil
                    service.mockResult = ConfigRetrieveServiceResult(error: .network)
                    
                    sut = LGConfigManager(service: service, dao: dao, appCurrentVersion: "18")
                    
                    sut.updateWithCompletion(completion)
                    expect(didExecuteCompletion).toEventually(beTrue())
                }
                
                it("should not force an update") {
                    expect(sut.shouldForceUpdate).to(beFalse())
                }
            }
            context("with service that cannot load any data and did have a force update before") {
                beforeEach {
                    let config = Config(buildNumber: 0,
                                        forceUpdateVersions: [1,2,3,18],
                                        configURL: "www.letgo.com",
                                        quadKeyZoomLevel: SharedConstants.defaultQuadKeyZoomLevel)
                    dao.config = config
                    
                    service.mockResult = ConfigRetrieveServiceResult(error: .network)
                    
                    sut = LGConfigManager(service: service, dao: dao, appCurrentVersion: "18")
                    
                    sut.updateWithCompletion(completion)
                    expect(didExecuteCompletion).toEventually(beTrue())
                }
                
                it("should force an update") {
                    expect(sut.shouldForceUpdate).to(beTrue())
                }
            }
            context("with service that loads data with a config that does not have the current app version as a force update version") {
                beforeEach {
                    let config = Config(buildNumber: 0,
                                        forceUpdateVersions: [1,2,3,24],
                                        configURL: "www.letgo.com",
                                        quadKeyZoomLevel: SharedConstants.defaultQuadKeyZoomLevel)
                    service.mockResult = ConfigRetrieveServiceResult(value: config)
                    
                    sut = LGConfigManager(service: service, dao: dao, appCurrentVersion: "18")
                    
                    sut.updateWithCompletion(completion)
                    expect(didExecuteCompletion).toEventually(beTrue())
                }
                
                it("should not force an update") {
                    expect(sut.shouldForceUpdate).to(beFalse())
                }
            }
            context("with service that loads data with a config that has the current app version as a force update version") {
                beforeEach {
                    let config = Config(buildNumber: 0,
                                        forceUpdateVersions: [1,2,3,18],
                                        configURL: "www.letgo.com",
                                        quadKeyZoomLevel: SharedConstants.defaultQuadKeyZoomLevel)
                    service.mockResult = ConfigRetrieveServiceResult(value: config)
                    
                    sut = LGConfigManager(service: service, dao: dao, appCurrentVersion: "18")
                    
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
