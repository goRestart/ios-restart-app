//
//  TourCategoriesViewModel.swift
//  LetGo
//
//  Created by Juan Iglesias on 27/07/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

protocol TourCategoriesViewModelDelegate: BaseViewModelDelegate { }

class TourCategoriesViewModel: BaseViewModel {
    
    static let minimumTaxonomiesNeeded: Int = 3
    static let categoriesIdentifier = "categories"
    
    weak var navigator: TourCategoriesNavigator?
    fileprivate let keyValueStorage: KeyValueStorage
    private let tracker: Tracker
    
    var categories: [TaxonomyChild] = []
    let categoriesSelected = Variable<[TaxonomyChild]>([])
    var categoriesMissingCounter: Int {
        return TourCategoriesViewModel.minimumTaxonomiesNeeded - categoriesSelectedCounter
    }
    var minimumCategoriesSelected = Variable<Bool>(false)
    
    private var categoriesSelectedCounter: Int {
        return categoriesSelected.value.count
    }
    
    var okButtonText = Variable<String>("")
    
    weak var delegate: TourCategoriesViewModelDelegate?
    let disposeBag = DisposeBag()
    
    // MARK: Lifecycle
    
    init(tracker: Tracker, keyValueStorage: KeyValueStorage, taxonomies: [Taxonomy]) {
        self.tracker = tracker
        self.keyValueStorage = keyValueStorage
        self.categories = taxonomies.flatMap { $0.children }
        super.init()
    }
    
    convenience init(taxonomies: [Taxonomy]) {
        self.init(tracker: TrackerProxy.sharedInstance,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  taxonomies: taxonomies)
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        setupRx()
    }
    
    
    // MARK: Rx
    
    private func setupRx() {
        categoriesSelected.asObservable().bindNext { [weak self] categoriesSelected in
            guard let strongSelf = self else { return }
            var okText: String
            if categoriesSelected.count == 0 {
                okText = String(format: LGLocalizedString.onboardingCategoriesButtonTitleInitial, Int(TourCategoriesViewModel.minimumTaxonomiesNeeded))
            } else if categoriesSelected.count < TourCategoriesViewModel.minimumTaxonomiesNeeded {
                okText =  String(format: LGLocalizedString.onboardingCategoriesButtonCountdown, Int(strongSelf.categoriesMissingCounter))
            } else {
                okText = LGLocalizedString.onboardingCategoriesButtonTitleFinish
            }
            strongSelf.okButtonText.value = okText
            strongSelf.minimumCategoriesSelected.value = categoriesSelected.count >= TourCategoriesViewModel.minimumTaxonomiesNeeded
        }.addDisposableTo(disposeBag)
    }
    
    
    // MARK: Actions
    
    func okButtonPressed() {
        let event = TrackerEvent.onboardingInterestsComplete(superKeywords: categoriesSelected.value.map { $0.name })
        tracker.trackEvent(event)
        keyValueStorage[.userCategoriesPrefered] = categoriesSelected.value.map { $0.id }
        keyValueStorage.newPreferedCategoriesSelected.value = true
        navigator?.tourCategoriesFinish(withCategories: categoriesSelected.value)
    }
}
