//
//  ExpressChatNavigator.swift
//  LetGo
//
//  Created by Dídac on 11/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation


protocol ExpressChatNavigator: class {
    func closeExpressChat(_ showAgain: Bool, forProduct: String)
    func sentMessage(_ forProduct: String, count: Int, completion: (() -> Void)?)
}
