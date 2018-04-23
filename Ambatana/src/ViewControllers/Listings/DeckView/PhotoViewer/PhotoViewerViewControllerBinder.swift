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

    func dismissView()
    func showChat()
    func updatePage(fromContentOffset offset: CGFloat)
}

protocol PhotoViewerBinderViewType: class {
    var rxCollectionView: Reactive<UICollectionView> { get }
    var rxTapControlEvents: Observable<UIControlEvents> { get }
}

final class PhotoViewerViewControllerBinder {

    weak var viewController: PhotoViewerVCType?
    private var disposeBag: DisposeBag?

    func bind(toView: PhotoViewerBinderViewType) {
        disposeBag = DisposeBag()

        guard let bag = disposeBag else { return }
        guard let vc = viewController else { return }

        bindContentOffset(toViewController: vc, view: toView, withDisposeBag: bag)
        bindKeyboard(toViewController: vc, view: toView, withDisposeBag: bag)
        bindTapControlEvents(toViewController: vc, view: toView, withDisposeBag: bag)
    }

    private func bindContentOffset(toViewController viewController: PhotoViewerVCType?,
                                   view: PhotoViewerBinderViewType,
                                   withDisposeBag disposeBag: DisposeBag) {
        view.rxCollectionView.contentOffset.asObservable().bind { [weak viewController] offset in
            viewController?.updatePage(fromContentOffset: offset.x)
        }.disposed(by:disposeBag)
    }

    private func bindKeyboard(toViewController viewController: PhotoViewerVCType?,
                              view: PhotoViewerBinderViewType,
                              withDisposeBag disposeBag: DisposeBag) {
        viewController?.keyboardChanges.bind { [weak viewController] in
            viewController?.updateWith(keyboardChange: $0)
        }.disposed(by:disposeBag)
    }

    private func bindTapControlEvents(toViewController viewController: PhotoViewerVCType?,
                                      view: PhotoViewerBinderViewType,
                                      withDisposeBag disposeBag: DisposeBag) {
        view.rxTapControlEvents
            .filter { $0 == .touchUpInside }
            .bind { [weak viewController] event in
            viewController?.dismissView()
        }.disposed(by: disposeBag)
    }
}
