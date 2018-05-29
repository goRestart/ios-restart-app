//
//  ListingDeckViewControllerBinderSpec.swift
//  letgoTests
//
//  Created by Facundo Menzella on 16/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import RxTest
import RxCocoa
import RxSwift
import LGCoreKit
import Quick
import Nimble

final class ListingDeckViewControllerBinderSpec: QuickSpec {

    override func spec() {
        var sut: ListingDeckViewControllerBinder!
        var viewControllerType: MockListingDeckViewControllerBinderType!
        var viewModelType: MockListingDeckViewModelType!
        var viewType: MockListingDeckViewType!
        var cellType: MockListingDeckViewControllerBinderCellType!

        var currentDisposeBag: DisposeBag!

        describe("ListingDeckViewControllerBinder setup") {
            beforeEach {
                sut = ListingDeckViewControllerBinder()
                viewControllerType = MockListingDeckViewControllerBinderType()
                viewType = MockListingDeckViewType()
                viewModelType = MockListingDeckViewModelType()
                cellType = MockListingDeckViewControllerBinderCellType()

                sut.listingDeckViewController = viewControllerType
            }
            afterEach {
                viewControllerType.resetVariables()
                viewModelType.resetVariables()
                viewType.resetVariables()
            }

            context("the cell's usericon button is touched") {
                beforeEach {
                    sut.bind(cell: cellType)
                    cellType.userIcon.sendActions(for: .touchUpInside)
                }
                it("didTapCardAction method is called one time") {
                    expect(viewControllerType.isDidTapUserIconCalled).toEventually(be(1))
                }
            }

            context("the cell's action button is touched after disposing the bag") {
                beforeEach {
                    sut.bind(cell: cellType)
                    cellType.disposeBag = DisposeBag()
                    cellType.userIcon.sendActions(for: .touchUpInside)
                }
                it("didTapCardAction method is not called") {
                    expect(viewControllerType.isDidTapUserIconCalled).toEventually(be(0))
                }
            }

            context("the cell's action button is touched") {
                beforeEach {
                    sut.bind(cell: cellType)
                    cellType.actionButton.sendActions(for: .touchUpInside)
                }
                it("didTapCardAction method is called one time") {
                    expect(viewControllerType.isDidTapCardActionCalled).toEventually(be(1))
                }
            }

            context("the cell's action button is touched after disposing the bag") {
                beforeEach {
                    sut.bind(cell: cellType)
                    cellType.disposeBag = DisposeBag()
                    cellType.actionButton.sendActions(for: .touchUpInside)
                }
                it("didTapCardAction method is not called") {
                    expect(viewControllerType.isDidTapCardActionCalled).toEventually(be(0))
                }
            }

            context("the cell's share button is touched after disposing the bag") {
                beforeEach {
                    sut.bind(cell: cellType)
                    cellType.disposeBag = DisposeBag()
                    cellType.shareButton.sendActions(for: .touchUpInside)
                }
                it("didTapShare method is not called one time") {
                    expect(viewControllerType.isDidTapShareCalled).toEventually(be(0))
                }
            }

            context("the cell's share button is touched") {
                beforeEach {
                    sut.bind(cell: cellType)
                    cellType.shareButton.sendActions(for: .touchUpInside)
                }
                it("didTapShare method is called one time") {
                    expect(viewControllerType.isDidTapShareCalled).toEventually(be(1))
                }
            }

            context("the view scrolls the cards with the chat enabled") {
                beforeEach {
                    sut.bind(withViewModel: viewModelType, listingDeckView: viewType)
                    let offset = Int.makeRandom(min: 0, max: 1000)
                    viewControllerType.contentOffset.value = CGPoint(x: offset, y: 0)
                }
                it("updateViewWithAlpha method is called once") {
                    expect(viewControllerType.isUpdateViewWithAlphaCalled).toEventually(be(1))
                }
            }

            context("the view scrolls the cards with the chat enabled") {
                beforeEach {
                    sut.bind(withViewModel: viewModelType, listingDeckView: viewType)
                    viewType.currentPage = 1
                    let offset = Int.makeRandom(min: 0, max: 1000)
                    viewControllerType.contentOffset.value = CGPoint(x: offset, y: 0)
                }
                it("the viewmodel moves to the current item") {
                    expect(viewModelType.moveToListingAtIndexIsCalled).toEventually(be(1))
                }
                it("the viewcontroller moves to the current item") {
                    expect(viewControllerType.isDidMoveToItemAtIndex).toEventually(be(1))
                }
                it("the viewmodel detects that the user has scrolled") {
                    expect(viewModelType.userHasScrollCalled).toEventually(be(1))
                }
            }

            context("the user does not scroll") {
                beforeEach {
                    sut.bind(withViewModel: viewModelType, listingDeckView: viewType)
                }
                it("the viewmodel does not register any scroll") {
                    expect(viewModelType.userHasScrollCalled).toEventually(be(0))
                }
            }

            context("the keyboard appears") {
                beforeEach {
                    sut.bind(withViewModel: viewModelType, listingDeckView: viewType)
                    viewControllerType.rx_keyboardChanges.value = KeyboardChange(height: 0,
                                                                                 origin: 0,
                                                                                 animationTime: 0,
                                                                                 animationOptions: .allowUserInteraction,
                                                                                 visible: true,
                                                                                 isLocal: true)
                }
                it("updateWithKeyboardChange method is called twice") {
                    expect(viewControllerType.isUpdateWithKeyboardChangeCalled).toEventually(be(2))
                }
            }

            context("the viewmodel updates the bumpup banner information ") {
                beforeEach {
                    sut.bind(withViewModel: viewModelType, listingDeckView: viewType)
                    viewModelType.bumpUpBannerInfo.value = BumpUpInfo(type: .free,
                                                                      timeSinceLastBump: TimeInterval.makeRandom(),
                                                                      maxCountdown: TimeInterval.makeRandom(),
                                                                      price: nil,
                                                                      bannerInteractionBlock: { _ in }, buttonBlock: { _ in })
                }
                it("showBumpUpBannerBumpInfo method is called") {
                    expect(viewControllerType.isShowBumpUpBannerBumpInfoCalled).toEventually(be(1))
                }
            }

            context("the viewmodel updates the actionButtons") {
                beforeEach {
                    sut.bind(withViewModel: viewModelType, listingDeckView: viewType)
                    viewModelType.actionButtons.value = [UIAction(interface: .text(String.makeRandom()),
                                                                  action: {},
                                                                  accessibilityId: nil)]
                }
                it("updateViewWithActions method is called twice") {
                    expect(viewControllerType.isUpdateViewWithActionsCalled).toEventually(be(2))
                }
            }

            context("the user taps the actionbutton") {
                beforeEach {
                    sut.bind(withViewModel: viewModelType, listingDeckView: viewType)
                    viewType.actionButton.sendActions(for: .touchUpInside)
                }
                it("did tap action method is called once") {
                    expect(viewModelType.didTapActionButtonCalled).toEventually(be(1))
                }
            }

            context("the user taps the playButton") {
                beforeEach {
                    sut.bind(withViewModel: viewModelType, listingDeckView: viewType)
                    viewType.startPlayingButton.sendActions(for: .touchUpInside)
                }
                it("open video player method is called once") {
                    expect(viewModelType.openVideoPlayerCalled).toEventually(be(1))
                }
            }

            context("we bind twice the viewcontroller") {
                beforeEach {
                    sut.bind(withViewModel: viewModelType, listingDeckView: viewType)
                    currentDisposeBag = sut.disposeBag
                    sut.bind(withViewModel: viewModelType, listingDeckView: viewType)
                }
                it("the dispose bag changes") {
                    expect(sut.disposeBag).toNot(be(currentDisposeBag))
                }
            }

            context("we dealloc the viewcontroller") {
                beforeEach {
                    sut.bind(withViewModel: viewModelType, listingDeckView: viewType)
                    viewControllerType = MockListingDeckViewControllerBinderType()
                }
                it("and the binder's viewcontroller reference dies too (so weak)") {
                    expect(sut.listingDeckViewController).toEventually(beNil())
                }
            }
        }
    }
}

