//
//  VersionCheckerSpec.swift
//  LetGo
//
//  Created by Dídac on 05/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble

class VersionCheckerSpec: QuickSpec {
    override func spec() {
        var sut: VersionChecker!

        beforeEach {
            sut = VersionChecker(currentVersion: MockAppVersion(version: "0.0.0"), previousVersion: "0.0.0")
        }
        describe("check version change") {
            context("fresh install") {
                beforeEach {
                    sut = VersionChecker(currentVersion: MockAppVersion(version: "1.0.0"), previousVersion: nil)
                }
                it("registers a new install version change") {
                    expect(sut.versionChange) == VersionChange.newInstall
                }
            }
            context("major update") {
                beforeEach {
                    sut = VersionChecker(currentVersion: MockAppVersion(version: "2.1.1"), previousVersion: "1.1.1")
                }
                it("registers a major version change") {
                    expect(sut.versionChange) == VersionChange.major
                }
            }

            context("minor update") {
                beforeEach {
                    sut = VersionChecker(currentVersion: MockAppVersion(version: "1.2.1"), previousVersion: "1.1.1")
                }
                it("registers a minor version change") {
                    expect(sut.versionChange) == VersionChange.minor
                }
            }

            context("patch update") {
                beforeEach {
                    sut = VersionChecker(currentVersion: MockAppVersion(version: "1.1.2"), previousVersion: "1.1.1")
                }
                it("registers a patch version change") {
                    expect(sut.versionChange) == VersionChange.patch
                }
            }

            context("no update") {
                beforeEach {
                    sut = VersionChecker(currentVersion: MockAppVersion(version: "1.1.1"), previousVersion: "1.1.1")
                }
                it("registers no version change") {
                    expect(sut.versionChange) == VersionChange.none
                }
            }

            context("current version same minor but missing patch") {
                beforeEach {
                    sut = VersionChecker(currentVersion: MockAppVersion(version: "1.1"), previousVersion: "1.1.0")
                }
                it("registers no version change") {
                    expect(sut.versionChange) == VersionChange.none
                }
            }

            context("current version minor update but missing patch") {
                beforeEach {
                    sut = VersionChecker(currentVersion: MockAppVersion(version: "1.2"), previousVersion: "1.1.0")
                }
                it("registers a minor version change") {
                    expect(sut.versionChange) == VersionChange.minor
                }
            }

            context("current version patch update but last version missing patch") {
                beforeEach {
                    sut = VersionChecker(currentVersion: MockAppVersion(version: "1.1.1"), previousVersion: "1.1")
                }
                it("has registered a patch version change") {
                    expect(sut.versionChange) == VersionChange.patch
                }
            }

            context("patch update with non-sense long version formatting") {
                beforeEach {
                    sut = VersionChecker(currentVersion: MockAppVersion(version: "1.1.1.1.1.1.1"),
                        previousVersion: "1.1.1.1.1")
                }
                it("has registered a patch version change") {
                    expect(sut.versionChange) == VersionChange.patch
                }
            }

            context("downgrade") {
                beforeEach {
                    sut = VersionChecker(currentVersion: MockAppVersion(version: "1.1.1"), previousVersion: "1.1.2")
                }
                it("registers no version change") {
                    expect(sut.versionChange) == VersionChange.none
                }
            }
        }
    }
}
