//
//  MeetingParserSpec.swift
//  letgoTests
//
//  Created by Dídac on 26/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble

class MeetingParserSpec: QuickSpec {
    override func spec() {
        var sut: LGMeetingParser!
        var dateFormatter: DateFormatter!

        fdescribe("Meeting Parser") {
            describe("create meeting from string") {
                var messageText: String!
                var meeting: AssistantMeeting!
                beforeEach {
                    sut = LGMeetingParser()
                    dateFormatter = DateFormatter()
                    dateFormatter.timeZone = TimeZone.current
                    dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a ZZZZ"
                }
                context("completely invalid string") {
                    beforeEach {
                        messageText = "random dumb text"
                        meeting = sut.createMeetingFromMessage(message: messageText)
                    }
                    it("meeting is nil") {
                        expect(meeting).to(beNil())
                    }
                }
                context("invalid string") {
                    beforeEach {
                        messageText = "Let's meet at:\n\n📍 Pasa tapas, Barcelona (37.42° N, -122.08° E)\n🕐 03/31/2018 04:34 AM GMT"
                        meeting = sut.createMeetingFromMessage(message: messageText)
                    }
                    it("meeting is nil") {
                        expect(meeting).to(beNil())
                    }
                }
                context("valid string, with empty name") {
                    beforeEach {
                        messageText = "🗓 Let's meet at:\n\n📍 (37.42° N,-122.08° E)\n🕐 03/31/2018 04:34 AM GMT"
                        meeting = sut.createMeetingFromMessage(message: messageText)
                    }
                    it("meeting has type requested") {
                        expect(meeting.meetingType) == MeetingMessageType.requested
                    }
                    it("meeting has no name") {
                        expect(meeting.locationName) == ""
                    }
                    it("meeting has a date") {
                        let stringDate = dateFormatter.string(from: meeting.date!)
                        expect(stringDate) == "03/31/2018 06:34 AM GMT+02:00"
                    }
                    it("meeting has no coordinates") {
                        expect(meeting.coordinates).to(beNil())
                    }
                    it("meeting has status") {
                        expect(meeting.status) == MeetingStatus.pending
                    }
                }
                context("valid string, with incorrectly formatted coordinates") {
                    beforeEach {
                        messageText = "🗓 Let's meet at:\n\n📍 Pasa tapas, Barcelona (37.42°N,-122.08°E)\n🕐 03/31/2018 04:34 AM GMT"
                        meeting = sut.createMeetingFromMessage(message: messageText)
                    }
                    it("meeting has type requested") {
                        expect(meeting.meetingType) == MeetingMessageType.requested
                    }
                    it("meeting has a location name") {
                        expect(meeting.locationName) == "Pasa tapas, Barcelona"
                    }
                    it("meeting has a date") {
                        let stringDate = dateFormatter.string(from: meeting.date!)
                        expect(stringDate) == "03/31/2018 06:34 AM GMT+02:00"
                    }
                    it("meeting has no coordinates") {
                        expect(meeting.coordinates).to(beNil())
                    }
                    it("meeting has status") {
                        expect(meeting.status) == MeetingStatus.pending
                    }
                }
                context("valid string, with incorrectly formatted date") {
                    beforeEach {
                        messageText = "🗓 Let's meet at:\n\n📍 Pasa tapas, Barcelona (37.42° N, -122.08° E)\n🕐 03/31/twothousandandpotato 04:34 AM GMT"
                        meeting = sut.createMeetingFromMessage(message: messageText)
                    }
                    it("meeting has type requested") {
                        expect(meeting.meetingType) == MeetingMessageType.requested
                    }
                    it("meeting has a location name") {
                        expect(meeting.locationName) == "Pasa tapas, Barcelona"
                    }
                    it("meeting has a date") {
                        expect(meeting.date).to(beNil())
                    }
                    it("meeting has no coordinates") {
                        expect(meeting.coordinates) == LGLocationCoordinates2D(latitude: 37.42, longitude: -122.08)
                    }
                    it("meeting has status") {
                        expect(meeting.status) == MeetingStatus.pending
                    }
                }
               context("valid string") {
                    beforeEach {
                        messageText = "🗓 Let's meet at:\n\n📍 Pasa tapas, Barcelona (37.42° N, -122.08° E)\n🕐 03/31/2018 04:34 AM GMT"
                        meeting = sut.createMeetingFromMessage(message: messageText)
                    }
                    it("meeting has type requested") {
                        expect(meeting.meetingType) == MeetingMessageType.requested
                    }
                    it("meeting has a location name") {
                        expect(meeting.locationName) == "Pasa tapas, Barcelona"
                    }
                    it("meeting has a date") {
                        let stringDate = dateFormatter.string(from: meeting.date!)
                        expect(stringDate) == "03/31/2018 06:34 AM GMT+02:00"
                    }
                    it("meeting has coordinates") {
                        expect(meeting.coordinates) == LGLocationCoordinates2D(latitude: 37.42, longitude: -122.08)
                    }
                    it("meeting has status") {
                        expect(meeting.status) == MeetingStatus.pending
                    }
                }
            }
            describe("acceptance message") {
                var messageText: String!
                var meeting: AssistantMeeting!
                beforeEach {
                    sut = LGMeetingParser()
                }
                context("invalid string") {
                    beforeEach {
                        messageText = "Let's meet in a shady alley at mdnight!"
                        meeting = sut.createMeetingFromMessage(message: messageText)
                    }
                    it("meeting is nil") {
                        expect(meeting).to(beNil())
                    }
                }
                context("valid string") {
                    beforeEach {
                        messageText = "✅ OK"
                        meeting = sut.createMeetingFromMessage(message: messageText)
                    }
                    it("meeting has type accepted") {
                        expect(meeting.meetingType) == MeetingMessageType.accepted
                    }
                    it("meeting doesn't have location name") {
                        expect(meeting.locationName).to(beNil())
                    }
                    it("meeting doesn't have a date") {
                        expect(meeting.date).to(beNil())
                    }
                    it("meeting doesn't have coordinates") {
                        expect(meeting.coordinates).to(beNil())
                    }
                    it("meeting doesn't have status") {
                        expect(meeting.status).to(beNil())
                    }
                }
            }
            describe("decline message") {
                var messageText: String!
                var meeting: AssistantMeeting!
                beforeEach {
                    sut = LGMeetingParser()
                }
                context("invalid string") {
                    beforeEach {
                        messageText = "LOL NOPE"
                        meeting = sut.createMeetingFromMessage(message: messageText)
                    }
                    it("meeting is nil") {
                        expect(meeting).to(beNil())
                    }
                }
                context("valid string") {
                    beforeEach {
                        messageText = "❌ Decline"
                        meeting = sut.createMeetingFromMessage(message: messageText)
                    }
                    it("meeting has type rejected") {
                        expect(meeting.meetingType) == MeetingMessageType.rejected
                    }
                    it("meeting doesn't have location name") {
                        expect(meeting.locationName).to(beNil())
                    }
                    it("meeting doesn't have a date") {
                        expect(meeting.date).to(beNil())
                    }
                    it("meeting doesn't have coordinates") {
                        expect(meeting.coordinates).to(beNil())
                    }
                    it("meeting doesn't have status") {
                        expect(meeting.status).to(beNil())
                    }
                }
            }
            describe("create string from meeting") {
                var messageText: String!
                var meeting: AssistantMeeting!
                beforeEach {
                    sut = LGMeetingParser()
                    dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a ZZZZ"
                }
                context("meeting requested") {
                    beforeEach {
                        let date = dateFormatter.date(from: "03/31/2018 04:34 AM GMT")
                        meeting = AssistantMeeting(meetingType: .requested,
                                                   date: date,
                                                   locationName: "Pasa Tapas, Barcelona",
                                                   coordinates: LGLocationCoordinates2D(latitude: 37.42, longitude: -122.08),
                                                   status: .pending)
                        messageText = sut.textForMeeting(meeting: meeting)
                    }
                    it ("Meeting is converted to text") {
                        expect(messageText) == "🗓 Let's meet at:\n\n📍 Pasa Tapas, Barcelona (37.42° N, -122.08° E)\n🕐 03/31/2018 06:34 AM GMT+02:00"
                    }
                }
            }
        }
    }
}
