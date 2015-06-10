//
//  ConfigurationManager.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 05/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import FBSDKCoreKit
import Parse
import UIKit

// private singleton instance
private let _singletonInstance = ConfigurationManager()

/**
 * The ConfigurationManager is in charge of handling the configuration of the user, including his/her data and profile picture.
 * It also handles the user-specified settings for the application.
 * ConfigurationManager follows the Singleton pattern, so it's accessed by means of the shared method sharedInstance().
 */
class ConfigurationManager: NSObject {
    // data
    var userName: String = translate("user")
    var userLocation: String = ""
    var userEmail: String = ""
    var userProfileImage: UIImage?
    var userFilterForProducts = LetGoUserFilterForProducts.Proximity
    
    /** Shared instance */
    class var sharedInstance: ConfigurationManager {
        return _singletonInstance
    }

    // MARK: - Setting and reading user's profile data
    
    // loads the initial facebook profile data in the user's profile
    func loadInitialFacebookProfileData() {
        if let currentUser = PFUser.currentUser() {
            // enable notification of changes in access token and profile info.
            FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
//            NSNotificationCenter.defaultCenter().addObserver(self, selector: "facebookAccessTokenAndRelatedInfoChanged:", name: FBSDKProfileDidChangeNotification, object: nil)
            
            // get current prodile data:
            let fbRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
            fbRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                if let userData = result as? NSDictionary {
                    // start filling user profile data.
                    //println("Datos de Facebook: \(userData)")
                    
                    // user name
                    let firstName = userData["first_name"] as? String
                    let lastName = userData["last_name"] as? String
                    if firstName != nil && lastName != nil {
                        let lastNameInitial: String = count(lastName!) > 0 ? lastName!.substringToIndex(advance(lastName!.startIndex, 1)) : ""
                        currentUser["username_public"] = "\(firstName!) \(lastNameInitial)."
                        self.userName = "\(firstName!) \(lastNameInitial)."
                    } else {
                        if let userName = userData["name"] as? NSString {
                            currentUser["username_public"] = userName
                            self.userName = userName as String
                        }
                    }
                    
                    // user email
                    if let userEmail = userData["email"] as? NSString {
                        currentUser["username"] = userEmail
                        currentUser["email"] = userEmail
                        self.userEmail = userEmail as String
                        
                        // Tracking
                        TrackingHelper.setUserId(userEmail as String)
                    }
                    
                    // user picture & facebookID
                    let facebookId: String = userData["id"] as! String
                    let userPictureURL = "https://graph.facebook.com/\(facebookId)/picture?type=large&return_ssl_resources=1"
                    self.setUserPictureFromURL(userPictureURL)
                    
                    // save user profile
                    currentUser.saveInBackgroundWithBlock(nil)
                    self.checkIfInstallationNeedsToBeUpdatedWithCurrentUserData()
                } else { // error
                    var oauthSessionExpired = false
                    if error != nil {
                        if let userInfo = error!.userInfo {
                            if let errorType = userInfo["type"] as? String {
                                if errorType == "OAuthException" {
                                    oauthSessionExpired = true
                                }
                            }
                        }
                    }
                    if oauthSessionExpired { // logout
                        PFUser.logOut()
                        NSNotificationCenter.defaultCenter().postNotificationName(kLetGoSessionInvalidatedNotification, object: nil)
                    } else { // notify error
                        NSNotificationCenter.defaultCenter().postNotificationName(kLetGoInvalidCredentialsNotification, object: nil)
                    }
                }
            })
        }
    }
    
//    /** Observes changes in Facebook access token and user related info */
//    func facebookAccessTokenAndRelatedInfoChanged(notification: NSNotification) {
//        if let newProfile = notification.userInfo?["FBSDKProfileNew"] as? FBSDKProfile {
//            // TODO: Update data with profile info ?
//        }
//    }
    
    func logOutUser() {
        userName = translate("user")
        userLocation = ""
        userEmail = ""
        userProfileImage = nil
    }
    
    // loads the user data from the already configured & authenticated PFUser
    func loadDataFromCurrentUser() {
        // name
        if let userName = PFUser.currentUser()?["username_public"] as? String { self.userName = userName }
        // user email
        if let userEmail = PFUser.currentUser()?["email"] as? String { self.userEmail = userEmail }
        // user location
        if let userLocation = PFUser.currentUser()?["city"] as? String { self.userLocation = userLocation }
        // profile picture
        if let avatarFile = PFUser.currentUser()?["avatar"] as? PFFile {
            avatarFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if error == nil && data != nil { // success
                    let updatedImage = UIImage(data: data!)
                    self.userProfileImage = updatedImage
                    NSNotificationCenter.defaultCenter().postNotificationName(kLetGoUserPictureUpdatedNotification, object: updatedImage)
                }
            })
        }
        checkIfInstallationNeedsToBeUpdatedWithCurrentUserData()
    }
    
    // checks if we need to update the installation data, linking it with our current user information.
    func checkIfInstallationNeedsToBeUpdatedWithCurrentUserData() {
        var installationModified = false
        if PFUser.currentUser() != nil { // associate installation and user.
            PFInstallation.currentInstallation()["user_objectId"] = PFUser.currentUser()!.objectId
            if let installationUsername = PFUser.currentUser()!["username"] as? String {
                PFInstallation.currentInstallation()["username"] = installationUsername
            }
            installationModified = true
        }
        if installationModified {
            PFInstallation.currentInstallation().saveInBackgroundWithBlock(nil)
        }
    }
    
    // loads the picture from a URL
    func setUserPictureFromURL(urlAsString: String) {
        if let url = NSURL(string: urlAsString) {
            let urlRequest = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: { (response, data, error) -> Void in
                if error == nil && data != nil { // success
                    let updatedImage = UIImage(data: data)
                    
                    // update user image in Parse
                    let parseImage: PFFile = PFFile(data: data)
                    PFUser.currentUser()?["avatar"] = parseImage
                    PFUser.currentUser()?.saveInBackgroundWithBlock(nil)
                    
                    // update image in local interface.
                    self.userProfileImage = updatedImage
                    NSNotificationCenter.defaultCenter().postNotificationName(kLetGoUserPictureUpdatedNotification, object: updatedImage)
                    
                    
                }
            })
        }
    }
    
}













