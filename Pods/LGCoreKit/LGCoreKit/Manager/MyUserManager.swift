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

public class MyUserManager: LocationManagerDelegate {
    
    // Constants & enum
    public enum Notification: String {
        case login = "MyUserManager.login"
        case logout = "MyUserManager.logout"
        case locationUpdate = "MyUserManager.locationUpdate"
        case didMoveFromManualLocationNotification = "MyUserManager.didMoveFromManualLocationNotification"
    }
    
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
    
    public var profileLocationInfo : String? {
        return myUser()?.postalAddress.city ?? myUser()?.postalAddress.countryCode
    }
    
    private var locationManager: LocationManager
    private var userDefaultsManager: UserDefaultsManager
    
    public var locationServiceStatus: LocationServiceStatus {
        return locationManager.locationServiceStatus
    }

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
        
        self.locationManager = LocationManager()
        self.userDefaultsManager = UserDefaultsManager.sharedInstance
        
        // Setup
        self.locationManager.delegate = self
        
        // > If location was manual set it up at location manager
        if let myUserId = PFUser.currentUser()?.objectId {
            let userDefaultManager = UserDefaultsManager.sharedInstance           
            if userDefaultManager.loadIsManualLocationForUser(myUserId) {
                if let location = userDefaultManager.loadManualLocationForUser(myUserId) {
                    locationManager.manualLocation = LGLocation(location: location, type: .Manual)
                }
            }
        }
        
