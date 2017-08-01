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
    
    static let minimumImageNeeded: Int = 3
    static let categoriesIdentifier = "categories"
    
    weak var navigator: TourCategoriesNavigator?
    private let categoryRepository: CategoryRepository
    var categories: [TaxonomyChild] = []
    let categoriesSelected = Variable<[TaxonomyChild]>([])
    var categoriesMissingCounter: Int {
        return TourCategoriesViewModel.minimumImageNeeded - categoriesSelectedCounter
    }
    var minimumCategoriesSelected = Variable<Bool>(false)
    
    private var categoriesSelectedCounter: Int {
        return categoriesSelected.value.count
    }
    
    var okButtonText = Variable<String>("")
    
    weak var delegate: TourCategoriesViewModelDelegate?
    let disposeBag = DisposeBag()
    
    // MARK: Lifecycle
    
    init(categoryRepository: CategoryRepository) {
        self.categoryRepository = categoryRepository
        self.categories = categoryRepository.indexTaxonomies().flatMap { $0.children }.filter { !$0.isOthers }
        super.init()
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        setupRx()
    }
    
    convenience override init() {
        self.init(categoryRepository: Core.categoryRepository)
    }
    
    
    // MARK: Rx
    
    private func setupRx() {
        categoriesSelected.asObservable().bindNext { [weak self] categoriesSelected in
            guard let strongSelf = self else { return }
            var okText: String
            if categoriesSelected.count == 0 {
                okText = String(format: LGLocalizedString.onboardingCategoriesButtonTitleInitial, Int(TourCategoriesViewModel.minimumImageNeeded))
            } else if categoriesSelected.count < TourCategoriesViewModel.minimumImageNeeded {
                okText =  String(format: LGLocalizedString.onboardingCategoriesButtonCountdown, Int(strongSelf.categoriesMissingCounter))
            } else {
                okText = LGLocalizedString.onboardingCategoriesButtonTitleFinish
            }
            strongSelf.okButtonText.value = okText
            strongSelf.minimumCategoriesSelected.value = categoriesSelected.count >= TourCategoriesViewModel.minimumImageNeeded
        }.addDisposableTo(disposeBag)
    }
    
    
    // MARK: Actions
    
    func okButtonPressed() {
        let categoriesSelectedDict:[String: [TaxonomyChild]] = [TourCategoriesViewModel.categoriesIdentifier: categoriesSelected.value]
        NotificationCenter.default.post(name: .onboardingCategories, object: nil, userInfo: categoriesSelectedDict)
        navigator?.tourCategoriesFinish(withCategories: categoriesSelected.value)
    }
}


extension Notification.Name {
    static let onboardingCategories = Notification.Name("onboardingCategories")
}
