//
//  AssistantMeeting.swift
//  LetGo
//
//  Created by Dídac on 26/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit


struct AssistantMeeting {

    let meetingType: MeetingMessageType
    let date: Date?
    let locationName: String?
    let coordinates: LGLocationCoordinates2D?
    let status: MeetingStatus?

    func updating(status: MeetingStatus?) -> AssistantMeeting {
        return AssistantMeeting(meetingType: meetingType,
                                date: date,
                                locationName: locationName,
                                coordinates: coordinates,
                                status: status)
    }
}
