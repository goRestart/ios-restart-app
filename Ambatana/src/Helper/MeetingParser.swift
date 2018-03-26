//
//  MeetingParser.swift
//  LetGo
//
//  Created by Dídac on 21/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit


final class MeetingParser {

//    ✅ OK -> Accepted meeting
//    ❌ Can't do -> Rejected meeting

//    🗓 Would you like to meet?
//
//    📍 Plaza Catalunya 13 (2.2345º N -21.9999º W)
//    🕐 02/09/2018 06:30 GMT+01

    static let sharedInstance: MeetingParser = MeetingParser()

    private let dateFormatter: DateFormatter

    private let acceptanceMark = "✅"
    private let rejectionMark = "❌"
    private let meetingMark = "🗓"
    private let locationMark = "📍"
    private let dateMark = "🕐"

    private var startingChars: [String] {
        return [acceptanceMark, rejectionMark, meetingMark]
    }

    private var meetingIntro: String {
        return meetingMark + " Would you like to meet?"
    }

    convenience init() {
        self.init(dateFormatter: DateFormatter())
    }

    init(dateFormatter: DateFormatter) {
        self.dateFormatter = dateFormatter
    }

    func createMeetingFromMessage(message: String) -> AssistantMeeting? {
        guard let firstElement = message.first else { return nil }
        let firstChar = String(describing: firstElement)
        guard startingChars.contains(firstChar) else { return nil }
        if firstChar == acceptanceMark {
            let meetingAccepted = AssistantMeeting(meetingType: .accepted,
                                                   date: nil,
                                                   locationName: nil,
                                                   coordinates: nil,
                                                   status: nil)
            return meetingAccepted
        } else if firstChar == rejectionMark {
            let meetingRejected = AssistantMeeting(meetingType: .rejected,
                                                   date: nil,
                                                   locationName: nil,
                                                   coordinates: nil,
                                                   status: nil)
            return meetingRejected
        } else if firstChar == meetingMark {
            let locationInfo = stripLocationFrom(string: message)
            let date = stripDateFrom(string: message)
            let meetingRequested = AssistantMeeting(meetingType: .requested,
                                                    date: date,
                                                    locationName: locationInfo.0,
                                                    coordinates: locationInfo.1,
                                                    status: .pending)
            return meetingRequested
        } else {
            return nil
        }
    }

    private func stripLocationFrom(string: String) -> (name: String?, coords: LGLocationCoordinates2D?) {
        let meetingInfo = string.components(separatedBy: locationMark + " ")
        guard meetingInfo.count == 2 else { return (nil, nil) }
        let locationString = meetingInfo[1]
        let locationName = locationString.components(separatedBy: " (")[0]
        let coordinates = stripLocationCoordinatesFrom(locationString: locationString)
        return (locationName, coordinates)
    }

    private func stripLocationCoordinatesFrom(locationString: String) -> LGLocationCoordinates2D? {
        let locationComponents = locationString.components(separatedBy: ["(", ")"])
        guard locationComponents.count > 1 else { return nil }
        let coords = locationComponents[1]
        let coordsComponents = coords.components(separatedBy: "º ")
        guard coordsComponents.count > 2 else { return nil }
        let latitude = coordsComponents[0]

        let longitude = coordsComponents[1].stringByReplacingFirstOccurrence(of: "N ", with: "")

        let doubleLat = Double(latitude.prefix(7)) ?? 0.0
        let doubleLon = Double(longitude.prefix(7)) ?? 0.0

        let locCoords = LGLocationCoordinates2D(latitude: doubleLat, longitude: doubleLon)

        return locCoords
    }

    private func stripDateFrom(string: String) -> Date? {
        let meetingInfo = string.components(separatedBy: dateMark + " ")
        guard meetingInfo.count == 2 else { return nil }
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a ZZZZ"
        dateFormatter.timeZone = TimeZone.current
        let date = dateFormatter.date(from: meetingInfo[1])
        return date
    }


    func textForMeeting(meeting: AssistantMeeting) -> String {
        switch meeting.meetingType {
        case .accepted:
            return "✅ OK"
        case .rejected:
            return "❌ Can't do"
        case .requested:
            let meetingDateString = stringFrom(meetingDate: meeting.date) ?? ""
            let meetingLocationName = meeting.locationName ?? ""
            var coordinatesString = ""
            if let meetingLocationCoordinates = stringFrom(coordinates: meeting.coordinates) {
                coordinatesString = " (\(meetingLocationCoordinates))"
            }
            return meetingIntro + "\n\n" + "📍 " + meetingLocationName + " " + coordinatesString + "\n" + "🕐 \(meetingDateString)"
        }
    }

    private func stringFrom(coordinates: LGLocationCoordinates2D?) -> String? {
        guard let coords = coordinates else { return nil }
        return "\(coords.latitude)º N \(coords.longitude)º E"
    }

    func stringFrom(meetingDate: Date?) -> String? {
        guard let date = meetingDate else { return nil }
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a ZZZZ"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date)
    }
}
