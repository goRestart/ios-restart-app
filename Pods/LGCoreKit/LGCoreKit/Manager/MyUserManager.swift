//
//  MyUserManager.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Bolts
import CoreLocation
import Parse

public class MyUserManager {
    
    // Constants
    public static let didReceiveAddressNotification = "MyUserManager.didReceiveAddressNotification"
    
    // iVars
    private var userSignUpService: UserSignUpService
    private var userLogInEmailService: UserLogInEmailService
    private var userLogInFBService: UserLogInFBService
    private var fbUserInfoRetrieveService: FBUserInfoRetrieveService
    private var userLogOutService: UserLogOutService
    
    private var userSaveService: UserSaveService
    private var installationSaveService: InstallationSaveService

    private var postalAddressRetrivalService: PostalAddressRetrievalService
    private var fileUploadService: FileUploadService
    
    // Singleton
    public static let sharedInstance: MyUserManager = MyUserManager()
    
    // MARK: - Lifecycle
    
    // FIXME: Refactor this to be initialized with a builder
    public init() {
        
        // Services
        self.userSignUpService = PAUserSignUpService()
        self.userLogInEmailService = PAUserLogInEmailService()
        self.userLogInFBService = PAUserLogInFBService()
        self.fbUserInfoRetrieveService = FBUserInfoRetrieveService()
        self.userLogOutService = PAUserLogOutService()
        
        self.userSaveService = PAUserSaveService()
        self.installationSaveService = PAInstallationSaveService()
        
        self.postalAddressRetrivalService = CLPostalAddressRetrievalService()
        self.fileUploadService = PAFileUploadService()
        
        // Start observing location changes
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveLocationWithNotification:", name: LocationManager.didReceiveLocationNotification, object: nil)
    }
    
