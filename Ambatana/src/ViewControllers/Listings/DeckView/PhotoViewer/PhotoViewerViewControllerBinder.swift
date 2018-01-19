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
    var keyboardChanges: Observable<KeyboardChange> { get }
    func updateWith(keyboardChange: KeyboardChange)
    
    func showChat()
    func updatePage(fromContentOffset offset: CGFloat)
}

protocol PhotoViewerBinderViewType: class {
    var rxChatButton: Reactive<UIControl>? { get }
    var rxCollectionView: Reactive<UICollectionView> { get }
}

final class PhotoViewerViewControllerBinder {

    weak var viewController: PhotoViewerVCType?
    private var disposeBag: DisposeBag?

    func bind(toView: PhotoViewerBinderViewType) {
        disposeBag = DisposeBag()

        guard let bag = disposeBag else { return }
        guard let vc = viewController else { return }

        bindChatButton(toViewController: vc, view: toView, withDisposeBag: bag)
        bindContentOffset(toViewController: vc, view: toView, withDisposeBag: bag)
        bindKeyboard(toViewController: vc, view: toView, withDisposeBag: bag)
    }

    private func bindChatButton(toViewController viewController: PhotoViewerVCType,
                        view: PhotoViewerBinderViewType, withDisposeBag disposeBag: DisposeBag) {
        view.rxChatButton?.controlEvent(.touchUpInside)
            .debounce(0.3, scheduler: MainScheduler.instance)
            .bind { [weak viewController] in
            viewController?.showChat()
        }.disposed(by:disposeBag)
    }

    private func bindContentOffset(toViewController viewController: PhotoViewerVCType?,
                                   view: PhotoViewerBinderViewType, withDisposeBag disposeBag: DisposeBag) {
        view.rxCollectionView.contentOffset.asObservable().bind { [weak viewController] offset in
            viewController?.updatePage(fromContentOffset: offset.x)
        }.disposed(by:disposeBag)
    }

    private func bindKeyboard(toViewController viewController: PhotoViewerVCType?,
                              view: PhotoViewerBinderViewType, withDisposeBag disposeBag: DisposeBag) {
        viewController?.keyboardChanges.bind {
            viewController?.updateWith(keyboardChange: $0)
        }.disposed(by:disposeBag)
    }
}
