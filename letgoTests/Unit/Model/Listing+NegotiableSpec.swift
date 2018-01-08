//
//  Listing+NegotiableSpec.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 25/08/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Quick
import Nimble
import LGCoreKit
@testable import LetGoGodMode

class ListingNegotiableSpec: QuickSpec {

    override func spec() {
        
        var listing: Listing!
        var freeModeAllowed: Bool!
        
        describe("Listing+Negotiable isNegotiable func") {
            context("free listing") {
                beforeEach {
                    listing = Listing.makeListing(price: ListingPrice.free)
                    freeModeAllowed = Bool.makeRandom()
                }
                it("can return true or false, depending freeModeAllowed value") {
                    expect(listing.isNegotiable(freeModeAllowed: freeModeAllowed)) == !freeModeAllowed
                }
            }
            context("price is 0") {
                beforeEach {
                    listing = Listing.makeListing(price: ListingPrice.normal(0))
                    freeModeAllowed = Bool.makeRandom()
                }
                it("returns true") {
                    expect(listing.isNegotiable(freeModeAllowed: freeModeAllowed)).to(beTrue())
                }
            }
            context("price is different than 0") {
                beforeEach {
                    listing = Listing.makeListing(price: ListingPrice.normal(Double.makeRandom()))
                    freeModeAllowed = Bool.makeRandom()
                }
                it("returns false") {
                    expect(listing.isNegotiable(freeModeAllowed: freeModeAllowed)).to(beFalse())
                }
            }
        }
    }
}
