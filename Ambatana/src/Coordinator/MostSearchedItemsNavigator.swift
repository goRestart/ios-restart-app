//
//  MostSearchedItemsNavigator.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 18/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

protocol MostSearchedItemsNavigator: class {
    func cancel()
    func openSell(mostSearchedItem: LocalMostSearchedItem)
}

