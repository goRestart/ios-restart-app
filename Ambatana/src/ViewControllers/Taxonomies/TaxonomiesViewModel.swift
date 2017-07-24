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
    
    init(taxonomies: [Taxonomy]) {
        title = LGLocalizedString.categoriesTitle
        self.taxonomies = taxonomies
    }
    
    func taxonomyChildSelected(taxonomyChild: TaxonomyChild) {
        taxonomiesDelegate?.didSelectTaxonomyChild(taxonomyChild: taxonomyChild)
        backTo()
    }
    
    fileprivate func backTo() {
        delegate?.vmPop()
    }
}

