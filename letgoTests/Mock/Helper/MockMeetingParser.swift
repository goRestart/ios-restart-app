//
//  MockMeetingParser.swift
//  letgoTests
//
//  Created by Dídac on 26/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

@testable import LetGoGodMode

final class MockMeetingParser: MeetingParser {

    var resultAssistantMeeting: AssistantMeeting?
    var resultText: String = ""

    func createMeetingFromMessage(message: String) -> AssistantMeeting? {
        return resultAssistantMeeting
    }

    func textForMeeting(meeting: AssistantMeeting) -> String {
        return resultText
    }
}
