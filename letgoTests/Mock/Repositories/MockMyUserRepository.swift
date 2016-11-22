//
//  MockUserRepository.swift
//  LetGo
//
//  Created by Eli Kohen on 21/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import Foundation
import RxSwift

class MockMyUserRepository: MyUserRepository {

    var myUserResult: MyUserResult?


    var myUser: MyUser? {
        return myUserVar.value
    }
    var rx_myUser: Observable<MyUser?> {
        return myUserVar.asObservable()
    }

    let myUserVar = Variable<MyUser?>(nil)

    func updateName(name: String, completion: MyUserCompletion?) {
        performAfterDelayWithCompletion(completion, result: myUserResult)
    }

    func updatePassword(password: String, completion: MyUserCompletion?) {
        performAfterDelayWithCompletion(completion, result: myUserResult)
    }

    func resetPassword(password: String, token: String, completion: MyUserCompletion?) {
        performAfterDelayWithCompletion(completion, result: myUserResult)
    }

    func updateEmail(email: String, completion: MyUserCompletion?) {
        performAfterDelayWithCompletion(completion, result: myUserResult)
    }

    func updateAvatar(avatar: NSData, progressBlock: ((Int) -> ())?, completion: MyUserCompletion?) {
        performAfterDelayWithCompletion(completion, result: myUserResult)
    }

    func linkAccount(email: String, completion: MyUserCompletion?) {
        performAfterDelayWithCompletion(completion, result: myUserResult)
    }

    func linkAccountFacebook(token: String, completion: MyUserCompletion?) {
        performAfterDelayWithCompletion(completion, result: myUserResult)
    }

    func linkAccountGoogle(token: String, completion: MyUserCompletion?) {
        performAfterDelayWithCompletion(completion, result: myUserResult)
    }

    func refresh(completion: MyUserCompletion?) {
        performAfterDelayWithCompletion(completion, result: myUserResult)
    }
}
