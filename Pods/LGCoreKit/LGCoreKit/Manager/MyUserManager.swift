//
//  MyUserManager.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation
import Parse
import Result

public class MyUserManager {
    
    // Constants
    public static let didReceiveAddressNotification = "MyUserManager.didReceiveAddressNotification"
    
    // iVars
    private var userSignUpService: UserSignUpService
    private var userLogInEmailService: UserLogInEmailService
    private var userLogInFBService: UserLogInFBService
    private var fbUserInfoRetrieveService: FBUserInfoRetrieveService
    private var userLogOutService: UserLogOutService
    
    private var userPasswordResetService: UserPasswordResetService
    
    private var userSaveService: UserSaveService
    private var installationSaveService: InstallationSaveService

    private var postalAddressRetrievalService: PostalAddressRetrievalService
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
        
        self.userPasswordResetService = PAUserPasswordResetService()
        
        self.userSaveService = PAUserSaveService()
        self.installationSaveService = PAInstallationSaveService()
        
        self.postalAddressRetrievalService = CLPostalAddressRetrievalService()
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
        Saves the user if it's new.
    
        :param: result The closure containing the result.
    */
    public func saveMyUserIfNew(result: UserSaveServiceResult) {
        if let myUser = myUser() {
            if !myUser.isSaved {
                userSaveService.saveUser(myUser, result: result)
            }
            else {
                result(Result<User, UserSaveServiceError>.success(myUser))
            }
        }
        else {
            result(Result<User, UserSaveServiceError>.failure(.Internal))
        }
    }
    
    /**
        Saves the given coordinates into the user.
    
        :returns: The task that performs the user save.
    */
    public func saveUserCoordinates(coordinates: CLLocationCoordinate2D, result: SaveUserCoordinatesResult) {
        if let user = myUser() {
            // Set the coordinates & and reset the address
            user.gpsCoordinates = LGLocationCoordinates2D(coordinates: coordinates)
            let address = PostalAddress()
            user.postalAddress = address
            
            // 1. Save it
            saveMyUser { (saveUserResult: Result<User, UserSaveServiceError>) in
                
                // Success
                if let savedUser = saveUserResult.value {
                    
                    // 2. Retrieve the address for the coordinates
                    let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                    self.postalAddressRetrievalService.retrieveAddressForLocation(location) { (postalAddressRetrievalResult: Result<PostalAddress, PostalAddressRetrievalServiceError>) -> Void in
                    
                        // Success
                        if let postalAddress = postalAddressRetrievalResult.value {
                            
                            // 3a. Set the currency code, if any
                            if let countryCode = postalAddress.countryCode {
                                if !countryCode.isEmpty {
                                    CurrencyHelper.sharedInstance.setCountryCode(countryCode)
                                }
                            }
                            
                            // 4. Save the user again
                            self.saveMyUser { (secondSaveUserResult: Result<User, UserSaveServiceError>) in
                                
                                // Success or Error
                                result(Result<CLLocationCoordinate2D, SaveUserCoordinatesError>.success(coordinates))
                            }
                        }
                        // Error
                        else if let postalAddressRetrievalError = postalAddressRetrievalResult.error {
                            result(Result<CLLocationCoordinate2D, SaveUserCoordinatesError>.failure(SaveUserCoordinatesError(postalAddressRetrievalError)))
                        }
                    }
                }
                // Error
                else if let saveUserError = saveUserResult.error {
                    result(Result<CLLocationCoordinate2D, SaveUserCoordinatesError>.failure(SaveUserCoordinatesError(saveUserError)))
                }
            }
        }
        else {
            result(Result<CLLocationCoordinate2D, SaveUserCoordinatesError>.failure(.Internal))
        }
    }
    
    /**
        Saves the installation with the given device token.
        
        :param: deviceToken The APN device token.
    */
    public func saveInstallationDeviceToken(deviceToken: NSData) {
        var installation = myInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installationSaveService.save(installation) { (result: Result<Installation, InstallationSaveServiceError>) in }
    }
    
