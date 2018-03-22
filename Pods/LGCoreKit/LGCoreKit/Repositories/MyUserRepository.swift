//
//  MyUserRepository.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Result
import RxSwift

public typealias MyUserResult = Result<MyUser, RepositoryError>
public typealias MyUserCompletion = (MyUserResult) -> Void

public protocol MyUserRepository {

    /**
    Returns the logged user.
    */
    var myUser: MyUser? { get }
    var rx_myUser: Observable<MyUser?> { get }


    /**
    Updates the name of my user.
    - parameter myUserId: My user identifier.
    - parameter name: The name.
    - parameter completion: The completion closure.
    */
    func updateName(_ name: String, completion: MyUserCompletion?)

    /**
    Updates the password of my user.
    - parameter myUserId: My user identifier.
    - parameter password: The password.
    - parameter completion: The completion closure.
    */
    func updatePassword(_ password: String, completion: MyUserCompletion?)
    
    /**
    Updates the password of the given userId using the given token as Authentication
    
    - parameter password:   New password
    - parameter token:      Token to be used as Authentication
    - parameter completion: Completion closure
    */
    func resetPassword(_ password: String, token: String, completion: MyUserCompletion?)
    
    /**
    Updates the email of my user.
    - parameter myUserId: My user identifier.
    - parameter email: The email.
    - parameter completion: The completion closure.
    */
    func updateEmail(_ email: String, completion: MyUserCompletion?)

    /**
    Updates the avatar of my user.
    - parameter avatar: The avatar.
    - parameter completion: The completion closure.
    */
    func updateAvatar(_ avatar: Data, progressBlock: ((Int) -> ())?, completion: MyUserCompletion?)

    /**
     Updates the biography of my user.
     - parameter biography: The new biography text
     - parameter completion: The completion closure
     */
    func updateBiography(_ biography: String, completion: MyUserCompletion?)

    /**
     Links an email account with the logged in user

     - parameter email:      email to be linked
     - parameter completion: completion closure
     */
    func linkAccount(_ email: String, completion: MyUserCompletion?)

    /**
     Links a facebook account with the logged in user

     - parameter email:      facebook token of the account to be linked
     - parameter completion: completion closure
     */
    func linkAccountFacebook(_ token: String, completion: MyUserCompletion?)

    /**
     Links a google account with the logged in user

     - parameter email:      google token of the account to be linked
     - parameter completion: completion closure
     */
    func linkAccountGoogle(_ token: String, completion: MyUserCompletion?)

    /**
    Refreshes my user. (retrieves again the logged in user)
    - parameter completion: The completion closure.
    */
    func refresh(_ completion: MyUserCompletion?)
}


protocol InternalMyUserRepository: MyUserRepository {

    /**
     Creates a `MyUser` with the given credentials, public user name and location.
     - parameter email: The email.
     - parameter password: The password.
     - parameter name: The name.
     - parameter newsletter: Whether or not the user accepted newsletter sending. Send to nil if user wasn't asked about it
     - parameter location: The location.
     - parameter postalAddress: The postal address.
     - parameter completion: The completion closure. Will pass api error as the method is internal so that the caller can
     have the complete error information
     */
    func createWithEmail(_ email: String, password: String, name: String, newsletter: Bool?, location: LGLocation?,
                         postalAddress: PostalAddress?, completion: ((Result<MyUser, ApiError>) -> ())?)

    /**
     Retrieves my user.
     - parameter myUserId: My user identifier.
     - parameter completion: The completion closure.
     */
    func show(_ myUserId: String, completion: MyUserCompletion?)

    /**
     Updates the user if the locale changed.
     - returns: If the update was performed.
     */
    @discardableResult func updateIfLocaleChanged() -> Bool

    /**
     Updates the location of my user. If no postal address is passed-by it nullifies it.
     - parameter location: The location.
     - parameter completion: The completion closure.
     */
    func updateLocation(_ location: LGLocation, completion: MyUserCompletion?)

    /**
     Saves the given `MyUser`.
     - parameter myUser: My user.
     */
    func save(_ myUser: MyUser)

    /**
     Deletes the user.
     */
    func deleteUser()
}
