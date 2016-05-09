//
//  VersionCheckerSpec.swift
//  LetGo
//
//  Created by Dídac on 05/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGo
import LGCoreKit
import Quick
import Nimble

class VersionCheckerSpec: QuickSpec {
    override func spec() {
        var sut: VersionChecker!

        beforeEach {
            sut = VersionChecker(appVersion: MockAppVersion(version: "0.0.0"), lastAppVersion: "0.0.0")
        }
        fdescribe("check version change") {
            context("major update") {
                beforeEach {
                    sut = VersionChecker(appVersion: MockAppVersion(version: "2.1.1"), lastAppVersion: "1.1.1")
                }
                it("registers a major version change") {
                    expect(sut.versionChange) == VersionChange.Major
                }
            }

            context("minor update") {
                beforeEach {
                    sut = VersionChecker(appVersion: MockAppVersion(version: "1.2.1"), lastAppVersion: "1.1.1")
                }
                it("registers a minor version change") {
                    expect(sut.versionChange) == VersionChange.Minor
                }
            }

            context("patch update") {
                beforeEach {
                    sut = VersionChecker(appVersion: MockAppVersion(version: "1.1.2"), lastAppVersion: "1.1.1")
                }
                it("registers a patch version change") {
                    expect(sut.versionChange) == VersionChange.Patch
                }
            }

            context("no update") {
                beforeEach {
                    sut = VersionChecker(appVersion: MockAppVersion(version: "1.1.1"), lastAppVersion: "1.1.1")
                }
                it("registers no version change") {
                    expect(sut.versionChange) == VersionChange.None
                }
            }

            context("current version same minor but missing patch") {
                beforeEach {
                    sut = VersionChecker(appVersion: MockAppVersion(version: "1.1"), lastAppVersion: "1.1.0")
                }
                it("registers no version change") {
                    expect(sut.versionChange) == VersionChange.None
                }
            }

            context("current version minor update but missing patch") {
                beforeEach {
                    sut = VersionChecker(appVersion: MockAppVersion(version: "1.2"), lastAppVersion: "1.1.0")
                }
                it("registers a minor version change") {
                    expect(sut.versionChange) == VersionChange.Minor
                }
            }

            context("current version patch update but last version missing patch") {
                beforeEach {
                    sut = VersionChecker(appVersion: MockAppVersion(version: "1.1.1"), lastAppVersion: "1.1")
                }
                it("has registered a patch version change") {
                    expect(sut.versionChange) == VersionChange.Patch
                }
            }

            context("downgrade") {
                beforeEach {
                    sut = VersionChecker(appVersion: MockAppVersion(version: "1.1.1"), lastAppVersion: "1.1.2")
                }
                it("registers no version change") {
                    expect(sut.versionChange) == VersionChange.None
                }
            }
        }
    }
}
