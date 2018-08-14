//
//  LGChatQuestion.swift
//  LGCoreKit
//
//  Created by Nestor on 02/05/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

public protocol ChatQuestion {
    var key: String? { get }
    var text: String { get }
}

struct LGChatQuestion: ChatQuestion, Equatable {
    
    let key: String?
    let text: String
    
    // MARK: Equatable
    
    static func ==(lhs: LGChatQuestion, rhs: LGChatQuestion) -> Bool {
        return lhs.key == rhs.key && lhs.text == rhs.text
    }
}