    /**
        Update the user's avatar with the given image.
    
        :param: image The image.
        :param: result The closure containing the result.
    */
    public func updateAvatarWithImage(image: UIImage, result: FileUploadResult) {
        if let myUser = myUser(), let data = UIImageJPEGRepresentation(image, 0.9) {

            // 1. Upload the picture
            fileUploadService.uploadFile(data) { (fileUploadResult: Result<File, FileUploadServiceError>) in

                // Succeeded
                if let file = fileUploadResult.value {
                
                    // 2. Save the user
                    self.saveMyUser { (userSaveResult: Result<User, UserSaveServiceError>) in
                        
                        // Succeeded
                        if let savedUser = userSaveResult.value {
                            result(Result<File, FileUploadError>.success(file))
                        }
                        // Error
                        else if let saveError = userSaveResult.error {
                            result(Result<File, FileUploadError>.failure(FileUploadError(saveError)))
                        }
                    }
                }
                // Error
                else if let fileUploadError = fileUploadResult.error {
                    result(Result<File, FileUploadError>.failure(FileUploadError(fileUploadError)))
                }
            }
        }
        else {
            result(Result<File, FileUploadError>.failure(.Internal))
        }
    }
    
    // MARK: > Sign up / Log in / Log out
    
    /**
        Signs up a user with the given email, password and public user name.
    
        :param: email The email.
        :param: password The password.
        :param: publicUsername The public user name.
        :param: result The closure containing the result.
    */
    public func signUpWithEmail(email: String, password: String, publicUsername: String, result: UserSignUpServiceResult) {
        userSignUpService.signUpUserWithEmail(email, password: password, publicUsername: publicUsername) { (myResult: Result<Nil, UserSignUpServiceError>) in
            // Succeeded
            if myResult == Result<Nil, UserSignUpServiceError>.success(Nil()) {
                self.setupAfterSessionSuccessful()
            }
            result(myResult)
        }
    }
    
    /**
        Logs in a user with the given email & password.
    
        :param: email The email.
        :param: password The password.
        :param: result The closure containing the result.
    */
    public func logInWithEmail(email: String, password: String, result: UserLogInEmailServiceResult) {
        userLogInEmailService.logInUserWithEmail(email, password: password) { (myResult: Result<User, UserLogInEmailServiceError>) in
            // Succeeded
            if let user = myResult.value {
                self.setupAfterSessionSuccessful()
            }
            result(myResult)
        }
    }
    
    /**
        Logs in a user via Facebook.

        :param: result The closure containing the result.
    */
    public func logInWithFacebook(result: UserLogInFBResult) {
        
        var user: User? = nil
        var fbUserInfo: FBUserInfo? = nil
        
        // 1. Login with Facebook
        userLogInFBService.logInByFacebooWithCompletion { (myResult: Result<User, UserLogInFBServiceError>) in
            
            // Succeeded
            if let user = myResult.value {
                
                // 2. Retrieve the FB Info
                self.fbUserInfoRetrieveService.retrieveFBUserInfo { (fbResult: Result<FBUserInfo, FBUserInfoRetrieveServiceError>) in
                    
                    // Succeeded
                    if let fbUserInfo = fbResult.value {
                        
                        // Set the fields from the graph request
                        let publicUsername: String
                        if let firstName = fbUserInfo.firstName, let lastName = fbUserInfo.lastName {
                            let lastNameInitial: String = count(lastName) > 0 ? lastName.substringToIndex(advance(lastName.startIndex, 1)) : ""
                            publicUsername = "\(firstName) \(lastNameInitial)."
                        }
                        else if let name = fbUserInfo.name {
                            publicUsername = name
                        }
                        else {
                            publicUsername = ""
                        }
                        user.publicUsername = publicUsername
                        
                        // 3. Upload the avatar
                        self.fileUploadService.uploadFile(fbUserInfo.avatarURL) { (uploadResult: Result<File, FileUploadServiceError>) in
                            
                            // Succeeded
                            if let file = uploadResult.value {
                                
                                // 4. Save my user
                                self.saveMyUser { (userSaveResult: Result<User, UserSaveServiceError>) in
                                    
                                    // Succeeded
                                    if let savedUser = userSaveResult.value {
                                        result(Result<User, UserLogInFBError>.success(savedUser))
                                    }
                                    // Error
                                    else if let saveError = userSaveResult.error {
                                        result(Result<User, UserLogInFBError>.failure(UserLogInFBError(saveError)))
                                    }
                                }
                            }
                            // Error
                            else if let uploadError = uploadResult.error {
                                result(Result<User, UserLogInFBError>.failure(UserLogInFBError(uploadError)))
                            }
                        }
                    }
                    // Error
                    else if let fbError = fbResult.error {
                        result(Result<User, UserLogInFBError>.failure(UserLogInFBError(fbError)))
                    }
                }
            }
            // Error
            else if let fbLoginError = myResult.error {
                result(Result<User, UserLogInFBError>.failure(UserLogInFBError(fbLoginError)))
            }
        }
    }
    
