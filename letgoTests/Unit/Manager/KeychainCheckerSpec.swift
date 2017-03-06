//
//  KeychainCheckerSpec.swift
//  LetGo
//
//  Created by Eli Kohen on 23/01/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import Quick
import Nimble

class KeychainCheckerSpec: QuickSpec {
    override func spec() {
        describe("KeychainCheckerSpec") {
            var sut: KeychainChecker!
            var booleanDao: MockBooleanDao!
            var keychainCleaner: MockKeychainCleaner!

            beforeEach {
                booleanDao = MockBooleanDao()
                keychainCleaner = MockKeychainCleaner()
                sut = KeychainChecker(booleanDao: booleanDao, keychainCleaner: keychainCleaner, enabled: true)
            }
            describe("check keychain") {
                context("switch in settings to off") {
                    beforeEach {
                        booleanDao.getValue = false
                        sut.checkKeychain()
                    }
                    it("uses the correct ud key") {
                        expect(booleanDao.lastGetKey) == "god_mode_cleanup_keychain"
                    }
                    it("doesn't call cleanup") {
                        expect(keychainCleaner.calledClean) == false
                    }
                    it("doesn't set any ud value") {
                        expect(booleanDao.lastSetValue).to(beNil())
                    }
                }
                context("switch in settings to on") {
                    beforeEach {
                        booleanDao.getValue = true
                        sut.checkKeychain()
                    }
                    it("uses the correct ud key") {
                        expect(booleanDao.lastGetKey) == "god_mode_cleanup_keychain"
                    }
                    it("calls cleanup") {
                        expect(keychainCleaner.calledClean) == true
                    }
                    it("sets the correct ud value") {
                        expect(booleanDao.lastSetKey) == "god_mode_cleanup_keychain"
                    }
                    it("sets the ud value to false") {
                        expect(booleanDao.lastSetValue) == false
                    }
                }
            }
        }
    }
}
