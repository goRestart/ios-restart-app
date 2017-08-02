//
//  TaxonomiesViewModel.swift
//  LetGo
//
//  Created by Juan Iglesias on 20/07/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit


protocol TaxonomiesViewModelDelegate: BaseViewModelDelegate {}

protocol TaxonomiesDelegate: class {
    func didSelectTaxonomyChild(taxonomyChild: TaxonomyChild)
}

class TaxonomiesViewModel : BaseViewModel {
    
    weak var delegate: TaxonomiesViewModelDelegate?
    weak var taxonomiesDelegate: TaxonomiesDelegate?
    
    var title: String
    
    let taxonomies: [Taxonomy]
    let tracker: Tracker
    let source: EventParameterTypePage
    
    
    // MARK: -LifeCycle
    
    init(taxonomies: [Taxonomy], source: EventParameterTypePage, tracker: Tracker) {
        title = LGLocalizedString.categoriesTitle
        self.taxonomies = taxonomies
        self.source = source
        self.tracker = tracker
    }
    
    convenience init(taxonomies: [Taxonomy], source: EventParameterTypePage) {
        self.init(taxonomies: taxonomies, source: source, tracker: TrackerProxy.sharedInstance)
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        let event = TrackerEvent.categoriesStart(source: source)
        tracker.trackEvent(event)
    }
    
    func taxonomyChildSelected(taxonomyChild: TaxonomyChild) {
        let event = TrackerEvent.categoriesComplete(keywordName: taxonomyChild.name, source: source)
        tracker.trackEvent(event)
        taxonomiesDelegate?.didSelectTaxonomyChild(taxonomyChild: taxonomyChild)
        goBack()
    }
    
    private func goBack() {
        delegate?.vmPop()
    }
}