private class MockListingDeckViewControllerBinderCellType: ListingDeckViewControllerBinderCellType {

    var rxShareButton: Reactive<UIButton> { return shareButton.rx }
    let shareButton = UIButton(frame: .zero)

    var rxActionButton: Reactive<UIButton> { return actionButton.rx }
    let actionButton = UIButton(frame: .zero)

    var rxUserIcon: Reactive<UIButton> { return userIcon.rx }
    let userIcon = UIButton(frame: .zero)

    var disposeBag = DisposeBag()

    func recycleDisposeBag() {
        disposeBag = DisposeBag()
    }
}

private class MockListingDeckViewType: ListingDeckViewType {
    var rxStartPlayingButton: Reactive<UIButton> { return startPlayingButton.rx } // ☢️ do not know how to test this
    var startPlayingButton: UIButton = UIButton(type: .custom)

    var rxCollectionView: Reactive<UICollectionView> { return collectionView.rx }

    var rxDidBeginEditing: ControlEvent<()>? // ☢️ do not know how to test this
    var rxDidEndEditing: ControlEvent<()>? // ☢️ do not know how to test this

    var collectionView: UICollectionView = UICollectionView(frame: .zero,
                                                            collectionViewLayout: UICollectionViewFlowLayout())

    var rxActionButton: Reactive<LetgoButton> { return actionButton.rx }
    let actionButton = LetgoButton(withStyle: .terciary)

