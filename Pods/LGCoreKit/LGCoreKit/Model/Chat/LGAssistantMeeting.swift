//
//  LGAssistantMeeting.swift
//  LetGo
//
//  Created by Dídac on 26/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

public enum MeetingStatus: Int {
    case pending = 0
    case accepted = 1
    case rejected = 2

    init(value: Int) {
        switch value {
        case 0:
            self = .pending
        case 1:
            self = .accepted
        case 2:
            self = .rejected
        default:
            self = .pending
        }
    }
}

public enum MeetingMessageType: String {
    case requested = "meeting_requested"
    case accepted = "meeting_accepted"
    case rejected = "meeting_rejected"

    var status: MeetingStatus {
        switch self {
        case .requested:
            return .pending
        case .accepted:
            return .accepted
        case .rejected:
            return .rejected
        }
    }
}

public protocol AssistantMeeting {
    var meetingType: MeetingMessageType { get }
    var date: Date? { get }
    var locationName: String? { get }
    var coordinates: LGLocationCoordinates2D? { get }
    var status: MeetingStatus? { get }

    static func makeMeeting(from message: String?) -> AssistantMeeting?
    var textForMeeting: String { get }
}


public struct LGAssistantMeeting: AssistantMeeting {
    public let meetingType: MeetingMessageType
    public let date: Date?
    public let locationName: String?
    public let coordinates: LGLocationCoordinates2D?
    public let status: MeetingStatus?

    public init(meetingType: MeetingMessageType,
         date: Date?,
         locationName: String?,
         coordinates: LGLocationCoordinates2D?,
         status: MeetingStatus?) {
        self.meetingType = meetingType
        self.date = date
        self.locationName = locationName
        self.coordinates = coordinates
        self.status = status
    }

    public static func makeMeeting(from message: String?) -> AssistantMeeting? {
        guard let message = message else { return nil }
        return createMeetingFromMessage(message: message)
    }

    public var textForMeeting: String {
        switch meetingType {
        case .accepted:
            return "✅ OK"
        case .rejected:
            return "❌ Decline"
        case .requested:
            let meetingDateString = LGAssistantMeeting.stringFrom(meetingDate: date) ?? ""
            let meetingLocationName = locationName ?? ""
            var coordinatesString = ""
            if let meetingLocationCoordinates = stringFrom(coordinates: coordinates) {
                coordinatesString = "(\(meetingLocationCoordinates))"
            }
            return LGAssistantMeeting.meetingIntro + "\n\n" + "📍 " + meetingLocationName + " " + coordinatesString + "\n" + "🕐 \(meetingDateString)"
        }
    }


    // MARK: Parser

    static private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a ZZZZ"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        return dateFormatter
    }()

    static private let degreeCharacter = "°"
    static private let acceptanceMark = "✅"
    static private let rejectionMark = "❌"
    static private let meetingMark = "🗓"
    static private let locationMark = "📍"
    static private let dateMark = "🕐"

    static private var startingChars: [String] {
        return [acceptanceMark, rejectionMark, meetingMark]
    }

    static private var meetingIntro: String {
        return meetingMark + " Let's meet at:"
    }

    static private func createMeetingFromMessage(message: String) -> AssistantMeeting? {
        guard let firstElement = message.first else { return nil }
        let firstChar = String(describing: firstElement)
        guard startingChars.contains(firstChar) else { return nil }
        switch firstChar {
        case acceptanceMark:
            let meetingAccepted = LGAssistantMeeting(meetingType: .accepted,
                                                     date: nil,
                                                     locationName: nil,
                                                     coordinates: nil,
                                                     status: nil)
            return meetingAccepted
        case rejectionMark:
            let meetingRejected = LGAssistantMeeting(meetingType: .rejected,
                                                     date: nil,
                                                     locationName: nil,
                                                     coordinates: nil,
                                                     status: nil)
            return meetingRejected
        case meetingMark:
            let locationSubstring = message.slice(from: locationMark, to: dateMark)

            let locationInfo = stripLocationFrom(string: locationSubstring)

            var date: Date? = nil
            if let dateRange = message.range(of: dateMark)?.lowerBound {
                let dateSubstring = message[dateRange..<message.endIndex]
                date = stripDateFrom(string: String(dateSubstring))
            }

            let meetingRequested = LGAssistantMeeting(meetingType: .requested,
                                                      date: date,
                                                      locationName: locationInfo.0,
                                                      coordinates: locationInfo.1,
                                                      status: .pending)
            return meetingRequested
        default:
            return nil
        }
    }

    static private func stripLocationFrom(string: String?) -> (name: String?, coords: LGLocationCoordinates2D?) {
        guard let string = string else { return (nil, nil) }
        let locationComponents = string.components(separatedBy: "(")
        guard locationComponents.count == 2 else { return (nil, nil) }
        let locationName = locationComponents[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let coordinates = stripLocationCoordinatesFrom(locationString: locationComponents[1])
        return (locationName, coordinates)
    }

    static private func stripLocationCoordinatesFrom(locationString: String) -> LGLocationCoordinates2D? {
        let locationComponents = locationString.components(separatedBy: ["(", ")"])
        guard locationComponents.count > 1 else { return nil }
        let coords = locationComponents[0]
        let coordsComponents = coords.components(separatedBy: "\(degreeCharacter) ")
        guard coordsComponents.count > 2 else { return nil }
        let latitude = coordsComponents[0]

        let longitude = stringByReplacingFirstOccurrence(of: "N, ", with: "", inString: coordsComponents[1])

        guard let doubleLat = Double(latitude.prefix(7)), let doubleLon = Double(longitude.prefix(7)) else { return nil }

        let locCoords = LGLocationCoordinates2D(latitude: doubleLat, longitude: doubleLon)

        return locCoords
    }

    static private func stringByReplacingFirstOccurrence(of findString: String, with: String, options: String.CompareOptions = [], inString: String) -> String {
        guard let rangeOfFoundString = inString.range(of: findString, options: options, range: nil, locale: nil) else { return inString }
        return inString.replacingOccurrences(of: findString, with: with, options: options, range: rangeOfFoundString)
    }

    static private func stripDateFrom(string: String?) -> Date? {
        guard let string = string else { return nil }
        let dateInfo = string.components(separatedBy: dateMark + " ")
        guard dateInfo.count == 2 else { return nil }
        let date = dateFormatter.date(from: dateInfo[1])
        return date
    }

    private func stringFrom(coordinates: LGLocationCoordinates2D?) -> String? {
        guard let coords = coordinates else { return nil }
        return "\(coords.latitude)\(LGAssistantMeeting.degreeCharacter) N, \(coords.longitude)\(LGAssistantMeeting.degreeCharacter) E"
    }

    static private func stringFrom(meetingDate: Date?) -> String? {
        guard let date = meetingDate else { return nil }
        return dateFormatter.string(from: date)
    }
}
