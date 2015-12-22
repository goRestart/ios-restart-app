//
//  SellProductControllerFactory.swift
//  LetGo
//
//  Created by Eli Kohen on 11/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

public protocol SellProductViewController: class {
    func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?)
}

protocol SellProductViewControllerDelegate : class {
    func sellProductViewController(sellVC: SellProductViewController?, didCompleteSell successfully: Bool)
    func sellProductViewController(sellVC: SellProductViewController?, didFinishPostingProduct
        postedViewModel: ProductPostedViewModel)
    func sellProductViewControllerDidTapPostAgain(sellVC: SellProductViewController?)
    func sellProductViewController(sellVC: SellProductViewController?,
        didEditProduct editVC: EditSellProductViewController?)
}

class SellProductControllerFactory {

    static func presentSellProductOn(viewController viewController: UIViewController,
        delegate: SellProductViewControllerDelegate? = nil) {

            if ABTests.loginAfterSell.boolValue && !ABTests.newPostingProcess.boolValue {
                // Old posting with 'loginAfterSell' will ask for login before saving the product
                SellProductControllerFactory.presentSellOn(viewController: viewController, delegate: delegate)
            } else {
                // New posting and old posting without 'loginAfterSell' require login before launching the postingVC
                viewController.ifLoggedInThen(.Sell,
                    loggedInAction: {
                        SellProductControllerFactory.presentSellOn(viewController: viewController, delegate: delegate)
                    },
                    elsePresentSignUpWithSuccessAction: {
                        SellProductControllerFactory.presentSellOn(viewController: viewController, delegate: delegate)
                    }
                )
            }
    }

    private static func presentSellOn(viewController viewController: UIViewController,
        delegate: SellProductViewControllerDelegate? = nil) {
            if ABTests.newPostingProcess.boolValue {
                let vc = PostProductViewController()
                vc.delegate = delegate
                viewController.presentViewController(vc, animated: true, completion: nil)
            } else {
                let vc = NewSellProductViewController()
                vc.completedSellDelegate = delegate
                let navCtl = UINavigationController(rootViewController: vc)
                viewController.presentViewController(navCtl, animated: true, completion: nil)
            }
    }
}
