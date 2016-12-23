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


//TODO: REMOVE!! JUST TO TEST
private struct FakePassiveBuyers: PassiveBuyersInfo {
    var objectId: String? = nil
    var productImage: File? = nil
    var passiveBuyers: [PassiveBuyersUser] = [FakePassiveBuyer(name: "User 1"), FakePassiveBuyer(name: "User 2"), FakePassiveBuyer(name: "User 3"), FakePassiveBuyer(name: "User 4")]
}

private struct FakePassiveBuyer: PassiveBuyersUser {
    var objectId: String? = nil
    let name: String?
    var avatar: File? = nil

    init(name: String) {
        self.name = name
    }
}


class PassiveBuyersViewModel: BaseViewModel {
    
    weak var delegate: PassiveBuyersViewModelDelegate?

    private let passiveBuyers: PassiveBuyersInfo
    private let passiveBuyersRepository: PassiveBuyersRepository

    //TODO: REMOVE!! JUST TO TEST
    convenience override init() {
        self.init(passiveBuyers: FakePassiveBuyers())
    }

    convenience init(passiveBuyers: PassiveBuyersInfo) {
        self.init(passiveBuyers: passiveBuyers, passiveBuyersRepository: Core.passiveBuyersRepository)
    }

    init(passiveBuyers: PassiveBuyersInfo, passiveBuyersRepository: PassiveBuyersRepository) {
        self.passiveBuyers = passiveBuyers
        self.passiveBuyersRepository = passiveBuyersRepository
    }


    // MARK: - Public info

    var productImage: NSURL? {
        return passiveBuyers.productImage?.fileURL
    }

    var buyersCount: Int {
        return passiveBuyers.passiveBuyers.count
    }

    func buyerImageAtIndex(index: Int) -> NSURL? {
        return buyerAtIndex(index)?.avatar?.fileURL
    }

    func buyerNameAtIndex(index: Int) -> String? {
        return buyerAtIndex(index)?.name
    }


    // MARK: - Actions

    func closeButtonPressed() {
        delegate?.vmDismiss(nil)
    }

    func contactButtonPressed() {
        delegate?.vmShowLoading(nil)
        passiveBuyersRepository.contactAllBuyers(passiveBuyersInfo: passiveBuyers) { [weak self] result in
            if let _ = result.value {
                self?.delegate?.vmHideLoading(LGLocalizedString.passiveBuyersContactSuccess) { [weak self] in
                    self?.delegate?.vmDismiss(nil)
                }
            } else {
                self?.delegate?.vmHideLoading(LGLocalizedString.passiveBuyersContactError, afterMessageCompletion: nil)
            }
        }
    }


    // MARK: - Private

    func buyerAtIndex(index: Int) -> PassiveBuyersUser? {
        guard 0..<passiveBuyers.passiveBuyers.count ~= index else { return nil }
        return passiveBuyers.passiveBuyers[index]
    }
}
