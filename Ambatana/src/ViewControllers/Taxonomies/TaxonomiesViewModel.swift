//
//  TaxonomiesViewModel.swift
//  LetGo
//
//  Created by Juan Iglesias on 20/07/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit

// TODO: TO BE REMOVE

public protocol Taxonomy {
    var name: String { get }
    var icon: URL? { get }
    var children: [TaxonomyChild] { get }
}

struct LGTaxonomy: Taxonomy {
    var name: String
    var icon: URL?
    var children: [TaxonomyChild]
}

public protocol TaxonomyChild {
    var id: Int { get }
    var type: TaxonomyChildType { get }
    var name: String { get }
    var highlightOrder: Int? { get }
    var highlightIcon: URL? { get }
    
}

struct LGTaxonomyChild: TaxonomyChild {
    var id: Int
    var type: TaxonomyChildType
    var name: String
    var highlightOrder: Int?
    var highlightIcon: URL?
}

public enum TaxonomyChildType: String {
    case superKeyword = "superkeyword"
    case category = "category"
}
/////////

protocol TaxonomiesViewModelDelegate: BaseViewModelDelegate {}

protocol TaxonomiesDelegate: class {
    func didSelectTaxonomyChild(id: Int, name: String, type: TaxonomyChildType)
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
    
    func taxonomyChildSelected(id: Int, name: String, type: TaxonomyChildType) {
        taxonomiesDelegate?.didSelectTaxonomyChild(id: id, name: name, type: type)
        backTo()
    }
    
    fileprivate func backTo() {
        delegate?.vmPop()
    }
}