    /**
        Logs out my user.
    
        :param: result The closure containing the result.
    */
    public func logout(result: UserLogOutServiceResult) {
        if let myUser = myUser() {
            userLogOutService.logOutUser(myUser) { (myResult: Result<Nil, UserLogOutServiceError>) in
                
                // Notify the callback
                result(Result<Nil, UserLogOutServiceError>.success(Nil()))
                
                // Update my installation in background, unlink userId & username
                if let myUser = self.myUser(), let userId = myUser.objectId, let username = myUser.username {
                    var installation = self.myInstallation()
                    installation.userId = ""
                    installation.username = ""
                    installation.channels = [""]
                    self.installationSaveService.save(installation) { (result: Result<Installation, InstallationSaveServiceError>) in }
                }
            }
        }
        else {
            result(Result<Nil, UserLogOutServiceError>.failure(.Internal))
        }
    }
    
    // MARK: > Password reset
    
    /**
        Resets the password of a my user.
    
        :param: result The closure containing the result.
    */
    public func resetPassword(result: UserPasswordResetServiceResult) {
        if let myUser = myUser() {
            userPasswordResetService.resetPassword(myUser, result: result)
        }
        else {
            result(Result<Nil, UserPasswordResetServiceError>.failure(.Internal))
        }
    }
    
    // MARK: - Private methods
    
    // MARK: > Helper
    
    /**
        Returns the current installation.
    
        :returns: the current installation.
    */
    private func myInstallation() -> Installation {
        return PFInstallation.currentInstallation()
    }
    
    /**
        Runs the setup needed after a session (when signing up or logging in) is successful.
    */
    private func setupAfterSessionSuccessful() {
        // If we already have a location, then save it into my user
        if let lastKnownLocation = LocationManager.sharedInstance.lastKnownLocation {
            saveUserCoordinates(lastKnownLocation.coordinate) { (result: Result<CLLocationCoordinate2D, SaveUserCoordinatesError>) in }
        }
        
        // If the user had already a country code, then set it in the currency helper
        if let user = MyUserManager.sharedInstance.myUser(), let countryCode = user.postalAddress.countryCode {
            CurrencyHelper.sharedInstance.setCountryCode(countryCode)
        }

        // Update my installation
        if let myUser = myUser(), let userId = myUser.objectId, let username = myUser.username {
            var installation = myInstallation()
            installation.userId = userId
            installation.username = username
            installation.channels = [""]
            installationSaveService.save(installation) { (result: Result<Installation, InstallationSaveServiceError>) in }
        }
    }
    
    // MARK: > Tasks
    
    // MARK: >> My User
    
    /**
        Saves my user.
    
        :param: result The closure containing the result.
    */
    private func saveMyUser(result: UserSaveServiceResult) {
        if let myUser = myUser() {
            userSaveService.saveUser(myUser, result: result)
        }
        else {
            result(Result<User, UserSaveServiceError>.failure(.Internal))
        }
    }
    
    
    // MARK: > NSNotificationCenter
    
    @objc private func didReceiveLocationWithNotification(notification: NSNotification) {
        if let location = notification.object as? CLLocation {
            saveUserCoordinates(location.coordinate) { (result: Result<CLLocationCoordinate2D, SaveUserCoordinatesError>) in }
        }
    }
}