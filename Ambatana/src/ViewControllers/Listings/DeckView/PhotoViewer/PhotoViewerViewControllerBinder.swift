//
//  PhotoViewerViewControllerBinder.swift
//  LetGo
//
//  Created by Facundo Menzella on 29/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import RxSwift

protocol PhotoViewerVCType: class {
    func showChat()
    func closeView()
}

protocol PhotoViewerViewType: class {
    var rx_closeButton: Reactive<UIControl>? { get }
    var rx_chatButton: Reactive<UIControl>? { get }
}

final class PhotoViewerViewControllerBinder {

    weak var viewController: PhotoViewerVCType?
    private var disposeBag: DisposeBag?

    func bind(toView: PhotoViewerViewType) {
        disposeBag = DisposeBag()

        guard let bag = disposeBag else { return }
        guard let vc = viewController else { return }

        bindChatButton(toViewController: vc, view: toView, withDisposeBag: bag)
        bindCloseButton(toViewController: vc, view: toView, withDisposeBag: bag)
    }

    func bindChatButton(toViewController viewController: PhotoViewerVCType,
                        view: PhotoViewerViewType, withDisposeBag disposeBag: DisposeBag) {
        view.rx_chatButton?.controlEvent(.touchUpInside)
            .debounce(0.3, scheduler: MainScheduler.instance)
            .bindNext { [weak viewController] in
            viewController?.showChat()
        }.addDisposableTo(disposeBag)
    }

    func bindCloseButton(toViewController viewController: PhotoViewerVCType?,
                        view: PhotoViewerViewType, withDisposeBag disposeBag: DisposeBag) {
        view.rx_closeButton?.controlEvent(.touchUpInside)
            .debounce(0.3, scheduler: MainScheduler.instance)
            .bindNext { [weak viewController] in
            viewController?.closeView()
        }.addDisposableTo(disposeBag)
    }
}
