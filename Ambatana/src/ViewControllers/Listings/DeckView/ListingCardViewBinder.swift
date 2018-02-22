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

        if viewModel.cardIsFavoritable {
            viewModel.productIsFavorite.bind { [weak self] favorite in
                self?.cardView?.userView.set(action: .favourite(isOn: favorite))
            }.disposed(by:vmDisposeBag)
        } else {
            cardView?.userView.set(action: .edit)
        }

        viewModel.cardUserInfo.bind { [weak self] userInfo in
            self?.cardView?.populateWith(userInfo: userInfo)
        }.disposed(by:vmDisposeBag)

        viewModel.cardProductImageURLs.bind { [weak self] urls in
            self?.cardView?.populateWith(imagesURLs: urls)
        }.disposed(by:vmDisposeBag)

        let statusAndFeatured = Observable.combineLatest(viewModel.cardStatus,
                                                         viewModel.cardIsFeatured) { ($0, $1) }
        statusAndFeatured.bind { [weak self] (status, isFeatured) in
            self?.cardView?.populateWith(status: status, featured: isFeatured)
        }.disposed(by:vmDisposeBag)
    }
}
