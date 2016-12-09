//
//  CreateCommercialViewModel.swift
//  LetGo
//
//  Created by Isaac Roldán Armengol on 4/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

protocol CreateCommercialViewModelDelegate: class {
    func vmOpenSell()
}

enum CreateCommercialViewStatus {
    case None
    case Loading
    case Data
    case Empty(LGEmptyViewModel)
    case Error(LGEmptyViewModel)
}

class CreateCommercialViewModel: BaseViewModel {
    
    private let commercializerRepository: CommercializerRepository
    var products: [CommercializerProduct] = []
    var status: Variable<CreateCommercialViewStatus>
    weak var delegate: CreateCommercialViewModelDelegate?
    
    convenience override init() {
        let commercializerRepository = Core.commercializerRepository
        self.init(commercializerRepository: commercializerRepository)
    }
    
    init(commercializerRepository: CommercializerRepository) {
        self.commercializerRepository = commercializerRepository
        self.status = Variable<CreateCommercialViewStatus>(.None)
        super.init()
    }
    
    internal override func didBecomeActive(firstTime: Bool) {
        fetchProducts()
    }
    
    func fetchProducts() {
        self.status.value = .Loading
        commercializerRepository.indexAvailableProducts { [weak self] result in
            if let value = result.value {
                self?.products = value
                if !value.isEmpty {
                    self?.status.value = .Data
                } else if let vm = self?.viewModelForEmptyView() {
                    self?.status.value = .Empty(vm)
                } else if let vm = self?.emptyViewModelForError(.Internal(message: "")){
                    self?.status.value = .Error(vm)
                } else {
                    self?.status.value = .None
                }
            } else if let error = result.error, let vm = self?.emptyViewModelForError(error) {
                self?.status.value = CreateCommercialViewStatus.Error(vm)
            } else {
                self?.status.value = .None
            }
        }
    }
    
    
    // MARK: - Empty View Model
    
    func viewModelForEmptyView() -> LGEmptyViewModel? {
        guard let image = UIImage(named: "ic_nothing_to_promote") else { return nil }
        return LGEmptyViewModel(icon: image,
                                title: LGLocalizedString.commercializerProductListEmptyTitle,
                                body: LGLocalizedString.commercializerProductListEmptyBody,
                                buttonTitle: LGLocalizedString.commercializerProductListEmptyButton,
                                action: delegate?.vmOpenSell,
                                secondaryButtonTitle: nil, secondaryAction: nil)
    }
    
    private func emptyViewModelForError(error: RepositoryError) -> LGEmptyViewModel {
        let emptyVM: LGEmptyViewModel
        switch error {
        case .NetworkFailedOnBackground:
            emptyVM = LGEmptyViewModel.genericErrorWithRetry(fetchProducts)
        case .Network:
            emptyVM = LGEmptyViewModel.networkErrorWithRetry(fetchProducts)
        case .Internal, .Forbidden, .NotFound, .Unauthorized, .TooManyRequests, .UserNotVerified, .ServerError:
            emptyVM = LGEmptyViewModel.genericErrorWithRetry(fetchProducts)
        }
        return emptyVM
    }

    
    // MARK: - Data Source
    
    func thumbnailAt(index: Int) -> String? {
        guard 0..<products.count ~= index else { return nil }
        return products[index].thumbnailURL
    }
    
    func productIdAt(index: Int) -> String? {
        guard 0..<products.count ~= index else { return nil }
        return products[index].objectId
    }
    
    func countryCodeAt(index: Int) -> String? {
        guard 0..<products.count ~= index else { return nil }
        return products[index].countryCode
    }
    
    func commercializerTemplates(index: Int) -> [CommercializerTemplate]? {
        guard let countryCode = countryCodeAt(index) else { return nil }
        return commercializerRepository.templatesForCountryCode(countryCode)
    }
}