    var currentPage: Int = 0

    func handleCollectionChange<T>(_ change: CollectionChange<T>, completion: ((Bool) -> Void)?) { }

    var isPageOffsetCalled: Int = 0
    func normalizedPageOffset(givenOffset: CGFloat) -> CGFloat {
        isPageOffsetCalled += 1
        return 0
    }

    func resetVariables() {
        isPageOffsetCalled = 0
    }
}

final class MockListingDeckViewModelType: ListingDeckViewModelType {
    var isPlayable: Bool = true
    var quickChatViewModel: QuickChatViewModel = QuickChatViewModel()
    func replaceListingCellModelAtIndex(_ index: Int, withListing listing: Listing) {
        replaceIndexIsCalled += 1
    }

    var rxIsChatEnabled: Observable<Bool> { return isChatEnabled.asObservable() }
    var isChatEnabled: Variable<Bool> = Variable<Bool>(true)

    var rxActionButtons: Observable<[UIAction]> { return actionButtons.asObservable() }
    let actionButtons: Variable<[UIAction]> = Variable<[UIAction]>([])

    var rxBumpUpBannerInfo: Observable<BumpUpInfo?> { return bumpUpBannerInfo.asObservable() }
    let bumpUpBannerInfo: Variable<BumpUpInfo?> = Variable<BumpUpInfo?>(nil)

    var rxNavBarButtons: Observable<[UIAction]> { return navBarButtons.asObservable() }
    let navBarButtons: Variable<[UIAction]> = Variable<[UIAction]>([])

    var rxObjectChanges: Observable<CollectionChange<ListingCellModel>> { return objects.changesObservable }
    let objects: CollectionVariable<ListingCellModel> = CollectionVariable<ListingCellModel>([])

    var moveToListingAtIndexIsCalled: Int = 0
    func moveToListingAtIndex(_ index: Int, movement: DeckMovement) {
        moveToListingAtIndexIsCalled += 1
    }

