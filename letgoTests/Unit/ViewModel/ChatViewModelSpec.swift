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

extension ChatViewMessage {
    static func mock(objectId: String?) -> ChatViewMessage {
        return ChatViewMessage(objectId: objectId, talkerId: "", sentAt: NSDate(),
                               receivedAt: NSDate(), readAt: NSDate(), type: .Text(text: "text"), status: .Sent,
                               warningStatus: .Normal)
    }
}

class ChatViewModelSpec: QuickSpec {
    override func spec() {

        var insertedMessagesInfo: (messages: [ChatViewMessage], indexes: [Int], isUpdate: Bool)?

        describe("insert new messages at table") {

            beforeEach {
                insertedMessagesInfo = nil
            }

            context ("two empty arrays") {
                beforeEach {
                    let mainArray: [ChatViewMessage] = []
                    let newArray: [ChatViewMessage] = []

                    insertedMessagesInfo = OldChatViewModel.insertNewMessagesAt(mainArray, newMessages: newArray)
                }
                it ("returning messages array is empty") {
                    expect(insertedMessagesInfo?.messages.count) == 0
                }
                it ("returning indexes array is empty") {
                    expect(insertedMessagesInfo?.indexes.count) == 0
                }
                it ("is an update") {
                    expect(insertedMessagesInfo?.isUpdate) == false
                }
            }

            describe("happy scenario, no nil values for ids") {
                context ("main Array empty, new array has values") {
                    beforeEach {
                        let msg1 = ChatViewMessage.mock("1")
                        let msg2 = ChatViewMessage.mock("2")

                        let mainArray: [ChatViewMessage] = []
                        let newArray: [ChatViewMessage] = [msg1, msg2]

                        insertedMessagesInfo = OldChatViewModel.insertNewMessagesAt(mainArray, newMessages: newArray)
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
                    it ("is an update") {
                        expect(insertedMessagesInfo?.isUpdate) == false
                    }
                }

                context ("main Array has values, new array is empty") {
                    beforeEach {
                        let msg1 = ChatViewMessage.mock("1")
                        let msg2 = ChatViewMessage.mock("2")

                        let mainArray: [ChatViewMessage] = [msg1, msg2]
                        let newArray: [ChatViewMessage] = []

                        insertedMessagesInfo = OldChatViewModel.insertNewMessagesAt(mainArray, newMessages: newArray)
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
                    it ("is an update") {
                        expect(insertedMessagesInfo?.isUpdate) == false
                    }
                }

                context ("both arrays have different values") {
                    beforeEach {
                        let msg1 = ChatViewMessage.mock("1")
                        let msg2 = ChatViewMessage.mock("2")
                        let msg3 = ChatViewMessage.mock("3")
                        let msg4 = ChatViewMessage.mock("4")
                        
                        let mainArray: [ChatViewMessage] = [msg1, msg2]
                        let newArray: [ChatViewMessage] = [msg3, msg4]

                        insertedMessagesInfo = OldChatViewModel.insertNewMessagesAt(mainArray, newMessages: newArray)
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
                    it ("is an update") {
                        expect(insertedMessagesInfo?.isUpdate) == false
                    }
                }

                context ("both arrays have values, some repeated") {
                    beforeEach {
                        let msg1 = ChatViewMessage.mock("1")
                        let msg2 = ChatViewMessage.mock("2")
                        let msg3 = ChatViewMessage.mock("3")
                        
                        let mainArray: [ChatViewMessage] = [msg2, msg1]
                        let newArray: [ChatViewMessage] = [msg3, msg2]

                        insertedMessagesInfo = OldChatViewModel.insertNewMessagesAt(mainArray, newMessages: newArray)
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
                    it ("is an update") {
                        expect(insertedMessagesInfo?.isUpdate) == false
                    }
                }
            }

            describe("not-so-happy scenario, user writes, and mainArray can has nil values for ids") {

                context ("main Array empty, new array has values") {
                    beforeEach {
                        let msg1 = ChatViewMessage.mock("1")
                        let msg2 = ChatViewMessage.mock("2")
                        
                        let mainArray: [ChatViewMessage] = []
                        let newArray: [ChatViewMessage] = [msg1, msg2]

                        insertedMessagesInfo = OldChatViewModel.insertNewMessagesAt(mainArray, newMessages: newArray)
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
                    it ("is an update") {
                        expect(insertedMessagesInfo?.isUpdate) == false
                    }
                }

                context ("main Array has values, new array is empty") {
                    beforeEach {
                        let msg1 = ChatViewMessage.mock("1")
                        let msgWritten = ChatViewMessage.mock(nil)
                        
                        let mainArray: [ChatViewMessage] = [msg1, msgWritten]
                        let newArray: [ChatViewMessage] = []

                        insertedMessagesInfo = OldChatViewModel.insertNewMessagesAt(mainArray, newMessages: newArray)
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
                    it ("is an update") {
                        expect(insertedMessagesInfo?.isUpdate) == false
                    }
                }

                context ("both arrays have different values") {
                    beforeEach {
                        let msg1 = ChatViewMessage.mock("1")
                        let msgWritten = ChatViewMessage.mock(nil)
                        let msg3 = ChatViewMessage.mock("3")
                        let msg4 = ChatViewMessage.mock("4")
                        
                        let mainArray: [ChatViewMessage] = [msgWritten, msg1]
                        let newArray: [ChatViewMessage] = [msg4, msg3]

                        insertedMessagesInfo = OldChatViewModel.insertNewMessagesAt(mainArray, newMessages: newArray)
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
                        expect(insertedMessagesInfo?.indexes.count) == 2
                    }
                    it ("is an update") {
                        expect(insertedMessagesInfo?.isUpdate) == true
                    }
                }

                context ("both arrays have values, some repeated") {
                    beforeEach {
                        let msg1 = ChatViewMessage.mock("1")
                        let msg2 = ChatViewMessage.mock("2")
                        let msgWritten = ChatViewMessage.mock(nil)
                        let msg3 = ChatViewMessage.mock("3")
                        
                        let mainArray: [ChatViewMessage] = [msgWritten, msg2, msg1]
                        let newArray: [ChatViewMessage] = [msg3, msg2]

                        insertedMessagesInfo = OldChatViewModel.insertNewMessagesAt(mainArray, newMessages: newArray)
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
                        expect(insertedMessagesInfo?.indexes.count) == 1
                    }
                    it ("is an update") {
                        expect(insertedMessagesInfo?.isUpdate) == true
                    }
                }

                context ("both arrays have values, several written messages") {
                    beforeEach {
                        let msg1 = ChatViewMessage.mock("1")
                        let msg2 = ChatViewMessage.mock("2")
                        let msgWritten = ChatViewMessage.mock(nil)
                        let msg3 = ChatViewMessage.mock("3")
                        let msg4 = ChatViewMessage.mock("4")
                        let msg5 = ChatViewMessage.mock("5")
                        
                        let mainArray: [ChatViewMessage] = [msgWritten, msgWritten, msgWritten, msg2, msg1]
                        let newArray: [ChatViewMessage] = [msg5, msg4, msg3, msg2]

                        insertedMessagesInfo = OldChatViewModel.insertNewMessagesAt(mainArray, newMessages: newArray)
                    }
                    it ("returning messages array has 5 elements") {
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
                        expect(insertedMessagesInfo?.indexes.count) == 3
                    }
                    it ("is an update") {
                        expect(insertedMessagesInfo?.isUpdate) == true
                    }
                }
            }


        }
    }
}

