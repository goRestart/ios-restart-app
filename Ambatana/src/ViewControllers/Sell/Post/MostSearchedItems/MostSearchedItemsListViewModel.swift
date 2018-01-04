//
//  MostSearchedItemsListViewModel.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 03/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

class MostSearchedItemsListViewModel: BaseViewModel {
    
    weak var navigator: PostListingNavigator?
    
    init(var1: String, var2: String) {
        super.init()
    }
    
    convenience init(var1: String) {
        self.init(var1: var1, var2: "var2")
    }
}
