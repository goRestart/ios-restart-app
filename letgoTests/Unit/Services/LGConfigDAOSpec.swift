//
//  LGConfigDAOSpec.swift
//  LGCoreKit
//
//  Created by Dídac on 10/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Quick
import Nimble
@testable import LetGoGodMode

class LGConfigDAOSpec: QuickSpec {
    
    override func spec() {
        
        var sut : LGConfigDAO!

        afterEach {
            // cache cleanup
            let fm = FileManager.default
            do { try fm.removeItem(atPath: sut.fileCachePath) } catch {}
        }
        
        describe("initialization") {
            context("unexisting file in bundle") {
                beforeEach {
                    sut = LGConfigDAO(bundle: Bundle(for: LGConfigDAOSpec.self), configFileName: "unexisting")
                }
                it("all properties should be initialized") {
                    expect(sut.fileCachePath).notTo(beNil())
                }
                it("cache should not contain any config file") {
                    let fm = FileManager.default
                    expect(fm.fileExists(atPath: sut.fileCachePath)).to(beFalse())
                }
            }
            context("existing file in bundle") {
                beforeEach {
                    sut = LGConfigDAO(bundle: Bundle(for: LGConfigDAOSpec.self), configFileName: "iOScfgMockOK")
                }
                it("all properties should be initialized") {
                    expect(sut.fileCachePath).notTo(beNil())
                }
                it("cache should contain a config file") {
                    let fm = FileManager.default
                    expect(fm.fileExists(atPath: sut.fileCachePath)).to(beTrue())
                }
            }
        }
        
        describe("retrieval") {
            context("with unexisting file in bundle") {
                var configFile: Config!
                
                beforeEach {
                    sut = LGConfigDAO(bundle: Bundle(for: LGConfigDAOSpec.self), configFileName: "unexisting")
                    configFile = sut.retrieve()
                }
                it("should return nil when retrieving") {
                    expect(configFile).to(beNil())
                }
            }
            context("with existing file in bundle") {
                var configFile: Config!
                
                beforeEach {
                    sut = LGConfigDAO(bundle: Bundle(for: LGConfigDAOSpec.self), configFileName: "iOScfgMockOK")
                    configFile = sut.retrieve()
                }
                it("should return a file when retrieving") {
                    expect(configFile).notTo(beNil())
                }
                it("cache should contain a config file") {
                    let fm = FileManager.default
                    expect(fm.fileExists(atPath: sut.fileCachePath)).to(beTrue())
                }
            }
        }
        
        describe("save") {
            var configFile: Config!
            
            beforeEach {
                sut = LGConfigDAO(bundle: Bundle(for: LGConfigDAOSpec.self), configFileName: "unexisting")
                expect(sut.retrieve()).to(beNil())
                
                configFile = Config(buildNumber: 3,
                                    forceUpdateVersions : [1,2,3],
                                    configURL: "http://yahoo.com",
                                    quadKeyZoomLevel: 15)
                sut.save(configFile)
            }
            it("should return a file when retrieving") {
                expect(sut.retrieve()).notTo(beNil())
            }
            it("cache should contain a config file") {
                let fm = FileManager.default
                expect(fm.fileExists(atPath: sut.fileCachePath)).to(beTrue())
            }
        }
    }
}
