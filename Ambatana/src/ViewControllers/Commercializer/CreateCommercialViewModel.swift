//
//  CreateCommercialViewModel.swift
//  LetGo
//
//  Created by Isaac Roldán Armengol on 4/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class CreateCommercialViewModel: BaseViewModel {
    
    private let commercializerRepository: CommercializerRepository
    var products: [Product] = []
    
    convenience override init() {
        let commercializerRepository = Core.commercializerRepository
        self.init(commercializerRepository: commercializerRepository)
    }
    
    init(commercializerRepository: CommercializerRepository) {
        self.commercializerRepository = commercializerRepository
        super.init()
    }
    
    internal override func didSetActive(active: Bool) {
        super.didSetActive(active)
        
        guard active else { return }
    
    }
    
    func fetchProducts() {
        commercializerRepository
    }
}
