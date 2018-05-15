 //
//  FeedAssembly.swift
//  LetGo
//
//  Created by Facundo Menzella on 12/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

extension SectionedMainFeed {
    var feedAssembly: FeedAssembly { return isActive ? .pro : .classic }
}
 
enum FeedAssembly {
    case pro
    case classic

    func makeWith(searchType: SearchType, filters: ListingFilters)  -> (BaseViewController, FeedNavigatorOwnership) {
        switch self {
        case .pro:
            let vm = FeedViewModel(searchType: searchType, filters: filters)
            let vc = FeedViewController(withViewModel: vm)
            return (vc, vm)
        case .classic:
            let vm = MainListingsViewModel(searchType: searchType, filters: filters)
            let vc = MainListingsViewController(viewModel: vm)
            return (vc, vm)
        }
    }

    func make() -> (BaseViewController, FeedNavigatorOwnership) {
        switch self {
        case .pro:
            let vm = FeedViewModel()
            return (FeedViewController(withViewModel: vm), vm)
        case .classic:
            let vm = MainListingsViewModel(searchType: nil, tabNavigator: nil)
            return  (MainListingsViewController(viewModel: vm), vm)
        }
    }
}
