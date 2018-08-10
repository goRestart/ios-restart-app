//
//  UserType.swift
//  LGCoreKit
//
//  Created by Dídac on 13/12/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public enum UserType: String {
    case pro = "professional"
    case user = "user"
    case dummy = "dummy"
    case unknown = "unknown"
}

extension UserType: Codable {}

extension UserType {
    public var isProfessional: Bool { return self == .pro }
    
    public var isDummy: Bool { return self == .dummy }
    
    public static var all: [UserType] {
        return [.pro, .user, .dummy]
    }
    
    public static var allNonDummyUserTypes: [UserType] {
        return all.filter { !$0.isDummy }
    }
}