    func openVideoPlayer() {
        openVideoPlayerCalled += 1
    }
    func didTapActionButton() {
        didTapActionButtonCalled += 1
    }

    var userHasScrollCalled: Int = 0
    var userHasScrolled: Bool = false { didSet { userHasScrollCalled += 1 } }
    var currentIndex: Int = 0
    var replaceIndexIsCalled: Int = 0
    var didTapActionButtonCalled: Int = 0
    var openVideoPlayerCalled: Int = 0

    func resetVariables() {
        userHasScrollCalled = 0
        moveToListingAtIndexIsCalled = 0
        currentIndex = 0
        replaceIndexIsCalled = 0
        didTapActionButtonCalled = 0
        openVideoPlayerCalled = 0
    }
}

private class MockListingDeckViewControllerBinderType: ListingDeckViewControllerBinderType {
    var rxDidBeginEditing: ControlEvent<()>? { return textField.rx.controlEvent(.editingDidBegin) }
    var rxDidEndEditing: ControlEvent<()>? { return textField.rx.controlEvent(.editingDidEnd) }
    var textField = UITextField()

    func didMoveToItemAtIndex(_ index: Int) {
        isDidMoveToItemAtIndex += 1
    }

    func didEndDecelerating() {
        // ☢️ do not know how to test this
    }

    func willBeginDragging() {
        // ☢️ do not know how to test this
    }
    func willDisplayCell(_ cell: UICollectionViewCell, atIndexPath indexPath: IndexPath) {
        // ☢️ do not know how to test this
    }
    func turnNavigationBar(_ on: Bool) {
        // ☢️ do not know how to test this
    }

    func updateViewWith(alpha: CGFloat, chatEnabled: Bool, actionsEnabled: Bool) {
        isUpdateViewWithAlphaCalled += 1
    }

    var rxContentOffset: Observable<CGPoint> { return contentOffset.asObservable() }
    var contentOffset: Variable<CGPoint> = Variable<CGPoint>(CGPoint(x: 0, y: 0))
    var keyboardChanges: Observable<KeyboardChange> { return rx_keyboardChanges.asObservable() }
    let rx_keyboardChanges: Variable<KeyboardChange> = Variable(KeyboardChange(height: 0,
                                                                               origin: 0,
                                                                               animationTime: 0,
                                                                               animationOptions: .allowUserInteraction,
                                                                               visible: true,
                                                                               isLocal: true))

    var isUpdateViewWithActionsCalled: Int = 0
    var isUpdateWithKeyboardChangeCalled: Int = 0
    var isShowBumpUpBannerBumpInfoCalled: Int = 0
    var isDidTapShareCalled: Int = 0
    var isDidTapUserIconCalled = 0
    var isDidTapCardActionCalled: Int = 0
    var isUpdateViewWithAlphaCalled: Int = 0
    var isDidMoveToItemAtIndex: Int = 0

    func resetVariables() {
        isUpdateViewWithActionsCalled = 0
        isUpdateWithKeyboardChangeCalled = 0
        isShowBumpUpBannerBumpInfoCalled = 0
        isDidTapShareCalled = 0
        isDidTapCardActionCalled = 0
        isUpdateViewWithAlphaCalled = 0
        isDidTapUserIconCalled = 0
        isDidMoveToItemAtIndex = 0
    }

    func updateViewWithActions(_ actions: [UIAction]) {
        isUpdateViewWithActionsCalled += 1
    }
    func updateWith(keyboardChange: KeyboardChange) {
        isUpdateWithKeyboardChangeCalled += 1
    }
    func updateWithBumpUpInfo(_ bumpInfo: BumpUpInfo?) {
        isShowBumpUpBannerBumpInfoCalled += 1
    }
    func didTapShare() {
        isDidTapShareCalled += 1
    }
    func didTapOnUserIcon() {
        isDidTapUserIconCalled += 1
    }
    func didTapCardAction() {
        isDidTapCardActionCalled += 1
    }
}
