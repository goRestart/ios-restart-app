//
//  PassiveBuyersViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 23/12/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit


protocol PassiveBuyersViewModelDelegate: BaseViewModelDelegate {

}


class PassiveBuyersViewModel: BaseViewModel {

    weak var navigator: PassiveBuyersNavigator?
    weak var delegate: PassiveBuyersViewModelDelegate?

    private let passiveBuyers: PassiveBuyersInfo
    private let passiveBuyersRepository: PassiveBuyersRepository

    convenience init(passiveBuyers: PassiveBuyersInfo) {
        self.init(passiveBuyers: passiveBuyers, passiveBuyersRepository: Core.passiveBuyersRepository)
    }

    init(passiveBuyers: PassiveBuyersInfo, passiveBuyersRepository: PassiveBuyersRepository) {
        self.passiveBuyers = passiveBuyers
        self.passiveBuyersRepository = passiveBuyersRepository
    }


    // MARK: - Public info

    var productImage: URL? {
        return passiveBuyers.productImage?.fileURL
    }

    var buyersCount: Int {
        return passiveBuyers.passiveBuyers.count
    }

    func buyerImageAtIndex(_ index: Int) -> URL? {
        return buyerAtIndex(index)?.avatar?.fileURL
    }

    func buyerNameAtIndex(_ index: Int) -> String? {
        return buyerAtIndex(index)?.name
    }


    // MARK: - Actions

    func closeButtonPressed() {
        navigator?.passiveBuyersCancel()
    }

    func contactButtonPressed() {
        delegate?.vmShowLoading(nil)
        passiveBuyersRepository.contactAllBuyers(passiveBuyersInfo: passiveBuyers) { [weak self] result in
            if let _ = result.value {
                self?.delegate?.vmHideLoading(LGLocalizedString.passiveBuyersContactSuccess) { [weak self] in
                    self?.navigator?.passiveBuyersCompleted()
                }
            } else {
                self?.delegate?.vmHideLoading(LGLocalizedString.passiveBuyersContactError, afterMessageCompletion: nil)
            }
        }
    }


    // MARK: - Private

    func buyerAtIndex(_ index: Int) -> PassiveBuyersUser? {
        guard 0..<passiveBuyers.passiveBuyers.count ~= index else { return nil }
        return passiveBuyers.passiveBuyers[index]
    }
}
