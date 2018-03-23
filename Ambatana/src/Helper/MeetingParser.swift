//
//  MeetingParser.swift
//  LetGo
//
//  Created by Dídac on 21/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

public enum MeetingStatus: Int {
    case pending = 0
    case accepted = 1
    case rejected = 2
//    case canceled = 3

    init(value: Int) {
        switch value {
        case 0:
            self = .pending
        case 1:
            self = .accepted
        case 2:
            self = .rejected
//        case 3:
//            self = .canceled
        default:
            self = .pending
        }
    }
}

public enum MeetingMessageType: String {
    case requested = "meeting_requested"
    case accepted = "meeting_accepted"
    case rejected = "meeting_rejected"
//    case canceled = "meeting_canceled"

    var status: MeetingStatus {
        switch self {
        case .requested:
            return .pending
        case .accepted:
            return .accepted
        case .rejected:
            return .rejected
//        case .canceled:
//            return .canceled
        }
    }
}

struct AssistantMeeting {

    var meetingType: MeetingMessageType
    var date: Date?
    var locationName: String?
    var coordinates: LGLocationCoordinates2D?
    var status: MeetingStatus?

    mutating func updateStatus(newStatus: MeetingStatus?) {
        self.status = newStatus
    }
}

class MeetingParser {

//    ✅ OK -> Accepted meeting
//    ❌ Can't do -> Rejected meeting

//    🗓 Would you like to meet?
//
//    📍 Plaza Catalunya 13 (2.2345º N -21.9999º W)
//    🕐 02/09/2018 06:30 GMT+01

    static let dateFormatter = DateFormatter()

    static let acceptanceMark = "✅"
    static let rejectionMark = "❌"
    static let meetingMark = "🗓"
    static let locationMark = "📍"
    static let dateMark = "🕐"

    static var startingChars: [String] {
        return [acceptanceMark, rejectionMark, meetingMark]
    }

    static var meetingIntro: String {
        return meetingMark + " Would you like to meet?"
    }

    static func createMeetingFromMessage(message: String) -> AssistantMeeting? {
        guard let firstElement = message.first else { return nil }
        let firstChar = String(describing: firstElement)
        guard startingChars.contains(firstChar) else { return nil }
        if firstChar == acceptanceMark {
            let meetingAccepted = AssistantMeeting(meetingType: .accepted, date: nil, locationName: nil, coordinates: nil, status: nil)
            return meetingAccepted
        } else if firstChar == rejectionMark {
            let meetingRejected = AssistantMeeting(meetingType: .rejected, date: nil, locationName: nil, coordinates: nil, status: nil)
            return meetingRejected
        } else if firstChar == meetingMark {
            let locationInfo = stripLocationFrom(string: message)
            let date = stripDateFrom(string: message)
            let meetingRequested = AssistantMeeting(meetingType: .requested, date: date, locationName: locationInfo.0, coordinates: locationInfo.1, status: .pending)
            return meetingRequested
        } else {
            return nil
        }
    }

    static private func stripLocationFrom(string: String) -> (name: String?, coords: LGLocationCoordinates2D?) {
        let meetingInfo = string.components(separatedBy: locationMark + " ")
        guard meetingInfo.count == 2 else { return (nil, nil) }
        let locationString = meetingInfo[1]
        let locationName = locationString.components(separatedBy: " (")[0]
        let coordinates = stripLocationCoordinatesFrom(locationString: locationString)
        return (locationName, coordinates)
    }

