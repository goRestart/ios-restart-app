//
//  LGEmojiSpec.swift
//  letgoTests
//
//  Created by Nestor on 08/02/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

@testable import LGComponents
import Quick
import Nimble

class LGEmojiSpec: QuickSpec {
    override func spec() {
        var sut: String!
        let sutNormalText = [" ","  ","ñ","Ñ","aasdf","ABASDL","83792159","Letgo","!@#$","%^&","*()_+",".><,","/?", ":;'",
                             "汉字","العربية ","देवनागरी","পূৰ্বী নাগৰী","Кириллица","かな","ꦗꦮ","조선글","తెలుగు","தமிழ்",
                             "ગુજરાતી","ಕನ್ನಡ","မြန်မာ","മലയാളം","ไทย","ᮞᮥᮔ᮪ᮓ","ਗੁਰਮੁਖੀ","ລາວ","ଉତ୍କଳ","ግዕዝ","සිංහල","אלפבית",
                             "Հայոց","ខ្មែរ","Ελληνικό","ᯅᯖᯂ᯲","ᨒᨚᨈᨑ","ᬩᬮᬶ","བོད","ქართული","ꆈꌠ","ᠮᠣᠩᠭᠣᠯ","ⵜⵉⴼⵉⵏⴰⵖ",
                             "ᥖᥭᥰᥘᥫᥴ","ᦑᦟᦹᧉ","ܣܘܪܝܬ","ދިވެހި","ᐃᓄᒃᑎᑐᑦ","ᏣᎳᎩ","ᜱᜨᜳᜨᜳᜢ"]
        let sutSingleUnicodeScalarEmojis = ["😀","🤔","😮","😔","😢","😵","🤢","🤠","👹","🤖","🙉","👱","🙇","🏃","⛷",
                                            "💑","👆","🤝","❤","🕶","🐕","🐑","🐤","🐔","🐢","🐜","🍊","🥝","🥑","🍕",
                                            "🥗","🍛","🍩","🍷","🔪","🌏","🗻","🏤","🕌","🌉","🚞","🛵","🚤","🛫",
                                            "🕦","🌔","🌧","💧","🎈","🥇","🏐","🥊","🎱","🔊","🎤","📲","🖲","📺",
                                            "📙","💳","📪","🖌","📇","🗑","🗝","⚔","💊","🚽","🏧","⛔","🔝","✝",
                                            "♐","📶","✅","❌","❗","💯","🔴"]
        let sutMultipleUnicodeScalarEmojis = ["👍🏿","🤘🏽","👩🏾‍🚀","👨🏽‍🚒","👮🏼","🕵🏼‍♂️","💂🏻‍♀️","👷🏼‍♂️","👳🏻","👨🏿‍⚕️","🤰🏼","🤶🏻",
                                              "🙍🏽","💃🏿","🛌🏿","🏄🏻‍♀️","🏋🏾‍♀️","👩‍👦‍👦","👨‍👩‍👧‍👧","🙏🏿","🇱🇺","🇧🇪","🏴"]
        describe("Emojis") {
            beforeEach {
                sut = ""
            }
            context("detection") {
                it("normal text") {
                    for normalText in sutNormalText {
                        sut = normalText
                        expect(sut.containsEmoji).to(beFalse(), description: "'\(sut!)'.containsEmoji")
                        expect(sut.containsOnlyEmoji).to(beFalse(), description: "'\(sut!)'.containsOnlyEmoji")
                        expect(sut.emojiOnlyCount).to(equal(0), description: "'\(sut!)'.emojiOnlyCount")
                    }
                }
                context("one emoji") {
                    context("single unicode scalar") {
                        it("without text") {
                            for emoji in sutSingleUnicodeScalarEmojis {
                                sut = emoji
                                expect(sut.containsEmoji).to(beTrue(), description: "'\(sut!)'.containsEmoji")
                                expect(sut.containsOnlyEmoji).to(beTrue(), description: "'\(sut!)'.containsOnlyEmoji")
                                expect(sut.emojiOnlyCount).to(equal(1), description: "'\(sut!)'.emojiOnlyCount")
                            }
                        }
                        it("with text") {
                            for emoji in sutSingleUnicodeScalarEmojis {
                                for text in sutNormalText {
                                    sut = String((emoji + text).shuffled())
                                    expect(sut.containsEmoji).to(beTrue(), description: "'\(sut!)'.containsEmoji")
                                    expect(sut.containsOnlyEmoji).to(beFalse(), description: "'\(sut!)'.containsOnlyEmoji")
                                    expect(sut.emojiOnlyCount).to(equal(0), description: "'\(sut!)'.emojiOnlyCount")
                                }
                            }
                        }
                    }
                    context("multiple unicode scalar") {
                        it("without text") {
                            for emoji in sutMultipleUnicodeScalarEmojis {
                                sut = emoji
                                expect(sut.containsEmoji).to(beTrue(), description: "'\(sut!)'.containsEmoji")
                                expect(sut.containsOnlyEmoji).to(beTrue(), description: "'\(sut!)'.containsOnlyEmoji")
                                expect(sut.emojiOnlyCount).to(equal(1), description: "'\(sut!)'.emojiOnlyCount")
                            }
                        }
                        it("with text") {
                            for emoji in sutMultipleUnicodeScalarEmojis {
                                for text in sutNormalText {
                                    sut = String((emoji + text).shuffled())
                                    expect(sut.containsEmoji).to(beTrue(), description: "'\(sut!)'.containsEmoji")
                                    expect(sut.containsOnlyEmoji).to(beFalse(), description: "'\(sut!)'.containsOnlyEmoji")
                                    expect(sut.emojiOnlyCount).to(equal(0), description: "'\(sut!)'.emojiOnlyCount")
                                }
                            }
                        }
                    }
                }
                context("more than one emoji") {
                    context("single unicode scalar") {
                        it("without text") {
                            for emoji in sutSingleUnicodeScalarEmojis {
                                sut = emoji
                                let numberOfEmojisToAdd = Int.makeRandom(min: 0, max: 3)
                                for _ in 0..<numberOfEmojisToAdd {
                                    sut = sut + sutSingleUnicodeScalarEmojis.random()!
                                }
                                sut = String(sut.shuffled())
                                expect(sut.containsEmoji).to(beTrue(), description: "'\(sut!)'.containsEmoji")
                                expect(sut.containsOnlyEmoji).to(beTrue(), description: "'\(sut!)'.containsOnlyEmoji")
                                expect(sut.emojiOnlyCount).to(equal(numberOfEmojisToAdd+1), description: "'\(sut!)'.emojiOnlyCount")
                            }
                        }
                        it("with text") {
                            for emoji in sutSingleUnicodeScalarEmojis {
                                for text in sutNormalText {
                                    sut = emoji
                                    let numberOfEmojisToAdd = Int.makeRandom(min: 0, max: 3)
                                    for _ in 0..<numberOfEmojisToAdd {
                                        sut = sut + sutSingleUnicodeScalarEmojis.random()!
                                    }
                                    sut = String((sut + text).shuffled())
                                    expect(sut.containsEmoji).to(beTrue(), description: "'\(sut!)'.containsEmoji")
                                    expect(sut.containsOnlyEmoji).to(beFalse(), description: "'\(sut!)'.containsOnlyEmoji")
                                    expect(sut.emojiOnlyCount).to(equal(0), description: "'\(sut!)'.emojiOnlyCount")
                                }
                            }
                        }
                    }
                    context("multiple unicode scalar") {
                        it("without text") {
                            for emoji in sutMultipleUnicodeScalarEmojis {
                                sut = emoji
                                let numberOfEmojisToAdd = Int.makeRandom(min: 0, max: 3)
                                for _ in 0..<numberOfEmojisToAdd {
                                    sut = sut + sutMultipleUnicodeScalarEmojis.random()!
                                }
                                sut = String(sut.shuffled())
                                expect(sut.containsEmoji).to(beTrue(), description: "'\(sut!)'.containsEmoji")
                                expect(sut.containsOnlyEmoji).to(beTrue(), description: "'\(sut!)'.containsOnlyEmoji")
                                expect(sut.emojiOnlyCount).to(equal(numberOfEmojisToAdd+1), description: "'\(sut!)'.emojiOnlyCount")
                            }
                        }
                        it("with text") {
                            for emoji in sutMultipleUnicodeScalarEmojis {
                                for text in sutNormalText {
                                    sut = emoji
                                    let numberOfEmojisToAdd = Int.makeRandom(min: 0, max: 3)
                                    for _ in 0..<numberOfEmojisToAdd {
                                        sut = sut + sutMultipleUnicodeScalarEmojis.random()!
                                    }
                                    sut = String((sut + text).shuffled())
                                    expect(sut.containsEmoji).to(beTrue(), description: "'\(sut!)'.containsEmoji")
                                    expect(sut.containsOnlyEmoji).to(beFalse(), description: "'\(sut!)'.containsOnlyEmoji")
                                    expect(sut.emojiOnlyCount).to(equal(0), description: "'\(sut!)'.emojiOnlyCount")
                                }
                            }
                        }
                    }
                    context("mixing single & multiple unicode scalar") {
                        it("without text") {
                            for singleUnicodeScalarEmoji in sutSingleUnicodeScalarEmojis {
                                for multipleUnicodeScalarEmoji in sutMultipleUnicodeScalarEmojis {
                                    sut = singleUnicodeScalarEmoji + multipleUnicodeScalarEmoji
                                    expect(sut.containsEmoji).to(beTrue(), description: "'\(sut!)'.containsEmoji")
                                    expect(sut.containsOnlyEmoji).to(beTrue(), description: "'\(sut!)'.containsOnlyEmoji")
                                    expect(sut.emojiOnlyCount).to(equal(2), description: "'\(sut!)'.emojiOnlyCount")
                                }
                            }
                        }
                        it("with text") {
                            for singleUnicodeScalarEmoji in sutSingleUnicodeScalarEmojis {
                                for multipleUnicodeScalarEmoji in sutMultipleUnicodeScalarEmojis {
                                    sut = String(singleUnicodeScalarEmoji + multipleUnicodeScalarEmoji + String.makeRandom())
                                    expect(sut.containsEmoji).to(beTrue(), description: "'\(sut!)'.containsEmoji")
                                    expect(sut.containsOnlyEmoji).to(beFalse(), description: "'\(sut!)'.containsOnlyEmoji")
                                    expect(sut.emojiOnlyCount).to(equal(0), description: "'\(sut!)'.emojiOnlyCount")
                                }
                            }
                        }
                    }
                }
            }
            describe("removal") {
                it("normal text") {
                    for normalText in sutNormalText {
                        sut = normalText
                        expect(sut.removingEmoji()).to(equal(normalText))
                    }
                }
                context("one emoji") {
                    context("single unicode scalar") {
                        it("without text") {
                            for emoji in sutSingleUnicodeScalarEmojis {
                                sut = emoji
                                expect(sut.removingEmoji()).to(equal(""))
                            }
                        }
                        it("with text") {
                            for emoji in sutSingleUnicodeScalarEmojis {
                                for text in sutNormalText {
                                    sut = emoji + text
                                    expect(sut.removingEmoji()).to(equal(text))
                                }
                            }
                        }
                    }
                    context("multiple unicode scalar") {
                        it("without text") {
                            for emoji in sutMultipleUnicodeScalarEmojis {
                                sut = emoji
                                expect(sut.removingEmoji()).to(equal(""))
                            }
                        }
                        it("with text") {
                            for emoji in sutMultipleUnicodeScalarEmojis {
                                for text in sutNormalText {
                                    sut = emoji + text
                                    expect(sut.removingEmoji()).to(equal(text))
                                }
                            }
                        }
                    }
                }
                context("more than one emoji") {
                    context("single unicode scalar") {
                        it("without text") {
                            for emoji in sutSingleUnicodeScalarEmojis {
                                sut = emoji
                                let numberOfEmojisToAdd = Int.makeRandom(min: 0, max: 3)
                                for _ in 0..<numberOfEmojisToAdd {
                                    sut = sut + sutSingleUnicodeScalarEmojis.random()!
                                }
                                expect(sut.removingEmoji()).to(equal(""))
                            }
                        }
                        it("with text") {
                            for emoji in sutSingleUnicodeScalarEmojis {
                                for text in sutNormalText {
                                    sut = emoji
                                    let numberOfEmojisToAdd = Int.makeRandom(min: 0, max: 3)
                                    for _ in 0..<numberOfEmojisToAdd {
                                        sut = sut + sutSingleUnicodeScalarEmojis.random()!
                                    }
                                    sut = String(sut + text)
                                    expect(sut.removingEmoji()).to(equal(text))
                                }
                            }
                        }
                    }
                    context("multiple unicode scalar") {
                        it("without text") {
                            for emoji in sutMultipleUnicodeScalarEmojis {
                                sut = emoji
                                let numberOfEmojisToAdd = Int.makeRandom(min: 0, max: 3)
                                for _ in 0..<numberOfEmojisToAdd {
                                    sut = sut + sutMultipleUnicodeScalarEmojis.random()!
                                }
                                expect(sut.removingEmoji()).to(equal(""))
                            }
                        }
                        it("with text") {
                            for emoji in sutMultipleUnicodeScalarEmojis {
                                for text in sutNormalText {
                                    sut = emoji
                                    let numberOfEmojisToAdd = Int.makeRandom(min: 0, max: 3)
                                    for _ in 0..<numberOfEmojisToAdd {
                                        sut = sut + sutMultipleUnicodeScalarEmojis.random()!
                                    }
                                    sut = String(sut + text)
                                    expect(sut.removingEmoji()).to(equal(text))
                                }
                            }
                        }
                    }
                    context("mixing single & multiple unicode scalar") {
                        it("without text") {
                            for singleUnicodeScalarEmoji in sutSingleUnicodeScalarEmojis {
                                for multipleUnicodeScalarEmoji in sutMultipleUnicodeScalarEmojis {
                                    sut = singleUnicodeScalarEmoji + multipleUnicodeScalarEmoji
                                    expect(sut.removingEmoji()).to(equal(""))
                                }
                            }
                        }
                        it("with text") {
                            for singleUnicodeScalarEmoji in sutSingleUnicodeScalarEmojis {
                                for multipleUnicodeScalarEmoji in sutMultipleUnicodeScalarEmojis {
                                    let text = String.makeRandom()
                                    sut = String(singleUnicodeScalarEmoji + multipleUnicodeScalarEmoji + text)
                                    expect(sut.removingEmoji()).to(equal(text))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
