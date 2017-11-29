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
    private var disposeBag = DisposeBag()
    private var vmDisposeBag = DisposeBag()

    private let page = Variable<Int>(0)
    private let isFavoritable = Variable<Bool>(false)

    func bind() {
        disposeBag = DisposeBag()
        guard let card = cardView else { return }

        page.asObservable().bindNext { [unowned card] page in
            card.update(currentPage: page)
        }.addDisposableTo(disposeBag)
    }

    func bind(withViewModel viewModel: ListingCardViewCellModel) {
        vmDisposeBag = DisposeBag()

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

    func update(scrollViewBindings scrollView: UIScrollView) {
        let base = scrollView.width / 2.0
        let offset = base + scrollView.contentOffset.x
        page.value = Int(offset / scrollView.width) + 1
    }
    
}
