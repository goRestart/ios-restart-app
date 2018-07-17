//
//  ListingCardViewBinder.swift
//  LetGo
//
//  Created by Facundo Menzella on 06/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

final class ListingCardViewBinder {

    weak var cardView: ListingCardView?
    private var viewModelBag: DisposeBag?

    func recycleDisposeBag() {
        viewModelBag = DisposeBag()
    }

    func bind(withViewModel viewModel: ListingCardViewCellModel) {
        recycleDisposeBag()
        guard let vmDisposeBag = viewModelBag else { return }

        let statusAndFeatured = Observable.combineLatest(viewModel.cardStatus,
                                                         viewModel.cardIsFeatured) { ($0, $1) }
        statusAndFeatured.observeOn(MainScheduler.asyncInstance).bind { [weak self] (status, isFeatured) in
            self?.cardView?.populateWith(status: status, featured: isFeatured)
        }.disposed(by: vmDisposeBag)
    }
}
