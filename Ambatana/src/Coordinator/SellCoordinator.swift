//
//  SellCoordinator.swift
//  LetGo
//
//  Created by Albert Hernández López on 20/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxSwift

final class SellCoordinator: NSObject, Coordinator {
    var child: Coordinator?
    var viewController: UIViewController { return postProductViewController }
    var presentedAlertController: UIAlertController?

    private let postProductViewController: PostProductViewController

    weak var delegate: SellNavigatorDelegate?

    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    init(postProductViewController: PostProductViewController) {
        self.postProductViewController = postProductViewController
    }
}


// MARK: - SellNavigator

extension SellCoordinator: SellNavigator {
    func open() {
    }
}