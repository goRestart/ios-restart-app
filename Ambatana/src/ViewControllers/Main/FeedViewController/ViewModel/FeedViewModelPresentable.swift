//
//  FeedViewModelPresentable.swift
//  LetGo
//
//  Created by Haiyan Ma on 20/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

typealias FeedAction = (FeedViewModel) -> ()

protocol FeedPresenter {
    static var feedClass: AnyClass { get }
    static var reuseIdentifier: String { get }
    var height: CGFloat { get }
}

extension FeedPresenter {
    static var reuseIdentifier: String {
        return String(describing: feedClass.self)
    }
}

protocol FeedNavigatorOwnership: class {
    var navigator: MainTabNavigator? { get set }
}

protocol FeedViewModelType: FeedNavigatorOwnership {

    var sectionsDriver: Driver<[FeedSectionMap]> { get }
    var infoBubbleText: Variable<String> { get }
    var infoBubbleVisible: Variable<Bool> { get }

    var rxHasFilter: Driver<Bool> { get }
    
    var searchString: String? { get }
    
    var shouldShowInviteButton: Bool { get }
    
    var allHeaderPresenters: [FeedPresenter.Type] { get }
    var allCellItemPresenters: [FeedPresenter.Type] { get }
    
    var rxOperations: Driver<FeedOperation> { get }
    
    func openInvite()
    func showFilters()
    func refreshControlTriggered()

    func item(for indexPath: IndexPath) -> FeedPresenter?
    func header(for section: Int) -> FeedPresenter?
    func numberOfItems(in section: Int) -> Int
    func numberOfSections() -> Int

    func bubbleTapped()
}

enum FeedOperation {
    case reloadAll
    case insertItem(at: [IndexPath])
    case deleteItem(at: [IndexPath])
    case reloadItem(at: [IndexPath])
}
