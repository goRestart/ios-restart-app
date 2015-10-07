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
    public func saveMyUserIfNew(result: UserSaveServiceResult?) {
        if let myUser = myUser() {
            if !myUser.isSaved {
                userSaveService.saveUser(myUser) { [weak self] (myResult: Result<User, UserSaveServiceError>) in
                    result?(myResult)

                    // Save my installation
                    if let installation = self?.myInstallation() {
                        if let userId = myUser.objectId {
                            installation.userId = userId
                        }
                        self?.installationSaveService.save(installation, result: nil)
                    }
                }
            }
            else {
                result?(Result<User, UserSaveServiceError>.success(myUser))
            }
        }
        else {
            result?(Result<User, UserSaveServiceError>.failure(.Internal))
        }
    }
    
    /**
        Saves the installation with the given device token.
        
        :param: deviceToken The APN device token.
    */
    public func saveInstallationDeviceToken(deviceToken: NSData) {
        var installation = myInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installationSaveService.save(installation, result: nil)
    }
    
    /**
        Update the user's avatar with the given image.
    
        :param: image The image.
        :param: result The closure containing the result.
    */
    public func updateAvatarWithImage(image: UIImage, result: FileUploadResult?) {
        if let myUser = myUser(), let myUserId = myUser.objectId, let sessionToken = myUser.sessionToken, let data = UIImageJPEGRepresentation(image, 0.9) {

            // 1. Upload the picture
            fileUploadService.uploadFileWithUserId(myUserId, sessionToken: sessionToken, data: data) { (fileUploadResult: Result<File, FileUploadServiceError>) in

                // Succeeded
                if let file = fileUploadResult.value {
                
                    // 2a. Set the user's avatar & mark as non-processed
                    myUser.avatar = file
                    myUser.processed = NSNumber(bool: false)
                    
                    // 2b. Save the user
                    self.saveMyUser { (userSaveResult: Result<User, UserSaveServiceError>) in
                        
                        // Succeeded
                        if let savedUser = userSaveResult.value {
                            result?(Result<File, FileUploadError>.success(file))
                        }
                        // Error
                        else if let saveError = userSaveResult.error {
                            result?(Result<File, FileUploadError>.failure(FileUploadError(saveError)))
                        }
                    }
                }
                // Error
                else if let fileUploadError = fileUploadResult.error {
                    result?(Result<File, FileUploadError>.failure(FileUploadError(fileUploadError)))
                }
            }
        }
        else {
            result?(Result<File, FileUploadError>.failure(.Internal))
        }
    }
    
    /**
        Updates my usename.
    
        :param: username The username.
        :param: result The closure containing the result.
    */
    public func updateUsername(username: String, result: UserSaveServiceResult?) {
        if let myUser = myUser() {
            myUser.publicUsername = username
            myUser.processed = NSNumber(bool: false)
            saveMyUser(result)
        }
        else {
            result?(Result<User, UserSaveServiceError>.failure(.Internal))
        }
    }
    
    /**
        Updates my user password.
    
        :param: password The password.
        :param: result The closure containing the result.
    */
    public func updatePassword(password: String, result: UserSaveServiceResult?) {
        if let myUser = myUser() {
            myUser.password = password
            myUser.processed = NSNumber(bool: false)
            saveMyUser(result)
        }
        else {
            result?(Result<User, UserSaveServiceError>.failure(.Internal))
        }
    }
    
    /**
        Updates my user email.
    
        :param: email The email.
        :param: result The closure containing the result.
    */
    public func updateEmail(email: String, result: UserSaveServiceResult?) {
        if let myUser = myUser() {
            myUser.email = email
            myUser.processed = NSNumber(bool: false)
            saveMyUser(result)
        }
        else {
            result?(Result<User, UserSaveServiceError>.failure(.Internal))
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
                if let coords = myUser()?.gpsCoordinates, let location = CLLocation(latitude: coords.latitude, longitude: coords.longitude) {
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
    
        :param: location The location.
        :param: place The place.
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
        
        :param: place The place.
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
    
        :param: email The email.
        :param: password The password.
        :param: publicUsername The public user name.
        :param: result The closure containing the result.
    */
    public func signUpWithEmail(email: String, password: String, publicUsername: String, result: UserSignUpServiceResult?) {
        userSignUpService.signUpUserWithEmail(email, password: password, publicUsername: publicUsername) { (myResult: Result<Nil, UserSignUpServiceError>) in
            // Succeeded
            if myResult == Result<Nil, UserSignUpServiceError>.success(Nil()) {
                self.setupAfterSessionSuccessful()
            }
            result?(myResult)
        }
    }
    
    /**
        Logs in a user with the given email & password.
    
        :param: email The email.
        :param: password The password.
        :param: result The closure containing the result.
    */
    public func logInWithEmail(email: String, password: String, result: UserLogInEmailServiceResult?) {
        // 1. Login
        userLogInEmailService.logInUserWithEmail(email, password: password) { (myResult: Result<User, UserLogInEmailServiceError>) in
            // Succeeded
            if let user = myResult.value {
                var isScammerUser: Bool = false
                if let isScammer = user.isScammer?.boolValue {
                    isScammerUser = isScammer
                }
                
                // 2a. If scammer then logout & notify
                if isScammerUser {
                    self.userLogOutService.logOutUser(user) { (logoutResult: Result<Nil, UserLogOutServiceError>) -> Void in
                        result?(Result<User, UserLogInEmailServiceError>.failure(.Forbidden))
                    }
                }
                // 2b. Otherwise it's a regular user, we're done
                else {
                    self.setupAfterSessionSuccessful()
                    result?(myResult)
                }
            }
            // Error
            else {
                result?(myResult)
            }
        }
    }
    
    /**
        Logs in a user via Facebook.

        :param: result The closure containing the result.
    */
    public func logInWithFacebook(result: UserLogInFBResult?) {
        
        var user: User? = nil
        var fbUserInfo: FBUserInfo? = nil
        
        // 1. Login with Facebook
        userLogInFBService.logInByFacebooWithCompletion { (myResult: Result<User, UserLogInFBServiceError>) in
            
            // Succeeded
            if let user = myResult.value, let userId = user.objectId {
                
                var isScammerUser: Bool = false
                if let isScammer = user.isScammer?.boolValue {
                    isScammerUser = isScammer
                }
                
                // 2a. If scammer then logout & notify
                if isScammerUser {
                    self.userLogOutService.logOutUser(user) { (logoutResult: Result<Nil, UserLogOutServiceError>) -> Void in
                        result?(Result<User, UserLogInFBError>.failure(.Forbidden))
                    }
                }
                // 2b. Otherwise it's a regular user, then retrieve the FB info
                else {
                    // 3. Retrieve the FB Info
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
                            user.email = fbUserInfo.email
                            user.publicUsername = publicUsername
                            user.processed = NSNumber(bool: false)
                            
                            // 4. Save my user
                            self.saveMyUser { (userSaveResult: Result<User, UserSaveServiceError>) in
                                
                                // Succeeded
                                if let savedUser = userSaveResult.value, let sessionToken = savedUser.sessionToken {
                                    
                                    // 5. Upload the avatar
                                    self.fileUploadService.uploadFileWithUserId(savedUser.objectId, sessionToken: sessionToken, sourceURL: fbUserInfo.avatarURL) { (uploadResult: Result<File, FileUploadServiceError>) in
                                        
                                        // Succeeded
                                        if let file = uploadResult.value {
                                            
                                            // 6. Set the user's avatar & mark as non-processed
                                            savedUser.avatar = file
                                            savedUser.processed = NSNumber(bool: false)
                                            
                                            // 7. Save my user again
                                            self.saveMyUser { (userSaveResult: Result<User, UserSaveServiceError>) in
                                                
                                                // Success or Error, but in case of error report success as avatar is not strictly necessary
                                                let savedUser = userSaveResult.value ?? user
                                                
                                                self.setupAfterSessionSuccessful()
                                                result?(Result<User, UserLogInFBError>.success(savedUser))
                                            }
                                        }
                                        // Error, but report success as avatar is not strictly necessary
                                        else if let uploadError = uploadResult.error {
                                            
                                            self.setupAfterSessionSuccessful()
                                            result?(Result<User, UserLogInFBError>.success(user))
                                        }
                                    }
                                }
                                // Error, then logout & report it as the user could not be saved (i.e.: EmailTaken)
                                else if let saveUserError = userSaveResult.error {
                                    self.logout(nil)
                                    result?(Result<User, UserLogInFBError>.failure(UserLogInFBError(saveUserError)))
                                }
                            }
                        }
                        // Error, then logout & report it as the info couldn't be loaded
                        else if let fbError = fbResult.error {
                            self.logout(nil)
                            result?(Result<User, UserLogInFBError>.failure(UserLogInFBError(fbError)))
                        }
                    }
                }
            }
            // Error, then report it
            else if let fbLoginError = myResult.error {
                result?(Result<User, UserLogInFBError>.failure(UserLogInFBError(fbLoginError)))
            }
        }
    }
    
    /**
        Logs out my user.
    
        :param: result The closure containing the result.
    */
    public func logout(result: UserLogOutServiceResult?) {
        if let myUser = myUser() {

            // Notify location manager that there's no manual location
            locationManager.manualLocation = nil
            
            // Logout
            userLogOutService.logOutUser(myUser) { (myResult: Result<Nil, UserLogOutServiceError>) in
                
                // Notify the callback
                result?(Result<Nil, UserLogOutServiceError>.success(Nil()))
                
                // Update my installation in background, unlink userId & username
                if let myUser = self.myUser(), let userId = myUser.objectId, let username = myUser.username {
                    var installation = self.myInstallation()
                    installation.userId = ""
                    installation.username = ""
                    installation.channels = [""]
                    self.installationSaveService.save(installation) { (result: Result<Installation, InstallationSaveServiceError>) in }
                }
            }
            
            // Notify
            NSNotificationCenter.defaultCenter().postNotificationName(Notification.logout.rawValue, object: nil)
        }
        else {
            result?(Result<Nil, UserLogOutServiceError>.failure(.Internal))
        }
    }
    
    // MARK: > Password reset
    
    /**
        Resets the password of a my user.
    
        :param: email The user email.
        :param: result The closure containing the result.
    */
    public func resetPassword(email: String, result: UserPasswordResetServiceResult?) {
        userPasswordResetService.resetPassword(email, result: result)
    }
    
    // MARK: - LocationManagerDelegate
    
    func locationManager(locationManager: LocationManager, didUpdateAutoLocation location: LGLocation) {
        // If location is manual, then check if we should notify about moving too much
        if userDefaultsManager.loadIsManualLocation() {
            if location.location.distanceFromLocation(userDefaultsManager.loadManualLocation()) > LGCoreKitConstants.maxDistanceToAskUpdateLocation{
                NSNotificationCenter.defaultCenter().postNotificationName(Notification.didMoveFromManualLocationNotification.rawValue, object: location)
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
    
        :returns: the current installation.
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
                var installation = myInstallation()
                installation.userId = userId
                installation.username = username
                installation.channels = [""]
                installationSaveService.save(installation, result: nil)
            }
        }
        
        // Notify
        NSNotificationCenter.defaultCenter().postNotificationName(Notification.login.rawValue, object: myUser())
    }
    

    // MARK: > Tasks
    
    // MARK: >> My User
    
    /**
        Saves my user.
    
        :param: result The closure containing the result.
    */
    private func saveMyUser(result: UserSaveServiceResult?) {
        if let myUser = myUser() {
            userSaveService.saveUser(myUser, result: result)
        }
        else {
            result?(Result<User, UserSaveServiceError>.failure(.Internal))
        }
    }
    
    /**
        Saves the given coordinates & place, if any, into the user.
    
        :param: location The location.
        :param: place The place. If nil, it will be retrieved.
        :returns: The completion closure.
    */
    private func saveCoordinates(location: LGLocation, place: Place?, completion: SaveUserCoordinatesResult?) {
        
        if let user = myUser() {
            // Set the coordinates, reset the address & mark as non-processed
            user.gpsCoordinates = LGLocationCoordinates2D(coordinates: location.coordinate)
            
            // If we receive a place, we set the postal address to the user
            if let actualPlace = place, let actualPostalAddress = place?.postalAddress {
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
                let address = PostalAddress()
                user.postalAddress = address
            }
            
            user.processed = NSNumber(bool: false)
            
            // 1. Save it
            saveMyUser { (saveUserResult: Result<User, UserSaveServiceError>) in
                
                // Success
                if let savedUser = saveUserResult.value {
                    
                    // 2a. User already has an address, we're done
                    if let actualPlace = place, let actualPostalAddress = place?.postalAddress {
                        completion?(Result<CLLocationCoordinate2D, SaveUserCoordinatesError>.success(location.coordinate))
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
                                self.saveMyUser { (secondSaveUserResult: Result<User, UserSaveServiceError>) in
                                    
                                    // Success or Error
                                    completion?(Result<CLLocationCoordinate2D, SaveUserCoordinatesError>.success(location.coordinate))
                                }
                            }
                            // Error
                            else if let postalAddressRetrievalError = postalAddressRetrievalResult.error {
                                completion?(Result<CLLocationCoordinate2D, SaveUserCoordinatesError>.failure(SaveUserCoordinatesError(postalAddressRetrievalError)))
                            }
                        }
                    }
                }
                // Error
                else if let saveUserError = saveUserResult.error {
                    completion?(Result<CLLocationCoordinate2D, SaveUserCoordinatesError>.failure(SaveUserCoordinatesError(saveUserError)))
                }
            }
        }
        else {
            completion?(Result<CLLocationCoordinate2D, SaveUserCoordinatesError>.failure(.Internal))
        }
    }
}