//
//  Tab.swift
//  LetGo
//
//  Created by Eli Kohen on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

/**
 Defines the tabs contained in the TabBarController
 */
enum Tab: Int {
    case Home = 0, Categories = 1, Sell = 2, Chats = 3, Profile = 4

    var tabIconImageName: String {
        switch self {
        case Home:
            return "tabbar_home"
        case Categories:
            return "tabbar_categories"
        case Sell:
            return "tabbar_sell"
        case Chats:
            return "tabbar_chats"
        case Profile:
            return "tabbar_profile"
        }
    }



    static var all:[Tab] {
        return Array( AnySequence { () -> AnyGenerator<Tab> in
            var i = 0
            return AnyGenerator{
                let value = i
                i = i + 1
                return Tab(rawValue: value)
            }
            }
        )
    }
}
