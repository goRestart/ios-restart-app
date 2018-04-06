//
//  UserVerificationItem.swift
//  LetGo
//
//  Created by Isaac Roldan on 19/3/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

enum UserVerificationItem {
    case facebook(completed: Bool)
    case google(completed: Bool)
    case email(completed: Bool)
    case phoneNumber(completed: Bool)
    case photoID(completed: Bool)
    case profilePicture(completed: Bool)
    case bio(completed: Bool)
    case markAsSold(completed: Bool)

    var title: String {
        switch self {
        case .facebook: return "Facebook"
        case .google: return "Google"
        case .email: return "Email"
        case .phoneNumber: return "Phone number"
        case .photoID: return "Photo ID"
        case .profilePicture: return "Profile Picture"
        case .bio: return "Bio"
        case .markAsSold: return "Mark a listing as sold"
        }
    }

    var subtitle: String? {
        switch self {
        case .markAsSold: return "+2pts each (up to 10 pts)"
        default: return nil
        }
    }

    var image: UIImage? {
        switch self {
        case .facebook: return UIImage(named: "verify_facebook")
        case .google: return UIImage(named: "verify_google")
        case .email: return UIImage(named: "verify_mail")
        case .phoneNumber: return UIImage(named: "verify_phone")
        case .photoID: return UIImage(named: "verify_id")
        case .profilePicture: return UIImage(named: "verify_photo")
        case .bio: return UIImage(named: "verify_bio")
        case .markAsSold: return UIImage(named: "verify_sold")
        }
    }

    var pointsValue: String {
        switch self {
        case .facebook: return "+25"
        case .google: return "+10"
        case .email: return "+5"
        case .phoneNumber: return "+15"
        case .photoID: return "+40"
        case .profilePicture: return "+10"
        case .bio: return "+5"
        case .markAsSold: return "+2"
        }
    }

    var showsAccessoryView: Bool {
        switch self {
        case .facebook, .google, .email, .phoneNumber, .photoID, .profilePicture, .bio: return true
        case .markAsSold: return false
        }
    }

    var completed: Bool {
        switch self {
        case .facebook(let completed): return completed
        case .google(let completed): return completed
        case .email(let completed): return completed
        case .phoneNumber(let completed): return completed
        case .photoID(let completed): return completed
        case .profilePicture(let completed): return completed
        case .bio(let completed): return completed
        case .markAsSold(let completed): return completed
        }
    }

    var canBeSelected: Bool {
        return !completed && showsAccessoryView
    }
}
