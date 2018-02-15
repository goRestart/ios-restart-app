//
//  ConfigSpec.swift
//  LGCoreKit
//
//  Created by Dídac on 10/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Quick
import Nimble
@testable import LetGoGodMode


class ConfigSpec: QuickSpec {
   
    override func spec() {
        var sut : Config!
        
        describe("decode") {
            var json : Data!
            
            context("with a correct json") {
                beforeEach {
                    json = """
                    {
                        "currentVersionInfo": {
                            "buildNumber": 312,
                            "forceUpdateVersions": [1, 2, 3]
                        },
                        "configURL": "https://cdn.letgo.com/config/ios.json",
                        "quadKeyZoomLevel": 15
                    }
                    """.data(using: .utf8)
                    sut = try? JSONDecoder().decode(Config.self, from: json)
                }
                
                it("returns a config object") {
                    expect(sut).notTo(beNil())
                }
                it("has build number") {
                    expect(sut.buildNumber) == 312
                }
                it("has force update versions") {
                    expect(sut.forceUpdateVersions) == [1,2,3]
                }
                it("has config url") {
                    expect(sut.configURL) == "https://cdn.letgo.com/config/ios.json"
                }
                it("has quad key zoom level") {
                    expect(sut.quadKeyZoomLevel) == 15
                }
            }
            
            context("with a json has not current version info key") {
                beforeEach {
                    json = """
                    {
                        "configURL": "https://cdn.letgo.com/config/ios.json",
                        "quadKeyZoomLevel": 15
                    }
                    """.data(using: .utf8)
                    sut = try? JSONDecoder().decode(Config.self, from: json)
                }
                
                it("returns a config object") {
                    expect(sut).notTo(beNil())
                }
                it("has build number with default value") {
                    expect(sut.buildNumber) == 0
                }
                it("has update versions with default value") {
                    expect(sut.forceUpdateVersions) == []
                }
                it("has config url") {
                    expect(sut.configURL) == "https://cdn.letgo.com/config/ios.json"
                }
                it("has quad key zoom level") {
                    expect(sut.quadKeyZoomLevel) == 15
                }
            }
            
            context("with a json has not build number key") {
                beforeEach {
                    json = """
                    {
                        "currentVersionInfo": {
                            "forceUpdateVersions": [1, 2, 3]
                        },
                        "configURL": "https://cdn.letgo.com/config/ios.json",
                        "quadKeyZoomLevel": 15
                    }
                    """.data(using: .utf8)
                    sut = try? JSONDecoder().decode(Config.self, from: json)
                }
                
                it("returns a config object") {
                    expect(sut).notTo(beNil())
                }
                it("has build number with default value") {
                    expect(sut.buildNumber) == 0
                }
                it("has force update versions") {
                    expect(sut.forceUpdateVersions) == [1,2,3]
                }
                it("has config url") {
                    expect(sut.configURL) == "https://cdn.letgo.com/config/ios.json"
                }
                it("has quad key zoom level") {
                    expect(sut.quadKeyZoomLevel) == 15
                }
            }
            
            context("with a json that has not force update versions key") {
                beforeEach {
                    json = """
                    {
                        "currentVersionInfo": {
                            "buildNumber": 312
                        },
                        "configURL": "https://cdn.letgo.com/config/ios.json",
                        "quadKeyZoomLevel": 15
                    }
                    """.data(using: .utf8)
                    sut = try? JSONDecoder().decode(Config.self, from: json)
                }
                
                it("returns a config object") {
                    expect(sut).notTo(beNil())
                }
                it("has build number") {
                    expect(sut.buildNumber) == 312
                }
                it("has force update versions with default value") {
                    expect(sut.forceUpdateVersions) == []
                }
                it("has config url") {
                    expect(sut.configURL) == "https://cdn.letgo.com/config/ios.json"
                }
                it("has quad key zoom level") {
                    expect(sut.quadKeyZoomLevel) == 15
                }
            }
            
            context("with a json that has not config url key") {
                beforeEach {
                    json = """
                    {
                        "currentVersionInfo": {
                            "buildNumber": 312,
                            "forceUpdateVersions": [1, 2, 3]
                        },
                        "quadKeyZoomLevel": 15
                    }
                    """.data(using: .utf8)
                    sut = try? JSONDecoder().decode(Config.self, from: json)
                }
                
                it("returns a config object") {
                    expect(sut).notTo(beNil())
                }
                it("has build number") {
                    expect(sut.buildNumber) == 312
                }
                it("has force update versions") {
                    expect(sut.forceUpdateVersions) == [1,2,3]
                }
                it("has config url with default value") {
                    expect(sut.configURL) == ""
                }
                it("has quad key zoom level") {
                    expect(sut.quadKeyZoomLevel) == 15
                }
            }
            
            context("with a json that has not quad key zoom level key") {
                beforeEach {
                    json = """
                    {
                        "currentVersionInfo": {
                            "buildNumber": 312,
                            "forceUpdateVersions": [1, 2, 3]
                        },
                        "configURL": "https://cdn.letgo.com/config/ios.json"
                    }
                    """.data(using: .utf8)
                    sut = try? JSONDecoder().decode(Config.self, from: json)
                }
                
                it("returns a config object") {
                    expect(sut).notTo(beNil())
                }
                it("has build number") {
                    expect(sut.buildNumber) == 312
                }
                it("has force update versions") {
                    expect(sut.forceUpdateVersions) == [1,2,3]
                }
                it("has config url") {
                    expect(sut.configURL) == "https://cdn.letgo.com/config/ios.json"
                }
                it("has quad key zoom level with default value") {
                    expect(sut.quadKeyZoomLevel) == 13
                }
            }
        }
        
        describe("encode") {
            beforeEach {
                let json = """
                {
                    "currentVersionInfo": {
                        "buildNumber": 312,
                        "forceUpdateVersions": [1, 2, 3]
                    },
                    "configURL": "https://cdn.letgo.com/config/ios.json",
                    "quadKeyZoomLevel": 15
                }
                """.data(using: .utf8)!
                let configObject = try? JSONDecoder().decode(Config.self, from: json)
                let newJSON: Data! = try? JSONEncoder().encode(configObject)
                sut = try? JSONDecoder().decode(Config.self, from: newJSON)
            }
            
            it("returns a config object") {
                expect(sut).notTo(beNil())
            }
            it("has build number") {
                expect(sut.buildNumber) == 312
            }
            it("has force update versions") {
                expect(sut.forceUpdateVersions) == [1,2,3]
            }
            it("has config url") {
                expect(sut.configURL) == "https://cdn.letgo.com/config/ios.json"
            }
            it("has quad key zoom level") {
                expect(sut.quadKeyZoomLevel) == 15
            }
        }
    }
}
