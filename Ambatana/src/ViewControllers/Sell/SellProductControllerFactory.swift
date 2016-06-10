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
    func sellProductViewController(sellVC: SellProductViewController?, didCompleteSell successfully: Bool,
        withPromoteProductViewModel promoteProductVM: PromoteProductViewModel?)
    func sellProductViewController(sellVC: SellProductViewController?, didFinishPostingProduct
        postedViewModel: ProductPostedViewModel)
    func sellProductViewControllerDidTapPostAgain(sellVC: SellProductViewController?)
    func sellProductViewController(sellVC: SellProductViewController?,
        didEditProduct editVC: EditProductViewController?)
}

class SellProductControllerFactory {

    static func presentSellProductOn(viewController viewController: UIViewController,
        delegate: SellProductViewControllerDelegate? = nil) {
            SellProductControllerFactory.presentSellOn(viewController: viewController, delegate: delegate)
    }

    private static func presentSellOn(viewController viewController: UIViewController,
        delegate: SellProductViewControllerDelegate? = nil) {
            let vc = PostProductViewController()
            vc.delegate = delegate
            viewController.presentViewController(vc, animated: true, completion: nil)
    }
}
