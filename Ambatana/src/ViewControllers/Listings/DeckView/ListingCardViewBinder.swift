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

        if viewModel.cardIsFavoritable {
            viewModel.productIsFavorite.observeOn(MainScheduler.asyncInstance).bind { [weak self] favorite in
                self?.cardView?.userView.set(action: .favourite(isOn: favorite))
            }.disposed(by:vmDisposeBag)
        } else {
            cardView?.userView.set(action: .edit)
        }

        viewModel.cardUserInfo.observeOn(MainScheduler.asyncInstance).bind { [weak self] userInfo in
            self?.cardView?.populateWith(userInfo: userInfo)
        }.disposed(by:vmDisposeBag)

        viewModel.cardProductPreview.observeOn(MainScheduler.asyncInstance).bind { [weak self] (preview, count) in
            self?.cardView?.populateWith(preview: preview, imageCount: count)
        }.disposed(by:vmDisposeBag)

        let statusAndFeatured = Observable.combineLatest(viewModel.cardStatus,
                                                         viewModel.cardIsFeatured) { ($0, $1) }
        statusAndFeatured.observeOn(MainScheduler.asyncInstance).bind { [weak self] (status, isFeatured) in
            self?.cardView?.populateWith(status: status, featured: isFeatured)
        }.disposed(by:vmDisposeBag)
    }
}
