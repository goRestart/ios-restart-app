//
//  SellProductControllerFactory.swift
//  LetGo
//
//  Created by Eli Kohen on 11/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

protocol SellProductViewControllerDelegate : class {
    func sellProductViewController(sellVC: UIViewController?, didCompleteSell successfully: Bool)
}

class SellProductControllerFactory {

    static func presentSellProductOn(viewController viewController: UIViewController,
        delegate: SellProductViewControllerDelegate? = nil) {


        
    }

}