    static private func stripLocationCoordinatesFrom(locationString: String) -> LGLocationCoordinates2D? {
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

    static private func stripDateFrom(string: String) -> Date? {
        let meetingInfo = string.components(separatedBy: dateMark + " ")
        guard meetingInfo.count == 2 else { return nil }
        print(meetingInfo[1])
        MeetingParser.dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a ZZZZ"
        MeetingParser.dateFormatter.timeZone = TimeZone.current
        let date = MeetingParser.dateFormatter.date(from: meetingInfo[1])
        return date
    }




    static func textForMeeting(meeting: AssistantMeeting) -> String {

//        var meetingType: MeetingMessageType
//        var date: Date?
//        var locationName: String?
//        var coordinates: LGLocationCoordinates2D?
//        var status: MeetingStatus?

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

    static private func stringFrom(coordinates: LGLocationCoordinates2D?) -> String? {
        guard let coords = coordinates else { return nil }
        return "\(coords.latitude)º N \(coords.longitude)º E"
    }

    static func stringFrom(meetingDate: Date?) -> String? {
        guard let date = meetingDate else { return nil }
        MeetingParser.dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a ZZZZ"
        MeetingParser.dateFormatter.timeZone = TimeZone.current
        return MeetingParser.dateFormatter.string(from: date)
    }

/*
//    {
//      "type": "meeting_created|meeting_accepted|meeting_rejected",
//      "properties": {
//          "location_name": "Barcelona",
//          "location_id": "982374987",
//          "geo": {
//              "lat": "41.390205",
//              "lon": "2.154007"
//          },
//          "date": "1511193820350",
//          "meeting_id": "23213213213",
//          "buyer_id": "329749273",
//          "seller_id": "09670967i"
//      }
//    }

    static let typeKey = "type"
    static let propertiesKey = "properties"
    static let locationNameKey = "location_name"
    static let locationIdKey = "location_id"
    static let geoKey = "geo"
    static let latKey = "lat"
    static let lonKey = "lon"
    static let dateKey = "date"
    static let meetingIdKey = "meeting_id"
    static let buyerIdKey = "buyer_id"
    static let sellerIdKey = "seller_id"

    static func createMeetingFromMessage(message: String) -> AssistantMeeting? {
        let data = message.data(using: .utf8)
        var theJson: Any?
        do {
            theJson = try JSONSerialization.jsonObject(with: data!)
        } catch {
            print(error)
        }
        guard let json = theJson as? [String: Any] else { return nil }

        let type = json[MeetingParser.typeKey] as? String ?? MeetingMessageType.requested.rawValue
        let properties = json[MeetingParser.propertiesKey] as? [String: Any] ?? [:]

        let locationName = properties[MeetingParser.locationNameKey] as? String
        let locationId = properties[MeetingParser.locationIdKey] as? String
        let coords = properties[MeetingParser.geoKey] as? [String: Any] ?? [:]
        let lat = coords[MeetingParser.latKey] as? String ?? "0.0"
        let lon = coords[MeetingParser.lonKey] as? String ?? "0.0"
        let timeInterval = properties[MeetingParser.dateKey] as? TimeInterval


        let meetingId = properties[MeetingParser.meetingIdKey] as? String

        let buyerId = properties[MeetingParser.buyerIdKey] as? String
        let sellerId = properties[MeetingParser.sellerIdKey] as? String


        var date: Date? = nil
        if let timeInterval = timeInterval {
            let fixedTimeInterval = timeInterval * 0.001
            date = Date(timeIntervalSince1970: fixedTimeInterval)
        }

        let doubleLat = Double(lat) ?? 0.0
        let doubleLon = Double(lon) ?? 0.0

        let meeting = AssistantMeeting(meetingType: MeetingMessageType(rawValue: type) ?? .requested,
                                       date: date,
                                       locationName: locationName,
                                       locationId: locationId,
                                       location: LGLocationCoordinates2D(latitude: doubleLat,
                                                                         longitude: doubleLon),
                                       status: nil,
                                       meetingId: meetingId,
                                       buyerId: buyerId,
                                       sellerId: sellerId)
        return meeting
    }

    static func textForMeeting(meeting: AssistantMeeting) -> String {

        var data: Data?
        do {
            let meetingDateTimeInterval = (meeting.date ?? Date()).timeIntervalSince1970 * 1000.0

            let meetingInt64: Int64 = Int64(meetingDateTimeInterval)
            
            let stringLat: String = String(describing: meeting.location?.latitude ?? 0.0)
            let stringLon: String = String(describing: meeting.location?.longitude ?? 0.0)

            let geoDict: [String:Any] = [MeetingParser.latKey: stringLat,
                                         MeetingParser.lonKey: stringLon]

            let properties: [String:Any] = [MeetingParser.locationNameKey: meeting.locationName,
                                             MeetingParser.locationIdKey: meeting.locationId,
                                             MeetingParser.geoKey: geoDict,
                                             MeetingParser.dateKey: meetingInt64,
                                             MeetingParser.meetingIdKey: meeting.meetingId,
                                             MeetingParser.buyerIdKey: meeting.buyerId,
                                             MeetingParser.sellerIdKey: meeting.sellerId]

            let meetingDict : [String:Any] = [MeetingParser.typeKey: meeting.meetingType.rawValue,
                                              MeetingParser.propertiesKey: properties]

            data = try JSONSerialization.data(withJSONObject: meetingDict, options: .prettyPrinted)
        } catch {
            print(error)
        }
        if let data = data {
            return String(data: data, encoding: .utf8) ?? ""
        } else {
            return ""
        }
    }
 */
}
