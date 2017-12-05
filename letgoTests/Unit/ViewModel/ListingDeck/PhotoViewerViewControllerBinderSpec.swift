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
                photoViewerVC.closeViewCalled = 0
                photoViewerVC.updatePageCalled = 0
            }

            context("chat event is sent") {
                beforeEach {
                    photoView.chatButton.sendActions(for: .touchUpInside)
                }
                it("showChat is called") {
                    expect(photoViewerVC.showChatCalled).toEventually(equal(1))
                }
                it("closeView is not called") {
                    expect(photoViewerVC.closeViewCalled).toEventually(equal(0))
                }
                it("updatePage is not called after setup") {
                    expect(photoViewerVC.updatePageCalled).toEventually(equal(1))
                }
            }

            context("close event is sent") {
                beforeEach {
                    photoView.closeButton.sendActions(for: .touchUpInside)
                }
                it("showChat is called") {
                    expect(photoViewerVC.showChatCalled).toEventually(equal(0))
                }
                it("closeView is not called") {
                    expect(photoViewerVC.closeViewCalled).toEventually(equal(1))
                }
                it("updatePage is not called after setup") {
                    expect(photoViewerVC.updatePageCalled).toEventually(equal(1))
                }
            }

            context("no event is sent") {
                it("showChat is called") {
                    expect(photoViewerVC.showChatCalled).toEventually(equal(0))
                }
                it("closeView is not called") {
                    expect(photoViewerVC.closeViewCalled).toEventually(equal(0))
                }
                it("updatePage is not called after setup") {
                    expect(photoViewerVC.updatePageCalled).toEventually(equal(1))
                }
            }

            context("chat event is sent twice") {
                beforeEach {
                    photoView.chatButton.sendActions(for: .touchUpInside)
                    photoView.chatButton.sendActions(for: .touchUpInside)
                }

                it("showChat is called only once") {
                    expect(photoViewerVC.showChatCalled).toEventually(equal(1))
                }
                it("closeView is not called") {
                    expect(photoViewerVC.closeViewCalled).toEventually(equal(0))
                }
                it("updatePage is not not called after setup") {
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
                it("closeView is not called") {
                    expect(photoViewerVC.closeViewCalled).toEventually(equal(0))
                }
            }

            context("we dealloc the viewcontroller") {
                beforeEach {
                    photoViewerVC = MockPhotoViewerViewController()
                }
                it("and the binder's viewcontroller reference dies too (so weak)") {
                    expect(sut.viewController).toEventually(beNil())
                }
            }
        }
    }
}

private class MockPhotoViewerView: PhotoViewerBinderViewType {
    let chatButton = UIButton()
    let closeButton = UIButton()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    var rx_chatButton: Reactive<UIControl>? { return (chatButton as UIControl).rx }
    var rx_closeButton: Reactive<UIControl>? { return (closeButton as UIControl).rx }
    var rx_collectionView: Reactive<UICollectionView> { return collectionView.rx }
}

private class MockPhotoViewerViewController: PhotoViewerVCType {

    var showChatCalled: Int = 0
    var closeViewCalled: Int = 0
    var updatePageCalled: Int = 0

    func showChat() {
        showChatCalled = showChatCalled + 1
    }

    func closeView() {
        closeViewCalled = closeViewCalled + 1
    }

    func updatePage(fromContentOffset offset: CGFloat) {
        updatePageCalled = updatePageCalled + 1
    }
}
