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

        fdescribe("ListingDeckViewControllerBinder setup") {
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
                    expect(viewControllerType.isDidTapUserIconCalled) == 1
                }
            }

            context("the cell's action button is touched after disposing the bag") {
                beforeEach {
                    sut.bind(cell: cellType)
                    cellType.disposeBag = DisposeBag()
                    cellType.userIcon.sendActions(for: .touchUpInside)
                }
                it("didTapCardAction method is not called") {
                    expect(viewControllerType.isDidTapUserIconCalled) == 0
                }
            }

            context("the cell's action button is touched") {
                beforeEach {
                    sut.bind(cell: cellType)
                    cellType.actionButton.sendActions(for: .touchUpInside)
                }
                it("didTapCardAction method is called one time") {
                    expect(viewControllerType.isDidTapCardActionCalled) == 1
                }
            }

            context("the cell's action button is touched after disposing the bag") {
                beforeEach {
                    sut.bind(cell: cellType)
                    cellType.disposeBag = DisposeBag()
                    cellType.actionButton.sendActions(for: .touchUpInside)
                }
                it("didTapCardAction method is not called") {
                    expect(viewControllerType.isDidTapCardActionCalled) == 0
                }
            }

            context("the cell's share button is touched after disposing the bag") {
                beforeEach {
                    sut.bind(cell: cellType)
                    cellType.disposeBag = DisposeBag()
                    cellType.shareButton.sendActions(for: .touchUpInside)
                }
                it("didTapShare method is not called one time") {
                    expect(viewControllerType.isDidTapShareCalled) == 0
                }
            }

            context("the cell's share button is touched") {
                beforeEach {
                    sut.bind(cell: cellType)
                    cellType.shareButton.sendActions(for: .touchUpInside)
                }
                it("didTapShare method is called one time") {
                    expect(viewControllerType.isDidTapShareCalled) == 1
                }
            }

            context("the viewmodel updates the alternative actions") {
                beforeEach {
                    sut.bind(withViewModel: viewModelType, listingDeckView: viewType)
                    viewModelType.altActions.value = [UIAction(interface: .text(String.makeRandom()),
                                                               action: {},
                                                               accessibilityId: nil)]
                }
                it("vmShowOptionsCancelLabel method is called one time") {
                    expect(viewControllerType.isVmShowOptionsCancelLabelCalled) == 1
                }
            }

            context("the viewmodel updates the navbar actions") {
                beforeEach {
                    sut.bind(withViewModel: viewModelType, listingDeckView: viewType)
                    viewModelType.navBarButtons.value = [UIAction(interface: .text(String.makeRandom()),
                                                                  action: {},
                                                                  accessibilityId: nil)]
                }
                it("setNavigationBarRightButtons & setLetGoRightButtonWith methods are called one time each") {
                    expect(viewControllerType.isSetNavigationBarRightButtonsCalled) == 1
                    expect(viewControllerType.isSetLetGoRightButtonWithCalled) == 1
                }
            }

            context("the view scrolls the cards with the chat enabled") {
                beforeEach {
                    sut.bind(withViewModel: viewModelType, listingDeckView: viewType)
                    let offset = Int.makeRandom(min: 0, max: 1000)
                    viewControllerType.collectionView.contentOffset = CGPoint(x: offset, y: 0)
                }
                it("updateViewWithAlpha method is called twice (initial + update)") {
                    expect(viewControllerType.isUpdateViewWithAlphaCalled) == 2
                }
            }

            context("the view scrolls the cards with the chat enabled") {
                beforeEach {
                    sut.bind(withViewModel: viewModelType, listingDeckView: viewType)
                    viewType.currentPage = 1
                    let offset = Int.makeRandom(min: 0, max: 1000)
                    viewControllerType.collectionView.contentOffset = CGPoint(x: offset, y: 0)
                }
                it("the viewmodel moves to the current item") {
                    expect(viewModelType.moveToProductIsCalled) == 1
                }
                it("the viewmodel detects that the user has scrolled") {
                    expect(viewModelType.userHasScrollCalled) == 1
                }
            }

            context("the user does not scroll") {
                beforeEach {
                    sut.bind(withViewModel: viewModelType, listingDeckView: viewType)
                }
                it("the viewmodel does not register any scroll") {
                    expect(viewModelType.userHasScrollCalled) == 0
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
                    expect(viewControllerType.isUpdateWithKeyboardChangeCalled) == 2
                }
            }

            context("the viewmodel updates the bumpup banner information ") {
                beforeEach {
                    sut.bind(withViewModel: viewModelType, listingDeckView: viewType)
                    viewModelType.bumpUpBannerInfo.value = BumpUpInfo(type: .free,
                                                                      timeSinceLastBump: TimeInterval.makeRandom(),
                                                                      maxCountdown: TimeInterval.makeRandom(),
                                                                      price: nil,
                                                                      bannerInteractionBlock: {}, buttonBlock: {})
                }
                it("showBumpUpBannerBumpInfo method is called") {
                    expect(viewControllerType.isShowBumpUpBannerBumpInfoCalled) == 1
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
                    expect(viewControllerType.isUpdateViewWithActionsCalled) == 2
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
}

private class MockListingDeckViewType: ListingDeckViewType {

    var collectionView: UICollectionView = UICollectionView(frame: .zero,
                                                            collectionViewLayout: UICollectionViewFlowLayout())
    var rxActionButton: Reactive<UIButton> { return actionButton.rx }
    let actionButton = UIButton(frame: .zero)
    var currentPage: Int = 0

    var isPageOffsetCalled: Int = 0
    func pageOffset(givenOffset: CGFloat) -> CGFloat {
        isPageOffsetCalled += 1
        return 0
    }

    func hideChat() { }

    func resetVariables() {
        isPageOffsetCalled = 0
    }
}

private class MockListingDeckViewModelType: ListingDeckViewModelType {
    var rxIsChatEnabled: Observable<Bool> { return isChatEnabled.asObservable() }
    var isChatEnabled: Variable<Bool> = Variable<Bool>(true)

    var rxActionButtons: Observable<[UIAction]> { return actionButtons.asObservable() }
    let actionButtons: Variable<[UIAction]> = Variable<[UIAction]>([])

    var rxBumpUpBannerInfo: Observable<BumpUpInfo?> { return bumpUpBannerInfo.asObservable() }
    let bumpUpBannerInfo: Variable<BumpUpInfo?> = Variable<BumpUpInfo?>(nil)

    var rxNavBarButtons: Observable<[UIAction]> { return navBarButtons.asObservable() }
    let navBarButtons: Variable<[UIAction]> = Variable<[UIAction]>([])

    var rxAltActions: Observable<[UIAction]> { return altActions.asObservable() }
    let altActions: Variable<[UIAction]> = Variable<[UIAction]>([])

    var rxObjectChanges: Observable<CollectionChange<ListingCellModel>> { return objects.changesObservable }
    let objects: CollectionVariable<ListingCellModel> = CollectionVariable<ListingCellModel>([])

    var moveToProductIsCalled: Int = 0
    func moveToProductAtIndex(_ index: Int, movement: CarouselMovement) {
        moveToProductIsCalled += 1
    }

    var userHasScrollCalled: Int = 0
    var userHasScrolled: Bool = false { didSet { userHasScrollCalled += 1 } }

    func resetVariables() {
        userHasScrollCalled = 0
        moveToProductIsCalled = 0
    }
}

private class MockListingDeckViewControllerBinderType: ListingDeckViewControllerBinderType {
    var rxContentOffset: Observable<CGPoint> { return rxCollectionView.contentOffset.share() }

    var keyboardChanges: Observable<KeyboardChange> { return rx_keyboardChanges.asObservable() }

    let rx_keyboardChanges: Variable<KeyboardChange> = Variable(KeyboardChange(height: 0,
                                                                               origin: 0,
                                                                               animationTime: 0,
                                                                               animationOptions: .allowUserInteraction,
                                                                               visible: true,
                                                                               isLocal: true))

    let collectionView: UICollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 500, height: 100),
                                                           collectionViewLayout: UICollectionViewFlowLayout())
    let rxCollectionView: Reactive<UICollectionView>

    var isUpdateViewWithActionsCalled: Int = 0
    var isUpdateWithKeyboardChangeCalled: Int = 0
    var isVmShowOptionsCancelLabelCalled: Int = 0
    var isShowBumpUpBannerBumpInfoCalled: Int = 0
    var isDidTapShareCalled: Int = 0
    var isDidTapUserIconCalled = 0
    var isDidTapCardActionCalled: Int = 0
    var isUpdateViewWithAlphaCalled: Int = 0
    var isSetNavigationBarRightButtonsCalled: Int = 0
    var isSetLetGoRightButtonWithCalled: Int = 0

    init() {
        rxCollectionView = collectionView.rx
    }

    func resetVariables() {
        isUpdateViewWithActionsCalled = 0
        isUpdateWithKeyboardChangeCalled = 0
        isVmShowOptionsCancelLabelCalled = 0
        isShowBumpUpBannerBumpInfoCalled = 0
        isDidTapShareCalled = 0
        isDidTapCardActionCalled = 0
        isUpdateViewWithAlphaCalled = 0
        isSetNavigationBarRightButtonsCalled = 0
        isSetLetGoRightButtonWithCalled = 0
        isDidTapUserIconCalled = 0
    }

    func updateViewWithActions(_ actions: [UIAction]) {
        isUpdateViewWithActionsCalled += 1
    }
    func updateWith(keyboardChange: KeyboardChange) {
        isUpdateWithKeyboardChangeCalled += 1
    }
    func vmShowOptions(_ cancelLabel: String, actions: [UIAction]) {
        isVmShowOptionsCancelLabelCalled += 1
    }
    func showBumpUpBanner(bumpInfo: BumpUpInfo) {
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
    func updateViewWith(alpha: CGFloat, chatEnabled: Bool) {
        isUpdateViewWithAlphaCalled += 1
    }
    func setNavigationBarRightButtons(_ actions: [UIButton]) {
        isSetNavigationBarRightButtonsCalled += 1
    }
    func setLetGoRightButtonWith(_ action: UIAction, buttonTintColor: UIColor?, tapBlock: (ControlEvent<Void>) -> Void ) {
        isSetLetGoRightButtonWithCalled += 1
    }
}
