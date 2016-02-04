//
//  ChatViewModelSpec.swift
//  LetGo
//
//  Created by Dídac on 04/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGo
import LGCoreKit
import Quick
import Nimble

class ChatViewModelSpec: QuickSpec {
    override func spec() {

        var insertedMessagesInfo: (messages: [Message], indexes: [Int])?

        describe("insert new messages at table") {

            beforeEach {
                insertedMessagesInfo = nil
            }

            context ("two empty arrays") {
                beforeEach {
                    let mainArray: [Message] = []
                    let newArray: [Message] = []

                    insertedMessagesInfo = ChatViewModel.insertNewMessagesAt(mainArray, newMessages: newArray)
                }
                it ("returning messages array is empty") {
                    expect(insertedMessagesInfo?.messages.count) == 0
                }
                it ("returning indexes array is empty") {
                    expect(insertedMessagesInfo?.indexes.count) == 0
                }
            }

            describe("happy scenario, no nil values for ids") {
                context ("main Array empty, new array has values") {
                    beforeEach {
                        var msg1 = LGMessage()
                        msg1.objectId = "1"
                        var msg2 = LGMessage()
                        msg2.objectId = "2"

                        let mainArray: [Message] = []
                        let newArray: [Message] = [msg1, msg2]

                        insertedMessagesInfo = ChatViewModel.insertNewMessagesAt(mainArray, newMessages: newArray)
                    }
                    it ("returning messages array has 2 elements") {
                        expect(insertedMessagesInfo?.messages.count) == 2
                    }
                    it ("returning messages array 1st element id is '1' ") {
                        expect(insertedMessagesInfo?.messages[0].objectId) == "1"
                    }
                    it ("returning indexes array has 2 elements") {
                        expect(insertedMessagesInfo?.indexes.count) == 2
                    }
                }

                context ("main Array has values, new array is empty") {
                    beforeEach {
                        var msg1 = LGMessage()
                        msg1.objectId = "1"
                        var msg2 = LGMessage()
                        msg2.objectId = "2"

                        let mainArray: [Message] = [msg1, msg2]
                        let newArray: [Message] = []

                        insertedMessagesInfo = ChatViewModel.insertNewMessagesAt(mainArray, newMessages: newArray)
                    }
                    it ("returning messages array has 2 elements") {
                        expect(insertedMessagesInfo?.messages.count) == 2
                    }
                    it ("returning messages array 1st element id is '1' ") {
                        expect(insertedMessagesInfo?.messages[0].objectId) == "1"
                    }
                    it ("returning indexes array has 0 elements") {
                        expect(insertedMessagesInfo?.indexes.count) == 0
                    }
                }

                context ("both arrays have different values") {
                    beforeEach {
                        var msg1 = LGMessage()
                        msg1.objectId = "1"
                        var msg2 = LGMessage()
                        msg2.objectId = "2"
                        var msg3 = LGMessage()
                        msg3.objectId = "3"
                        var msg4 = LGMessage()
                        msg4.objectId = "4"

                        let mainArray: [Message] = [msg1, msg2]
                        let newArray: [Message] = [msg3, msg4]

                        insertedMessagesInfo = ChatViewModel.insertNewMessagesAt(mainArray, newMessages: newArray)
                    }
                    it ("returning messages array has 4 elements") {
                        expect(insertedMessagesInfo?.messages.count) == 4
                    }
                    it ("returning messages array 3rd element id is '1' ") {
                        expect(insertedMessagesInfo?.messages[2].objectId) == "1"
                    }
                    it ("returning indexes array has 2 elements") {
                        expect(insertedMessagesInfo?.indexes.count) == 2
                    }
                }

                context ("both arrays have values, some repeated") {
                    beforeEach {
                        var msg1 = LGMessage()
                        msg1.objectId = "1"
                        var msg2 = LGMessage()
                        msg2.objectId = "2"
                        var msg3 = LGMessage()
                        msg3.objectId = "3"

                        let mainArray: [Message] = [msg2, msg1]
                        let newArray: [Message] = [msg3, msg2]

                        insertedMessagesInfo = ChatViewModel.insertNewMessagesAt(mainArray, newMessages: newArray)
                    }
                    it ("returning messages array has 3 elements") {
                        expect(insertedMessagesInfo?.messages.count) == 3
                    }
                    it ("returning messages array 3rd element id is '1' ") {
                        expect(insertedMessagesInfo?.messages[2].objectId) == "1"
                    }
                    it ("returning indexes array has 1 elements") {
                        expect(insertedMessagesInfo?.indexes.count) == 1
                    }
                }
            }

            describe("not-so-happy scenario, user writes, and mainArray can has nil values for ids") {

                context ("main Array empty, new array has values") {
                    beforeEach {
                        var msg1 = LGMessage()
                        msg1.objectId = "1"
                        var msg2 = LGMessage()
                        msg2.objectId = "2"

                        let mainArray: [Message] = []
                        let newArray: [Message] = [msg1, msg2]

                        insertedMessagesInfo = ChatViewModel.insertNewMessagesAt(mainArray, newMessages: newArray)
                    }
                    it ("returning messages array has 2 elements") {
                        expect(insertedMessagesInfo?.messages.count) == 2
                    }
                    it ("returning messages array 1st element id is '1' ") {
                        expect(insertedMessagesInfo?.messages[0].objectId) == "1"
                    }
                    it ("returning indexes array has 2 elements") {
                        expect(insertedMessagesInfo?.indexes.count) == 2
                    }
                }

                context ("main Array has values, new array is empty") {
                    beforeEach {
                        var msg1 = LGMessage()
                        msg1.objectId = "1"
                        var msgWritten = LGMessage()
                        msgWritten.objectId = nil

                        let mainArray: [Message] = [msg1, msgWritten]
                        let newArray: [Message] = []

                        insertedMessagesInfo = ChatViewModel.insertNewMessagesAt(mainArray, newMessages: newArray)
                    }
                    it ("returning messages array has 2 elements") {
                        expect(insertedMessagesInfo?.messages.count) == 2
                    }
                    it ("returning messages array 1st element id is '1' ") {
                        expect(insertedMessagesInfo?.messages[0].objectId) == "1"
                    }
                    it ("returning messages array 2nd element id is 'nil' ") {
                        expect(insertedMessagesInfo?.messages[1].objectId).to(beNil())
                    }
                    it ("returning indexes array has 0 elements") {
                        expect(insertedMessagesInfo?.indexes.count) == 0
                    }
                }

                context ("both arrays have different values") {
                    beforeEach {
                        var msg1 = LGMessage()
                        msg1.objectId = "1"
                        var msgWritten = LGMessage()
                        msgWritten.objectId = nil
                        var msg3 = LGMessage()
                        msg3.objectId = "3"
                        var msg4 = LGMessage()
                        msg4.objectId = "4"

                        let mainArray: [Message] = [msgWritten, msg1]
                        let newArray: [Message] = [msg4, msg3]

                        insertedMessagesInfo = ChatViewModel.insertNewMessagesAt(mainArray, newMessages: newArray)
                    }
                    it ("returning messages array has 4 elements") {
                        expect(insertedMessagesInfo?.messages.count) == 3
                    }
                    it ("returning messages array 3rd element id is '1' ") {
                        expect(insertedMessagesInfo?.messages[2].objectId) == "1"
                    }
                    it ("returning messages array 2nd element id is '3' ") {
                        expect(insertedMessagesInfo?.messages[1].objectId) == "3"
                    }
                    it ("returning indexes array has 1 element") {
                        expect(insertedMessagesInfo?.indexes.count) == 1
                    }
                }

                context ("both arrays have values, some repeated") {
                    beforeEach {
                        var msg1 = LGMessage()
                        msg1.objectId = "1"
                        var msg2 = LGMessage()
                        msg2.objectId = "2"
                        var msgWritten = LGMessage()
                        msgWritten.objectId = nil
                        var msg3 = LGMessage()
                        msg3.objectId = "3"

                        let mainArray: [Message] = [msgWritten, msg2, msg1]
                        let newArray: [Message] = [msg3, msg2]

                        insertedMessagesInfo = ChatViewModel.insertNewMessagesAt(mainArray, newMessages: newArray)
                    }
                    it ("returning messages array has 3 elements") {
                        expect(insertedMessagesInfo?.messages.count) == 3
                    }
                    it ("returning messages array 3rd element id is '1' ") {
                        expect(insertedMessagesInfo?.messages[2].objectId) == "1"
                    }
                    it ("returning messages array 2nd element id is '2' ") {
                        expect(insertedMessagesInfo?.messages[1].objectId) == "2"
                    }
                    it ("returning messages array 1st element id is '3' ") {
                        expect(insertedMessagesInfo?.messages[0].objectId) == "3"
                    }
                    it ("returning indexes array has 0 elements") {
                        expect(insertedMessagesInfo?.indexes.count) == 0
                    }
                }

                context ("both arrays have values, several written messages") {
                    beforeEach {
                        var msg1 = LGMessage()
                        msg1.objectId = "1"
                        var msg2 = LGMessage()
                        msg2.objectId = "2"
                        var msgWritten = LGMessage()
                        msgWritten.objectId = nil
                        var msg3 = LGMessage()
                        msg3.objectId = "3"
                        var msg4 = LGMessage()
                        msg4.objectId = "4"
                        var msg5 = LGMessage()
                        msg5.objectId = "5"

                        let mainArray: [Message] = [msgWritten, msgWritten, msgWritten, msg2, msg1]
                        let newArray: [Message] = [msg5, msg4, msg3, msg2]

                        insertedMessagesInfo = ChatViewModel.insertNewMessagesAt(mainArray, newMessages: newArray)
                    }
                    it ("returning messages array has 3 elements") {
                        expect(insertedMessagesInfo?.messages.count) == 5
                    }
                    it ("returning messages array 5th element id is '1' ") {
                        expect(insertedMessagesInfo?.messages[4].objectId) == "1"
                    }
                    it ("returning messages array 4th element id is '2' ") {
                        expect(insertedMessagesInfo?.messages[3].objectId) == "2"
                    }
                    it ("returning messages array 3rd element id is '3' ") {
                        expect(insertedMessagesInfo?.messages[2].objectId) == "3"
                    }
                    it ("returning messages array 2nd element id is '4' ") {
                        expect(insertedMessagesInfo?.messages[1].objectId) == "4"
                    }
                    it ("returning messages array 1st element id is '5' ") {
                        expect(insertedMessagesInfo?.messages[0].objectId) == "5"
                    }
                    it ("returning indexes array has 0 elements") {
                        expect(insertedMessagesInfo?.indexes.count) == 0
                    }
                }
            }


        }
    }
}

