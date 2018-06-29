
import Quick
import Nimble
@testable import LetGoGodMode

class AccessibilityIdSpec: QuickSpec {
    
    override func spec() {
        
        describe("test the rangeIdentifier:forBound function") {
            let identifierPrefix = String.makeRandom()
            var sut: String!
            
            context("no values are passed in") {
                beforeEach {
                    sut = AccessibilityId.rangeIdentifier(forRange: AccessibilityRange(withLowerBound: nil,
                                                                                       upperBound: nil),
                                                          identifierPrefix: identifierPrefix)
                }
                
                it("should be a string containing only the identifier prefix") {
                    expect(sut) == identifierPrefix+"-_"
                }
            }
            
            context("only a lowerbound is passed in") {
                beforeEach {
                    sut = AccessibilityId.rangeIdentifier(forRange: AccessibilityRange(withLowerBound: 4,
                                                                                       upperBound: nil),
                                                          identifierPrefix: identifierPrefix)
                }
                
                it("should be a string containing only the identifier prefix and the lowerbound") {
                    expect(sut) == identifierPrefix+"-\(4)_"
                }
            }
            
            context("only an upperbound is passed in") {
                beforeEach {
                    sut = AccessibilityId.rangeIdentifier(forRange: AccessibilityRange(withLowerBound: nil,
                                                                                       upperBound: 7),
                                                          identifierPrefix: identifierPrefix)
                }
                
                it("should be a string containing only the identifier prefix and the upperbound") {
                    expect(sut) == identifierPrefix+"-_\(7)"
                }
            }
            
            context("both an upper an lowerbound are passed in") {
                beforeEach {
                    sut = AccessibilityId.rangeIdentifier(forRange: AccessibilityRange(withLowerBound: 26,
                                                                                       upperBound: 84),
                                                          identifierPrefix: identifierPrefix)
                }
                
                it("should be a string containing only the identifier prefix and both bounds") {
                    expect(sut) == identifierPrefix+"-\(26)_\(84)"
                }
            }
        
        }
    }
}
