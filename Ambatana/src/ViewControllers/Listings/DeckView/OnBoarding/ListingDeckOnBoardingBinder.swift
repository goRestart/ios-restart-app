//
//  ListingDeckOnBoardingBinder.swift
//  LetGo
//
//  Created by Facundo Menzella on 24/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import RxSwift

final class ListingDeckOnBoardingBinder {

    weak var viewController: ListingDeckOnBoardingViewControllerType?
    private var disposeBag: DisposeBag?

    func bind(withView view: ListingDeckOnBoardingViewRxType) {
        let bag = DisposeBag()
        bindTap(withView: view, disposeBag: bag)
        disposeBag = bag
    }

    func bindTap(withView view: ListingDeckOnBoardingViewRxType, disposeBag: DisposeBag) {
        view.rxConfirmButton.tap.bind { [weak viewController] in
            viewController?.close()
        }.disposed(by: disposeBag)
    }

}
