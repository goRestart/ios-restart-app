//
//  CreateCommercialViewModel.swift
//  LetGo
//
//  Created by Isaac Roldán Armengol on 4/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol CreateCommercialViewModelDelegate: class {
    func vmWillStartDownloadingProducts()
    func vmDidFinishDownloadingProducts()
    func vmDidFailProductsDownload()
}

class CreateCommercialViewModel: BaseViewModel {
    
    weak var delegate: CreateCommercialViewModelDelegate?
    
    private let commercializerRepository: CommercializerRepository
    var products: [CommercializerProduct] = []
    
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
        fetchProducts()
    }
    
    func fetchProducts() {
        delegate?.vmWillStartDownloadingProducts()
        commercializerRepository.indexAvailableProducts { [weak self] result in
            if let value = result.value {
                self?.products = value
                self?.delegate?.vmDidFinishDownloadingProducts()
            } else {
                self?.delegate?.vmDidFailProductsDownload()
            }
        }
    }
}
