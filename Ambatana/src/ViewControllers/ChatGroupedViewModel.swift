//
//  ChatGroupedViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 27/01/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

// TODO: Strings!
class ChatGroupedViewModel: BaseViewModel {

    var chatsTypeCount: Int {
        return 3
    }

    func chatListViewModelForTabAtIndex(index: Int) -> ChatListViewModel {
        let chatsType = chatsTypeAtIndex(index)
        return ChatListViewModel(chatsType: chatsType)
    }

    func titleForTabAtIndex(index: Int, selected: Bool) -> NSAttributedString {
        let color: UIColor = selected ? StyleHelper.primaryColor : UIColor.blackColor()

        var titleAttributes = [String : AnyObject]()
        titleAttributes[NSForegroundColorAttributeName] = color

        let string = NSMutableAttributedString()
        switch index % 3 {
        case 0:
            string.appendAttributedString(NSAttributedString(string: "BUYING", attributes: titleAttributes))
        case 1:
            string.appendAttributedString(NSAttributedString(string: "SELLING", attributes: titleAttributes))
        case 2:
            string.appendAttributedString(NSAttributedString(string: "ARCHIVED", attributes: titleAttributes))
        default:
            break
        }
        return string
    }

    private func chatsTypeAtIndex(index: Int) -> ChatsType {
        guard index >= 0 && index < chatsTypeCount else { return .All }
        switch index {
        case 0:
            return .Selling
        case 1:
            return .Buying
        case 2:
            return .Archived
        default:
            return .All
        }
    }
}