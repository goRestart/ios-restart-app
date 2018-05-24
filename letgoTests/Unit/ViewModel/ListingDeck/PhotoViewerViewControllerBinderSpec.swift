//
//  PhotoViewerViewControllerBinderSpec.swift
//  LetGo
//
//  Created by Facundo Menzella on 29/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import RxTest
import RxSwift
import LGCoreKit
import Quick
import Nimble

final class PhotoViewerViewControllerBinderSpec: QuickSpec {

    override func spec() {
        var sut: PhotoViewerViewControllerBinder!
        var photoViewerVC: MockPhotoViewerViewController!
        var photoView: MockPhotoViewerView!

        describe("PhotoViewerViewControllerBinderSpec") {
            beforeEach {
                photoViewerVC = MockPhotoViewerViewController()
                photoView = MockPhotoViewerView()

                sut = PhotoViewerViewControllerBinder()
                sut.viewController = photoViewerVC
                sut.bind(toView: photoView)
            }

            afterEach {
                photoViewerVC.showChatCalled = 0
                photoViewerVC.updatePageCalled = 0
            }

            context("no event is sent") {
                it("showChat is called") {
                    expect(photoViewerVC.showChatCalled).toEventually(equal(0))
                }
                it("updatePage is not called after setup") {
                    expect(photoViewerVC.updatePageCalled).toEventually(equal(1))
                }
            }

            context("user scrolls the photos") {
                beforeEach {
                    photoView.collectionView.setContentOffset(CGPoint(x: 200, y: 0), animated: false)
                }
                it("updatePage is called one more time after setup") {
                    expect(photoViewerVC.updatePageCalled).toEventually(equal(2))
                }
                it("showChat is called only once") {
                    expect(photoViewerVC.showChatCalled).toEventually(equal(0))
                }
            }

            context("user taps in photoviewer") {
                beforeEach {
                    photoView.tapControlEvents.value = .touchUpInside
                }
                it("dismiss is called only once") {
                    expect(photoViewerVC.dismissIsCalled).toEventually(equal(1))
                }
            }

            context("keyboard event is sent") {
                it("showChat is called only once") {
                    expect(photoViewerVC.keyboardIsCalled).toEventually(equal(1))
                }
            }

            context("we dealloc the viewcontroller") {
                beforeEach {
                    photoViewerVC = MockPhotoViewerViewController()
                }
            }
        }
    }
}

private class MockPhotoViewerView: PhotoViewerBinderViewType {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let tapControlEvents: Variable<UIControlEvents?> = Variable<UIControlEvents?>(nil)

    var rxTapControlEvents: Observable<UIControlEvents> { return tapControlEvents.asObservable().ignoreNil() }
    var rxCollectionView: Reactive<UICollectionView> { return collectionView.rx }
}

private class MockPhotoViewerViewController: PhotoViewerVCType {

    var keyboardChanges: Observable<KeyboardChange> { return keyboardChange.asObservable() }

    var showChatCalled: Int = 0
    var updatePageCalled: Int = 0
    var keyboardIsCalled: Int = 0
    var dismissIsCalled: Int = 0

    private let keyboardChange: Variable<KeyboardChange>

    private let change = KeyboardChange(height: 0,
                                        origin: 0,
                                        animationTime: 0,
                                        animationOptions: .beginFromCurrentState,
                                        visible: true,
                                        isLocal: true)

    init() {
        keyboardChange = Variable<KeyboardChange>(change)
    }

    func updateWith(keyboardChange: KeyboardChange) {
        keyboardIsCalled += 1
    }

    func dismissView() {
        dismissIsCalled += 1
    }

    func showChat() {
        showChatCalled += 1
    }

    func updatePage(fromContentOffset offset: CGFloat) {
        updatePageCalled += 1
    }
}
