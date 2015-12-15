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
}

class SellProductControllerFactory {

    static func presentSellProductOn(viewController viewController: UIViewController,
        delegate: SellProductViewControllerDelegate? = nil) {

            // TODO: A/B TEST THIS!
            //Old version
//            let vc = NewSellProductViewController()
//            vc.completedSellDelegate = delegate
//            let navCtl = UINavigationController(rootViewController: vc)
//            viewController.presentViewController(navCtl, animated: true, completion: nil)

            //New version
            let vc = PostProductViewController()
            vc.delegate = delegate
            viewController.presentViewController(vc, animated: true, completion: nil)
    }
}
