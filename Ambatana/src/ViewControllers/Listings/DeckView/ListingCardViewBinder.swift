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

    func bind(withViewModel viewModel: ListingCardViewCellModel) {
        viewModelBag = DisposeBag()
        guard let vmDisposeBag = viewModelBag else { return }

        viewModel.productIsFavorite.bindNext { [weak self] favorite in
            if viewModel.cardIsFavoritable {
                self?.cardView?.userView.set(action: .favourite(isOn: favorite))
            } else {
                self?.cardView?.userView.set(action: .edit)
            }
        }.addDisposableTo(vmDisposeBag)

        viewModel.cardUserInfo.bindNext { [weak self] userInfo in
            self?.cardView?.populateWith(userInfo: userInfo)
        }.addDisposableTo(vmDisposeBag)

        viewModel.cardProductImageURLs.bindNext { [weak self] urls in
            self?.cardView?.populateWith(imagesURLs: urls)
        }.addDisposableTo(vmDisposeBag)

        let statusAndFeatured = Observable.combineLatest(viewModel.cardStatus,
                                                         viewModel.cardIsFeatured) { $0 }
        statusAndFeatured.bindNext { [weak self] (status, isFeatured) in
            self?.cardView?.populateWith(status: status, featured: isFeatured)
        }.addDisposableTo(vmDisposeBag)
    }
}
