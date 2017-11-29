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
    private let disposeBag = DisposeBag()
    private var vmDisposeBag = DisposeBag()

    private let page = Variable<Int>(0)
    private let isFavorite = Variable<Bool>(false)

    func bind() {
        guard let card = cardView else { return }

        page.asObservable().bindNext { [unowned card] page in
            card.update(currentPage: page)
        }.addDisposableTo(disposeBag)

        isFavorite.asObservable().bindNext { [weak self] isFav in
            self?.cardView?.userView.set(action: .favourite(isOn: isFav))
        }.addDisposableTo(disposeBag)
    }

    func bind(withViewModel viewModel: ListingViewModel) {
        vmDisposeBag = DisposeBag()
        viewModel.isFavorite.asObservable()
            .filter { _ in return viewModel.isFavoritable }.bindTo(isFavorite).addDisposableTo(vmDisposeBag)
    }

    func update(scrollViewBindings scrollView: UIScrollView) {
        let base = scrollView.width / 2.0
        let offset = base + scrollView.contentOffset.x
        page.value = Int(offset / scrollView.width) + 1
    }
    
}
