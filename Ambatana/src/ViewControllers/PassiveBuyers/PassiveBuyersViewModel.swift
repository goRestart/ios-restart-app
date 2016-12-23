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
    var passiveBuyers: [PassiveBuyersUser] = []
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

    }


    // MARK: - Private

    func buyerAtIndex(index: Int) -> PassiveBuyersUser? {
        guard 0..<passiveBuyers.passiveBuyers.count ~= index else { return nil }
        return passiveBuyers.passiveBuyers[index]
    }
}
