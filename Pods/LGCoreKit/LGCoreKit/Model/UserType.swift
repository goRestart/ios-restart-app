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
}

extension UserType: Decodable {}
