//
//  LGUserUserRelation.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 10/02/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

struct LGUserUserRelation: UserUserRelation {
    var isBlocked: Bool
    var isBlockedBy: Bool

    private init(isBlocked: Bool, isBlockedBy: Bool) {
        self.isBlocked = isBlocked
        self.isBlockedBy = isBlockedBy
    }

    private init?(from json: [String: Any]) {
        guard let isBlocked = json[Keys.isBlocked] as? Bool, let  isBlockedBy = json[Keys.isBlockedBy] as? Bool else {
            return nil
        }
        self.isBlocked = isBlocked
        self.isBlockedBy = isBlockedBy
    }

    static func decodeFrom(jsonData: Data) -> LGUserUserRelation {
        let relation = LGUserUserRelation(isBlocked: false, isBlockedBy: false)
        if let jsonArray = try? JSONSerialization.jsonObject(with: jsonData,
                                                             options: .allowFragments) as? [[String: Any]],
            let json = jsonArray {
            return LGUserUserRelation.decodeFrom(jsonArray: json)
        } else if let decodedJson = try? JSONSerialization.jsonObject(with: jsonData,
                                                                      options: .allowFragments) as? [String: Any],
            let json = decodedJson,
            let relation = LGUserUserRelation(from: json) {
            return relation
        }
        return relation
    }
    
    static func decodeFrom(jsonArray: [[String: Any]]) -> LGUserUserRelation {
        var userRelation = LGUserUserRelation(isBlocked: false, isBlockedBy: false)
        for json in jsonArray {
            if let relation = LGUserUserRelation(from: json) {
                userRelation.isBlocked = userRelation.isBlocked || relation.isBlocked
                userRelation.isBlockedBy = userRelation.isBlockedBy || relation.isBlockedBy
            } else if let linkName = json[Keys.linkName] as? String {
                userRelation.isBlocked = linkName == Keys.isBlocked
                userRelation.isBlockedBy = linkName == Keys.isBlockedBy
            }
        }
        return userRelation
    }

    struct Keys {
        static let isBlocked = "blocked"
        static let isBlockedBy = "blocked_by"
        static let linkName = "link_name"
    }
}