        // Set currency
        if let countryCode = myUser()?.postalAddress.countryCode {
            CurrencyHelper.sharedInstance.setCountryCode(countryCode)
        }
    }
    
    // MARK: - Public methods
    
    // MARK: > My User
    
    /**
        Returns the current user.
    
        - returns: the current user.
    */
    public func myUser() -> MyUser? {
        return PFUser.currentUser()
    }
    
    /**
        Returns if the current user is anonymous.
    
        - returns: if the current user is anonymous.
    */
    public func isMyUserAnonymous() -> Bool {
        if let myUser = myUser() {
            return myUser.isAnonymous
        }
        return true
    }
    
    /**
    Factory method. Will build a new contact from the provided product. Will use myUser as 'userFrom'.
    
    - returns: Contact in case myUser and product.user have values. nil otherwise
    */
    public func newContactWithEmail(email: String, title: String, message: String) -> Contact {
        return LGContact(email: email, title: title, message: message)
    }

    
    /**
        Saves the user if it's new.
    
        - parameter result: The closure containing the result.
    */
    public func saveMyUserIfNew(completion: UserSaveServiceCompletion?) {
        if let myUser = myUser() {
            if !myUser.isSaved {
                userSaveService.saveUser(myUser) { [weak self] (myResult: UserSaveServiceResult) in
                    completion?(myResult)

                    // Save my installation
                    if let installation = self?.myInstallation() {
                        if let userId = myUser.objectId {
                            installation.userId = userId
                        }
                        self?.installationSaveService.save(installation, completion: nil)
                    }
                }
            }
            else {
                completion?(UserSaveServiceResult(value: myUser))
            }
        }
        else {
            completion?(UserSaveServiceResult(error: .Internal))
        }
    }
    
    /**
        Saves the installation with the given device token.
        
        - parameter deviceToken: The APN device token.
    */
    public func saveInstallationDeviceToken(deviceToken: NSData) {
        let installation = myInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installationSaveService.save(installation, completion: nil)
    }
    
    /**
        Update the user's avatar with the given image.
    
        - parameter image: The image.
        - parameter result: The closure containing the result.
    */
    public func updateAvatarWithImage(image: UIImage, completion: FileUploadCompletion?) {
        if let myUser = myUser(), let myUserId = myUser.objectId, let sessionToken = myUser.sessionToken, let data = UIImageJPEGRepresentation(image, 0.9) {

            // 1. Upload the picture
            fileUploadService.uploadFileWithUserId(myUserId, sessionToken: sessionToken, data: data) { (fileUploadResult: FileUploadServiceResult) in

                // Succeeded
                if let file = fileUploadResult.value {
                
                    // 2a. Set the user's avatar & mark as non-processed
                    myUser.avatar = file
                    myUser.processed = NSNumber(bool: false)
                    
                    // 2b. Save the user
                    self.saveMyUser { (userSaveResult: UserSaveServiceResult) in
                        
                        // Succeeded
                        if let _ = userSaveResult.value {
                            completion?(FileUploadResult(value: file))
                        }
                        // Error
                        else if let saveError = userSaveResult.error {
                            completion?(FileUploadResult(error: FileUploadError(saveError)))
                        }
                    }
                }
                // Error
                else if let fileUploadError = fileUploadResult.error {
                    completion?(FileUploadResult(error: FileUploadError(fileUploadError)))
                }
            }
        }
        else {
            completion?(FileUploadResult(error: .Internal))
        }
    }
    
    /**
        Updates my usename.
    
        - parameter username: The username.
        - parameter result: The closure containing the result.
    */
    public func updateUsername(username: String, completion: UserSaveServiceCompletion?) {
        if let myUser = myUser() {
            myUser.publicUsername = username
            myUser.processed = NSNumber(bool: false)
            saveMyUser(completion)
        }
        else {
            completion?(UserSaveServiceResult(error: .Internal))
        }
    }
    
    /**
        Updates my user password.
    
        - parameter password: The password.
        - parameter result: The closure containing the result.
    */
    public func updatePassword(password: String, completion: UserSaveServiceCompletion?) {
        if let myUser = myUser() {
            myUser.password = password
            myUser.processed = NSNumber(bool: false)
            saveMyUser(completion)
        }
        else {
            completion?(UserSaveServiceResult(error: .Internal))
        }
    }
    
    /**
        Updates my user email.
    
        - parameter email: The email.
        - parameter result: The closure containing the result.
    */
    public func updateEmail(email: String, completion: UserSaveServiceCompletion?) {
        if let myUser = myUser() {
            myUser.email = email
            myUser.processed = NSNumber(bool: false)
            saveMyUser(completion)
        }
        else {
            completion?(UserSaveServiceResult(error: .Internal))
        }
    }
    
    // MARK: > Location
    
    /**
        Asks location manager to start sensor updates
    */
    public func startSensorLocationUpdates() {
        locationManager.startSensorLocationUpdates()
    }

    /**
        Asks location manager to stop sensor updates
    */
    public func stopSensorLocationUpdates() {
        locationManager.stopSensorLocationUpdates()
    }

    /**
        Returns the current location. Prio: manual, sensor, last saved (into user @ backend), ip lookup, regional
    */
    public var currentLocation: LGLocation? {
        if let location = locationManager.currentLocation {
            switch location.type {
            case .Manual, .Sensor, .LastSaved:
                return location
            case .IPLookup, .Regional:
                if let coords = myUser()?.gpsCoordinates {
                    let location = CLLocation(latitude: coords.latitude, longitude: coords.longitude)
                    return LGLocation(location: location, type: .LastSaved)
                }
                else {
                    return location
                }
            }
        }
        return nil
    }
    
    /**
        Returns the auto current location. Prio: sensor, ip lookup, regional
    */
    public var currentAutoLocation: LGLocation? {
        return locationManager.currentAutoLocation
    }
    
    /**
        Sets manual location with the given location and place.
    
        - parameter location: The location.
        - parameter place: The place.
    */
    public func setManualLocation(location: CLLocation, place: Place) {
        // Save location & place into the user
        let manualLocation = LGLocation(location: location, type: .Manual)
        saveCoordinates(manualLocation, place: place, completion: nil)
        
        // Save manual location into user defaults
        userDefaultsManager.saveIsManualLocation(true)
        userDefaultsManager.saveManualLocation(location)
        
        // Notify location manager
        locationManager.manualLocation = manualLocation
        
        // Notify the listeners
        NSNotificationCenter.defaultCenter().postNotificationName(Notification.locationUpdate.rawValue, object: manualLocation)
    }
    
    /**
        Sets automatic location associating the current location with the given place.
        
        - parameter place: The place.
    */
    public func setAutomaticLocationWithPlace(place: Place?) {
        // Notify location manager (so, location retrieve is guaranteed to be automatic (sensor, iplookup or regional)
        locationManager.manualLocation = nil
        
        // Save automatic location into user defaults
        userDefaultsManager.saveIsManualLocation(false)
        
        // If we've a current auto location then save it
        if let location = locationManager.currentLocation {
            saveCoordinates(location, place: place, completion: nil)
            // Notify the listeners
            NSNotificationCenter.defaultCenter().postNotificationName(Notification.locationUpdate.rawValue, object: location)
        }
    }
    
    // MARK: > Sign up / Log in / Log out
    
    /**
        Signs up a user with the given email, password and public user name.
    
        - parameter email: The email.
        - parameter password: The password.
        - parameter publicUsername: The public user name.
        - parameter result: The closure containing the result.
    */
    public func signUpWithEmail(email: String, password: String, publicUsername: String, completion: UserSignUpServiceCompletion?) {
        userSignUpService.signUpUserWithEmail(email, password: password, publicUsername: publicUsername) { (myResult: UserSignUpServiceResult) in
            // Succeeded
            if myResult == UserSignUpServiceResult(value: Nil()) {
                self.setupAfterSessionSuccessful()
            }
            completion?(myResult)
        }
    }
    
    /**
        Logs in a user with the given email & password.
    
        - parameter email: The email.
        - parameter password: The password.
        - parameter result: The closure containing the result.
    */
    public func logInWithEmail(email: String, password: String, completion: UserLogInEmailServiceCompletion?) {
        // 1. Login
        userLogInEmailService.logInUserWithEmail(email, password: password) { (myResult: UserLogInEmailServiceResult) in
            // Succeeded
            if let user = myResult.value {
                var isScammerUser: Bool = false
                if let isScammer = user.isScammer?.boolValue {
                    isScammerUser = isScammer
                }
                
                // 2a. If scammer then logout & notify
                if isScammerUser {
                    self.userLogOutService.logOutUser(user) { (logoutResult: UserLogOutServiceResult) -> Void in
                        completion?(UserLogInEmailServiceResult(error: .Forbidden))
                    }
                }
                // 2b. Otherwise it's a regular user, we're done
                else {
                    self.setupAfterSessionSuccessful()
                    completion?(myResult)
                }
            }
            // Error
            else {
                completion?(myResult)
            }
        }
    }
    
    /**
        Logs in a user via Facebook.

        - parameter result: The closure containing the result.
    */
    public func logInWithFacebook(completion: UserLogInFBCompletion?) {

        // 1. Login with Facebook
        userLogInFBService.logInByFacebooWithCompletion { (myResult: UserLogInFBServiceResult) in
            
            // Succeeded
            if let user = myResult.value, let _ = user.objectId {
                
                var isScammerUser: Bool = false
                if let isScammer = user.isScammer?.boolValue {
                    isScammerUser = isScammer
                }
                
                // 2a. If scammer then logout & notify
                if isScammerUser {
                    self.userLogOutService.logOutUser(user) { (logoutResult: UserLogOutServiceResult) -> Void in
                        completion?(UserLogInFBResult(error: .Forbidden))
                    }
                }
                // 2b. Otherwise it's a regular user, then retrieve the FB info
                else {
                    // 3. Retrieve the FB Info
                    self.fbUserInfoRetrieveService.retrieveFBUserInfoWithCompletion { (fbResult: FBUserInfoRetrieveServiceResult) in
                        
                        // Succeeded
                        if let fbUserInfo = fbResult.value {
                            
                            // Set the fields from the graph request
                            let publicUsername: String
                            
                            if let firstName = fbUserInfo.firstName, let lastName = fbUserInfo.lastName {
                                let lastNameInitial: String = lastName.characters.count > 0 ? lastName.substringToIndex(lastName.startIndex.advancedBy(1)) : ""
                                publicUsername = "\(firstName) \(lastNameInitial)."
                            }
                            else if let name = fbUserInfo.name {
                                publicUsername = name
                            }
                            else {
                                publicUsername = ""
                            }
                            user.email = fbUserInfo.email
                            user.publicUsername = publicUsername
                            user.processed = NSNumber(bool: false)
                            
                            // 4. Save my user
                            self.saveMyUser { (userSaveResult: UserSaveServiceResult) in
                                
                                // Succeeded
                                if let savedUser = userSaveResult.value, let sessionToken = savedUser.sessionToken, let userId = savedUser.objectId {
                                    
                                    // 5. Upload the avatar
                                    self.fileUploadService.uploadFileWithUserId(userId, sessionToken: sessionToken, sourceURL: fbUserInfo.avatarURL) { (uploadResult: Result<File, FileUploadServiceError>) in
                                        
                                        // Succeeded
                                        if let file = uploadResult.value {
                                            
                                            // 6. Set the user's avatar & mark as non-processed
                                            savedUser.avatar = file
                                            savedUser.processed = NSNumber(bool: false)
                                            
                                            // 7. Save my user again
                                            self.saveMyUser { (userSaveResult: UserSaveServiceResult) in
                                                
                                                // Success or Error, but in case of error report success as avatar is not strictly necessary
                                                let savedUser = userSaveResult.value ?? user
                                                
                                                self.setupAfterSessionSuccessful()
                                                completion?(UserLogInFBResult(value: savedUser))
                                            }
                                        }
                                        // Error, but report success as avatar is not strictly necessary
                                        else if let _ = uploadResult.error {
                                            
                                            self.setupAfterSessionSuccessful()
                                            completion?(UserLogInFBResult(value: user))
                                        }
                                    }
                                }
                                // Error, then logout & report it as the user could not be saved (i.e.: EmailTaken)
                                else if let saveUserError = userSaveResult.error {
                                    self.logout(nil)
                                    completion?(UserLogInFBResult(error: UserLogInFBError(saveUserError)))
                                }
                            }
                        }
                        // Error, then logout & report it as the info couldn't be loaded
                        else if let fbError = fbResult.error {
                            self.logout(nil)
                            completion?(UserLogInFBResult(error: UserLogInFBError(fbError)))
                        }
                    }
                }
            }
            // Error, then report it
            else if let fbLoginError = myResult.error {
                completion?(UserLogInFBResult(error: UserLogInFBError(fbLoginError)))
            }
        }
    }
    
    /**
        Logs out my user.
    
        - parameter result: The closure containing the result.
    */
    public func logout(completion: UserLogOutServiceCompletion?) {
        if let myUser = myUser() {

            // Notify location manager that there's no manual location
            locationManager.manualLocation = nil
            
            // Logout
            userLogOutService.logOutUser(myUser) { (myResult: UserLogOutServiceResult) in
                
                // Notify the callback
                completion?(UserLogOutServiceResult(value: Nil()))
                
                // Update my installation in background, unlink userId & username
                let installation = self.myInstallation()
                installation.userId = self.myUser()?.objectId ?? ""
                installation.username = self.myUser()?.username ?? ""
                installation.channels = [""]
                self.installationSaveService.save(installation) { (result: Result<Installation, InstallationSaveServiceError>) in }
            }
            
            // Notify
            NSNotificationCenter.defaultCenter().postNotificationName(Notification.logout.rawValue, object: nil)
        }
        else {
            completion?(UserLogOutServiceResult(error: .Internal))
        }
    }
    
    // MARK: > Password reset
    
    /**
        Resets the password of a my user.
    
        - parameter email: The user email.
        - parameter result: The closure containing the result.
    */
    public func resetPassword(email: String, completion: UserPasswordResetServiceCompletion?) {
        userPasswordResetService.resetPassword(email, completion: completion)
    }
    
    // MARK: - LocationManagerDelegate
    
    func locationManager(locationManager: LocationManager, didUpdateAutoLocation location: LGLocation) {
        // If location is manual, then check if we should notify about moving too much
        if userDefaultsManager.loadIsManualLocation() {
            if let manualLocation = userDefaultsManager.loadManualLocation() {
                if location.location.distanceFromLocation(manualLocation) > LGCoreKitConstants.maxDistanceToAskUpdateLocation {
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.didMoveFromManualLocationNotification.rawValue, object: location)
                }
            }
        }
        // If not manual, then save & notify
        else {
            saveCoordinates(location, place: nil, completion: nil)
            NSNotificationCenter.defaultCenter().postNotificationName(Notification.locationUpdate.rawValue, object: location)
        }
    }
   
    // MARK: - Private methods
    
    // MARK: > Helper
    
    /**
        Returns the current installation.
    
        - returns: the current installation.
    */
    private func myInstallation() -> Installation {
        return PFInstallation.currentInstallation()
    }
    
    /**
        Runs the setup needed after a session (when signing up or logging in) is successful.
    */
    private func setupAfterSessionSuccessful() {
        
        // Ask to user default if current user has manual location
        if userDefaultsManager.loadIsManualLocation() {
            
            // If so, then notify the location manager, in case we have it
            if let location = userDefaultsManager.loadManualLocation() {
                let manualLocation = LGLocation(location: location, type: .Manual)
                locationManager.manualLocation = manualLocation
            }
        }
        
        // If we already have a location
        if let location = locationManager.currentLocation {
            
            // And source is more accurate than the one saved, then save it into my user
            switch location.type {
            case .Sensor, .Manual:
                saveCoordinates(location, place: nil, completion: nil)
            case .Regional, .IPLookup, .LastSaved:
                break
            }
        }
        
        if let user = MyUserManager.sharedInstance.myUser() {
            
            // If it has a country code, then set it in the currency helper
            if let countryCode = user.postalAddress.countryCode {
                CurrencyHelper.sharedInstance.setCountryCode(countryCode)
            }
            
            // Update my installation
            if let userId = user.objectId, let username = user.username {
                let installation = myInstallation()
                installation.userId = userId
                installation.username = username
                installation.channels = [""]
                installationSaveService.save(installation, completion: nil)
            }
        }
        
        // Notify
        NSNotificationCenter.defaultCenter().postNotificationName(Notification.login.rawValue, object: myUser())
    }
    

    // MARK: > Tasks
    
    // MARK: >> My User
    
    /**
        Saves my user.
    
        - parameter result: The closure containing the result.
    */
    private func saveMyUser(completion: UserSaveServiceCompletion?) {
        if let myUser = myUser() {
            userSaveService.saveUser(myUser, completion: completion)
        }
        else {
            completion?(UserSaveServiceResult(error: .Internal))
        }
    }
    
    /**
        Saves the given coordinates & place, if any, into the user.
    
        - parameter location: The location.
        - parameter place: The place. If nil, it will be retrieved.
        - returns: The completion closure.
    */
    private func saveCoordinates(location: LGLocation, place: Place?, completion: SaveUserCoordinatesCompletion?) {
        
        if let user = myUser() {
            // Set the coordinates, reset the address & mark as non-processed
            user.gpsCoordinates = LGLocationCoordinates2D(coordinates: location.coordinate)
            
            // If we receive a place, we set the postal address to the user
            if let _ = place, let actualPostalAddress = place?.postalAddress {
                user.postalAddress = actualPostalAddress
                
                // Set the currency code, if any
                if let countryCode = actualPostalAddress.countryCode {
                    if !countryCode.isEmpty {
                        CurrencyHelper.sharedInstance.setCountryCode(countryCode)
                    }
                }
            }
            // Otherwise, we create a new one that will be retrieved later (check step 2b)
            else {
                let address = PostalAddress(address: nil, city: nil, zipCode: nil, countryCode: nil, country: nil)
                user.postalAddress = address
            }
            
            user.processed = NSNumber(bool: false)
            
            // 1. Save it
            saveMyUser { (saveUserResult: Result<MyUser, UserSaveServiceError>) in
                
                // Success
                if let _ = saveUserResult.value {
                    
                    // 2a. User already has an address, we're done
                    if let _ = place, let _ = place?.postalAddress {
                        completion?(SaveUserCoordinatesResult(value: location.coordinate))
                    }
                    // 2b. User hasn't an address. Retrieve the address with the given coordinates
                    else {
                        self.postalAddressRetrievalService.retrieveAddressForLocation(location.location) { (postalAddressRetrievalResult: Result<Place, PostalAddressRetrievalServiceError>) -> Void in
                            
                            // Success
                            if let actualPlace = postalAddressRetrievalResult.value, let postalAddress = actualPlace.postalAddress {
                                
                                // 3a. Update the postal address & mark as non-processed
                                user.postalAddress = postalAddress
                                user.processed = NSNumber(bool: false)
                                
                                // 3b. Set the currency code, if any
                                if let countryCode = postalAddress.countryCode {
                                    if !countryCode.isEmpty {
                                        CurrencyHelper.sharedInstance.setCountryCode(countryCode)
                                    }
                                }
                                // 4. Save the user again
                                self.saveMyUser { (secondSaveUserResult: UserSaveServiceResult) in
                                    
                                    // Success or Error
                                    completion?(SaveUserCoordinatesResult(value: location.coordinate))
                                }
                            }
                            // Error
                            else if let postalAddressRetrievalError = postalAddressRetrievalResult.error {
                                completion?(SaveUserCoordinatesResult(error: SaveUserCoordinatesError(postalAddressRetrievalError)))
                            }
                        }
                    }
                }
                // Error
                else if let saveUserError = saveUserResult.error {
                    completion?(SaveUserCoordinatesResult(error: SaveUserCoordinatesError(saveUserError)))
                }
            }
        }
        else {
            completion?(SaveUserCoordinatesResult(error: .Internal))
        }
    }
}