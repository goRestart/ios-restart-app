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
    case canceled = 3

    init(value: Int) {
        switch value {
        case 0:
            self = .pending
        case 1:
            self = .accepted
        case 2:
            self = .rejected
        case 3:
            self = .canceled
        default:
            self = .pending
        }
    }
}

public enum MeetingMessageType: String {
    case requested = "meeting_requested"
    case accepted = "meeting_accepted"
    case rejected = "meeting_rejected"
    case canceled = "meeting_canceled"

    var status: MeetingStatus {
        switch self {
        case .requested:
            return .pending
        case .accepted:
            return .accepted
        case .rejected:
            return .rejected
        case .canceled:
            return .canceled
        }
    }
}

struct AssistantMeeting {

    var meetingType: MeetingMessageType
    var date: Date?
    var locationName: String?
    var locationId: String?
    var location: LGLocationCoordinates2D?
    var status: MeetingStatus?
    var meetingId: String? // only for acceptance messages
    var buyerId: String? // only for acceptance messages
    var sellerId: String? // only for acceptance messages

    mutating func updateStatus(newStatus: MeetingStatus?) {
        self.status = newStatus
    }
}

class MeetingParser {

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
}
