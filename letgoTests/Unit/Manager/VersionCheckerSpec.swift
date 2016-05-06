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
        describe("check version change") {
            context("major changed") {
                beforeEach {
                    sut = VersionChecker(appVersion: MockAppVersion(version: "2.1.1"), lastAppVersion: "1.1.1")
                }
                it("major changed") {
                    expect(sut.versionChange) == VersionChange.Major
                }
            }

            context("minor changed") {
                beforeEach {
                    sut = VersionChecker(appVersion: MockAppVersion(version: "1.2.1"), lastAppVersion: "1.1.1")
                }
                it("major changed") {
                    expect(sut.versionChange) == VersionChange.Minor
                }
            }

            context("patch changed") {
                beforeEach {
                    sut = VersionChecker(appVersion: MockAppVersion(version: "1.1.2"), lastAppVersion: "1.1.1")
                }
                it("major changed") {
                    expect(sut.versionChange) == VersionChange.Patch
                }
            }

            context("no changes") {
                beforeEach {
                    sut = VersionChecker(appVersion: MockAppVersion(version: "1.1.1"), lastAppVersion: "1.1.1")
                }
                it("major changed") {
                    expect(sut.versionChange) == VersionChange.None
                }
            }

            context("weird current version") {
                beforeEach {
                    sut = VersionChecker(appVersion: MockAppVersion(version: "1.1"), lastAppVersion: "1.1.0")
                }
                it("major changed") {
                    expect(sut.versionChange) == VersionChange.None
                }
            }

            context("weird last version") {
                beforeEach {
                    sut = VersionChecker(appVersion: MockAppVersion(version: "1.1.1"), lastAppVersion: "1.1")
                }
                it("major changed") {
                    expect(sut.versionChange) == VersionChange.None
                }
            }
        }
    }
}
