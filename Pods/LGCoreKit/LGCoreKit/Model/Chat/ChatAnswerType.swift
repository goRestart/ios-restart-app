//
//  ChatAnswerType.swift
//  LGCoreKit
//
//  Created by Nestor on 18/04/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

public enum ChatAnswerType: Equatable {
    case replyText(textToShow: String, textToReply: String)
    case callToAction(textToShow: String, textToReply: String, deeplinkURL: URL)
    
    // MARK: Equatable
    
    static public func == (lhs: ChatAnswerType, rhs: ChatAnswerType) -> Bool {
        switch lhs {
        case .replyText(let lhsTextToShow, let lhsTextToReply):
            if case .replyText(let rhsTextToShow, let rhsTextToReply) = rhs {
                return lhsTextToShow == rhsTextToShow && lhsTextToReply == rhsTextToReply
            }
        case .callToAction(let lhsTextToShow, let lhsTextToReply, let lhsDeeplinkURL):
            if case .callToAction(let rhsTextToShow, let rhsTextToReply, let rhsDeeplinkURL) = rhs {
                return lhsTextToShow == rhsTextToShow && lhsTextToReply == rhsTextToReply && lhsDeeplinkURL == rhsDeeplinkURL
            }
        }
        return false
    }
}