    deinit {
        // Stop observing
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    // MARK: - Public methods
    
    // MARK: > My User
    
    /**
        Returns the current user.
    
        :returns: the current user.
    */
    public func myUser() -> User? {
        return PFUser.currentUser()
    }
    
    /**
        Returns if the current user is anonymous.
    
        :returns: if the current user is anonymous.
    */
    public func isMyUserAnonymous() -> Bool {
        if let myUser = myUser() {
            return myUser.isAnonymous
        }
        return true
    }
    
    /**
        Saves the user.
    
        :param: user The user.
        :param: completion The completion closure.
        :returns: The task that performs the user save.
    */
    public func saveUser(user: User, completion: UserSaveCompletion) {
        userSaveService.saveUser(user, completion: completion)
    }
    
    /**
        Saves the user if it's new.
    
        :returns: The task that performs the user save.
    */
    public func saveUserIfNew() -> BFTask {
        if let myUser = myUser() {
            if !myUser.isSaved {
                return save(myUser)
            }
        }
        
        return BFTask(error: NSError(code: LGErrorCode.Internal))
    }
    
    /**
        Saves the given coordinates into the user.
    
        :returns: The task that performs the user save.
    */
    public func saveUserCoordinates(coordinates: CLLocationCoordinate2D) -> BFTask {
        if let user = myUser() {
            // Set the coordinates & and reset the address
            user.gpsCoordinates = LGLocationCoordinates2D(coordinates: coordinates)
            let address = PostalAddress()
            user.postalAddress = address
            
            // Save it
            save(user).continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
                
                // Retrieve the address for the coordinates
                return self.retrieveAddressForLocation(CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude))
                
            }.continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
                let postalAddress = task.result as! PostalAddress
                user.postalAddress = postalAddress
                
                // If we know the country code, then notify the CurrencyHelper
                if let countryCode = postalAddress.countryCode {
                    if !countryCode.isEmpty {
                        CurrencyHelper.sharedInstance.setCountryCode(countryCode)
                    }
                }
                
                // Save the user again
                return self.save(user)
            }
        }
        return BFTask(error: NSError(code: LGErrorCode.Internal))
    }
    
    /**
        Update the user's avatar with the given image.
    
        :param: image The image.
        :param: completion The completion closure.
    */
    public func updateAvatarWithImage(image: UIImage, completion: FileUploadCompletion) {
        
        var file: File?
        
        if let myUser = myUser(), let data = UIImageJPEGRepresentation(image, 0.9) {
            uploadFileWithData(data).continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
                file = task.result as? File
                myUser.avatar = file
                return self.save(myUser)
            }.continueWithBlock { (task: BFTask!) -> AnyObject! in
                completion(file: file, error: task.error)
                return nil
            }
        }
        else {
            completion(file: nil, error: NSError(code: LGErrorCode.Internal))
        }
    }
    
    // MARK: > Log in / Log out / Sign up
    
    /**
        Signs up a user with the given email, password and public user name.
    
        :param: email The email.
        :param: password The password.
        :param: publicUsername The public user name.
        :param: completion The completion closure.
    */
    public func signUpWithEmail(email: String, password: String, publicUsername: String, completion: UserSignUpCompletion) {
        
        signUpWithEmail(email, password: password, publicUsername: publicUsername).continueWithBlock { (task: BFTask!) -> AnyObject! in
 
            let succeeded = task.error == nil
            
            if succeeded {
                self.setupAfterSessionSuccessful()
            }
            
            completion(success: succeeded, error: task.error)
            
            return nil
        }
    }
    
    /**
        Logs in a user with the given email & password.
    
        :param: email The email.
        :param: password The password.
        :param: completion The completion closure.
    */
    public func logInWithEmail(email: String, password: String, completion: UserLogInCompletion) {
        
        logInWithEmail(email, password: password).continueWithBlock { (task: BFTask!) -> AnyObject! in
            let user = task.result as? User
            let error = task.error
            let succeeded = error == nil
            
            if succeeded {
                self.setupAfterSessionSuccessful()
            }
            completion(user: user, error: error)
            return nil
        }
    }
    
    /**
        Logs in a user via Facebook.

        :param: completion The completion closure.
    */
    public func logInWithFacebook(completion: UserLogInCompletion) {
        
        var user: User? = nil
        var fbUserInfo: FBUserInfo? = nil
        
        // Login with Facebook
        logInWithFacebook().continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in

            // Keep track of the user and retrieve the FB user info (graph)
            user = task.result as? User
            return self.retrieveFBUserInfo()
            
        }.continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
            fbUserInfo = task.result as? FBUserInfo
            
            // Set the fields from the graph request
            if let actualUser = user, let actualFBUserInfo = fbUserInfo {
                let publicUsername: String
                if let firstName = actualFBUserInfo.firstName, let lastName = actualFBUserInfo.lastName {
                    let lastNameInitial: String = count(lastName) > 0 ? lastName.substringToIndex(advance(lastName.startIndex, 1)) : ""
                    publicUsername = "\(firstName) \(lastNameInitial)."
                }
                else if let name = fbUserInfo?.name {
                    publicUsername = name
                }
                else {
                    publicUsername = ""
                }
                actualUser.publicUsername = publicUsername
                
                // Retrieve the user's avatar
                return self.uploadFileWithDataAtURL(actualFBUserInfo.avatarURL)
            }
            else {
                return BFTask(error: NSError(code: LGErrorCode.Internal))
            }
        }.continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
            
            // Set the picture into the user
            let actualUser = user!
            actualUser.avatar = task.result as? File
            
            // Save the user
            return self.save(actualUser)
            
        }.continueWithBlock { (task: BFTask!) -> AnyObject! in
            
            // An error happened in the whole process
            if let actualError = task.error {
                completion(user: nil, error: actualError)
            }
            // Everything is OK
            else if let actualUser = task.result as? User {
                self.setupAfterSessionSuccessful()
                completion(user: actualUser, error: nil)
            }
            else {
                completion(user: nil, error: NSError(code: LGErrorCode.Internal))
            }
            return nil
        }
    }
    
    /**
        Logs out a user.
    
        :param: completion The completion closure.
    */
    public func logout(completion: UserLogOutCompletion) {
        logout().continueWithBlock{ (task: BFTask!) -> AnyObject! in
            let succeeded = task.error == nil
            completion(success: succeeded, error: task.error)
            return nil
        }
    }
    
    // MARK: - Private methods
    
    // MARK: > Helper
    
    /**
        Runs the setup needed after a session (when signing up or logging in) is successful.
    */
    private func setupAfterSessionSuccessful() {
        // If we already have a location, then save it into my user
        if let lastKnownLocation = LocationManager.sharedInstance.lastKnownLocation {
            saveUserCoordinates(lastKnownLocation.coordinate)
        }
        
        // If the user had already a country code, then set it in the currency helper
        if let user = MyUserManager.sharedInstance.myUser(), let countryCode = user.postalAddress.countryCode {
            CurrencyHelper.sharedInstance.setCountryCode(countryCode)
        }

        // Update my installation
        if let myUser = myUser() {
            var installation = myInstallation()
            installation.userId = myUser.objectId
            installation.username = myUser.username
            save(installation)
        }
    }
    
    /**
        Returns the current installation.
        
        :returns: the current installation.
    */
    private func myInstallation() -> Installation {
        return PFInstallation.currentInstallation()
    }
    
    // MARK: > Tasks
    
    // MARK: >> My User
    
    private func saveLocationAndRetrieveAddress(location: CLLocation) -> BFTask {
        if let user = myUser() {
            // Save the received location and erase previous postal address data, if any
            user.gpsCoordinates = LGLocationCoordinates2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let address = PostalAddress()
            user.postalAddress = address
            save(user)
            
            // Then, retrieve the address for the received location
            return retrieveAddressForLocation(location).continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
                if let postalAddress = task.result as? PostalAddress {
                    user.postalAddress = postalAddress
                    
                    // If we know the country code, then notify the CurrencyHelper
                    if let countryCode = postalAddress.countryCode {
                        if !countryCode.isEmpty {
                            CurrencyHelper.sharedInstance.setCountryCode(countryCode)
                        }
                    }
                    
                    // Save the user again
                    return self.save(user)
                }
                return nil
            }
        }
        return BFTask(error: NSError(code: LGErrorCode.Internal))
    }
    
    // MARK: >> Sign up / Log in / Log out
    
    private func signUpWithEmail(email: String, password: String, publicUsername: String) -> BFTask {
        var task = BFTaskCompletionSource()
        userSignUpService.signUpUserWithEmail(email, password: password, publicUsername: publicUsername) { (success: Bool, error: NSError?) in
            if let actualError = error {
                task.setError(error)
            }
            else if success {
                task.setResult(success)
            }
            else {
                task.setError(NSError(code: LGErrorCode.Internal))
            }
        }
        return task.task
    }

    private func logInWithEmail(email: String, password: String) -> BFTask {
        var task = BFTaskCompletionSource()
        userLogInEmailService.logInUserWithEmail(email, password: password) { (user: User?, error: NSError?) in
            if let actualError = error {
                task.setError(error)
            }
            else if let actualUser = user {
                task.setResult(actualUser)
            }
            else {
                task.setError(NSError(code: LGErrorCode.Internal))
            }
        }
        return task.task
    }
    
    private func logInWithFacebook() -> BFTask {
        var task = BFTaskCompletionSource()
        userLogInFBService.logInByFacebooWithCompletion { (user: User?, error: NSError?) in
            if let actualError = error {
                task.setError(error)
            }
            else if let actualUser = user {
                task.setResult(actualUser)
            }
            else {
                task.setError(NSError(code: LGErrorCode.Internal))
            }
            
        }
        return task.task
    }
    
    private func logout() -> BFTask {
        var task = BFTaskCompletionSource()
        userLogOutService.logOutWithCompletion { (success: Bool, error: NSError?) in
            if let actualError = error {
                task.setError(error)
            }
            else if success {
                task.setResult(success)
            }
            else {
                task.setError(NSError(code: LGErrorCode.Internal))
            }
            
        }
        return task.task
    }
    
    private func retrieveFBUserInfo() -> BFTask {
        var task = BFTaskCompletionSource()
        fbUserInfoRetrieveService.retrieveFBUserInfo() { (userInfo: FBUserInfo?, error: NSError?) in
            if let actualError = error {
                task.setError(error)
            }
            else if let actualUserInfo = userInfo {
                task.setResult(actualUserInfo)
            }
            else {
                task.setError(NSError(code: LGErrorCode.Internal))
            }
        }
        return task.task
    }
    
    // MARK: >> Avatar upload
    
    private func uploadFileWithData(data: NSData) -> BFTask {
        var task = BFTaskCompletionSource()
        
        fileUploadService.uploadFile(data) { (file: File?, error: NSError?) -> Void in
            if let actualError = error {
                task.setError(actualError)
            }
            else if let actualFile = file {
                task.setResult(actualFile)
            }
            else {
                task.setError(NSError(code: LGErrorCode.Internal))
            }
        }
        return task.task
    }
    
    private func uploadFileWithDataAtURL(url: NSURL) -> BFTask {
        var task = BFTaskCompletionSource()
        
        fileUploadService.uploadFile(url)  { (file: File?, error: NSError?) -> Void in
            if let actualError = error {
                task.setError(actualError)
            }
            else if let actualFile = file {
                task.setResult(actualFile)
            }
            else {
                task.setError(NSError(code: LGErrorCode.Internal))
            }
        }
        return task.task
    }
    
    // MARK: >> User
    
    public func save(user: User) -> BFTask {
        var task = BFTaskCompletionSource()
        
        userSaveService.saveUser(user) { (success: Bool, error: NSError?) -> Void in
            if let actualError = error {
                task.setError(actualError)
            }
            else {
                task.setResult(success)
            }
        }
        return task.task
    }
    
    // MARK: >> Installation
    
    private func save(installation: Installation) -> BFTask {
        var task = BFTaskCompletionSource()
        
        installationSaveService.save(installation) { (success: Bool, error: NSError?) -> Void in
            if let actualError = error {
                task.setError(actualError)
            }
            else {
                task.setResult(success)
            }
        }
        return task.task
    }
    
    // MARK: >> Address & location
    
    private func retrieveAddressForLocation(location: CLLocation) -> BFTask {
        var task = BFTaskCompletionSource()
        postalAddressRetrivalService.retrieveAddressForLocation(location) { (address: PostalAddress?, error: NSError?) in
            if let actualError = error {
                task.setError(error)
            }
            else if let actualAddress = address {
                task.setResult(actualAddress)
            }
        }
        return task.task
    }
    
    // MARK: > NSNotificationCenter
    
    @objc private func didReceiveLocationWithNotification(notification: NSNotification) {

        if let location = notification.object as? CLLocation {
            saveLocationAndRetrieveAddress(location)
        }
    }
}