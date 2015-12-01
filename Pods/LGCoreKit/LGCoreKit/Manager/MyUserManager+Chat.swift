//
//  MyUserManager+Chat.swift
//  Pods
//
//  Created by Isaac Roldan on 30/11/15.
//
//

import Foundation

extension MyUserManager {
    public func isMessageMine(message: Message) -> Bool {
        return message.userId == myUser()?.objectId
    }
}