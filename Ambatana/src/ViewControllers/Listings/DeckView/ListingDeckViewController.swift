//
//  ListingDeckViewController.swift
//  LetGo
//
//  Created by Facundo Menzella on 23/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

final class ListingDeckViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    struct Identifiers {
        static let cardView = "ListingCardView"
    }
    let listingDeckView = ListingDeckView()
    let contentOffset = Variable<CGFloat>(0)
    fileprivate let overlaysAlpha = Variable<CGFloat>(1)

    fileprivate let viewModel: ListingDeckViewModel
    fileprivate let disposeBag = DisposeBag()

    init(viewModel: ListingDeckViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() {
        self.view = listingDeckView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()

        setupNavigationBar()
        setupCollectionView()
    }

    // MARK: Rx

    private func setupRx() {
        contentOffset.asObservable()
            .map { [weak self] x in
                guard let strongSelf = self else { return x }
                let pageOffset = strongSelf.listingDeckView.layout.pageOffset(givenOffset: x).truncatingRemainder(dividingBy: 1.0)
                if pageOffset < 0.5 {
                    return pageOffset
                }
                return (1 - pageOffset)
        }.bindTo(overlaysAlpha).addDisposableTo(disposeBag)

        overlaysAlpha.asObservable().bindTo(listingDeckView.bottomView.rx.alpha).addDisposableTo(disposeBag)
    }
    
    // MARK: CollectionView

    private func setupCollectionView() {
        func setupCollectionRx() {
            viewModel.objectChanges.observeOn(MainScheduler.instance).bindNext { [weak self] change in
                guard let strongSelf = self else { return }
                //                    strongSelf.listingDeckView.collectionView.handleCollectionChange(change)
                strongSelf.listingDeckView.collectionView.reloadData()
                }.addDisposableTo(disposeBag)
        }

        listingDeckView.collectionView.dataSource = self
        listingDeckView.collectionView.delegate = self
        listingDeckView.collectionView.reloadData()
        listingDeckView.collectionView.register(ListingCardView.self, forCellWithReuseIdentifier: Identifiers.cardView)

        setupCollectionRx()
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.objectCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.cardView, for: indexPath) as? ListingCardView {
            let listing = viewModel.listingCellModelAt(index: indexPath.row)
            cell.populateWith(listing?.listing.objectId ?? "IDENTIFICADOR")
            return cell
        }
        return UICollectionViewCell()
    }

    // ScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        contentOffset.value = scrollView.contentOffset.x

    }

    // MARK: NavBar

    private func setupNavigationBar() {
        setNavBarBackgroundStyle(.transparent(substyle: .light))
        edgesForExtendedLayout = []

        let rightButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_more_options"), style: .plain, target: self, action: #selector(didTapMoreInfo))
        let leftButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_close_red"), style: .plain, target: self, action: #selector(didTapClose))
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.leftBarButtonItem  = leftButton

        setNavigationBarRightButtons([])
        viewModel.navBarButtons.asObservable().subscribeNext { [weak self] navBarButtons in
            guard let strongSelf = self else { return }
            let takeUntilAction = strongSelf.viewModel.navBarButtons.asObservable().skip(1)
            if navBarButtons.count == 1 {
                let action = navBarButtons[0]
                switch action.interface {
                case .textImage:
                    let shareButton = CarouselUIHelper.buildShareButton(action.text, icon: action.image)
                    let rightItem = UIBarButtonItem(customView: shareButton)
                    rightItem.style = .plain
                    shareButton.rx.tap.takeUntil(takeUntilAction).bindNext{
                        action.action()
                        }.addDisposableTo(strongSelf.disposeBag)
                    strongSelf.navigationItem.rightBarButtonItems = nil
                    strongSelf.navigationItem.rightBarButtonItem = rightItem
                default:
                    strongSelf.setLetGoRightButtonWith(action, buttonTintColor: UIColor.white,
                                                       tapBlock: { tapEvent in
                                                        tapEvent.takeUntil(takeUntilAction).bindNext{
                                                            action.action()
                                                            }.addDisposableTo(strongSelf.disposeBag)
                    })
                }
            } else if navBarButtons.count > 1 {
                var buttons = [UIButton]()
                navBarButtons.forEach { navBarButton in
                    let button = UIButton(type: .system)
                    button.setImage(navBarButton.image, for: .normal)
                    button.rx.tap.takeUntil(takeUntilAction).bindNext { _ in
                        navBarButton.action()
                        }.addDisposableTo(strongSelf.disposeBag)
                    buttons.append(button)
                }
                strongSelf.setNavigationBarRightButtons(buttons)
            }
            }.addDisposableTo(disposeBag)
    }

    @objc private func didTapBumpUp() {

    }

    @objc private func didTapClose() {
        //            closeBumpUpBanner()
        viewModel.close()
    }

    @objc private func didTapMoreInfo() {

    }

}
