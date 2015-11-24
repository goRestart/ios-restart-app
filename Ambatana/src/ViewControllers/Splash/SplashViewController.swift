//
//  SplashViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 08/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import LGTour
import UIKit
import Result

class SplashViewController: BaseViewController, LGTourViewControllerDelegate {

    let configManager: ConfigManager
    
    var completionBlock: (Bool -> Void)?
    
    
    // MARK: - Lifecycle
    
    init(configManager: ConfigManager) {
        self.configManager = configManager
        
        super.init(viewModel: nil, nibName: "SplashViewController")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
       
    internal override func viewWillAppearFromBackground(fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)

        // Update the config file
        configManager.updateWithCompletion { () -> Void in
            
            // If should force update then show a blocking alert
            let itunesURL = String(format: Constants.appStoreURL, arguments: [EnvironmentProxy.sharedInstance.appleAppId])
            if self.configManager.shouldForceUpdate && UIApplication.sharedApplication().canOpenURL(NSURL(string:itunesURL)!) == true {
                let alert = UIAlertController(title: LGLocalizedString.forcedUpdateTitle, message: LGLocalizedString.forcedUpdateMessage, preferredStyle: .Alert)
                let openAppStore = UIAlertAction(title: LGLocalizedString.forcedUpdateUpdateButton, style: .Default, handler: { (action :UIAlertAction!) -> Void in
                    UIApplication.sharedApplication().openURL(NSURL(string:itunesURL)!)
                })
                
                alert.addAction(openAppStore)
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
            // Otherwise, show onboarding if not shown, or save my user if new
            else {
                let shouldShowOnboarding = self.configManager.shouldShowOnboarding
                let didShowOnboarding = UserDefaultsManager.sharedInstance.loadDidShowOnboarding()
                if shouldShowOnboarding && !didShowOnboarding {
                    let page1 = LGTourPage(title: .Image(UIImage(named: "logo_white")), body: LGLocalizedString.tourPage1Body, image: UIImage(named: "tour_1"))
                    let page2 = LGTourPage(title: .Text(LGLocalizedString.tourPage2Title), body: LGLocalizedString.tourPage2Body, image: UIImage(named: "tour_2"))
                    let page3 = LGTourPage(title: .Text(LGLocalizedString.tourPage3Title), body: LGLocalizedString.tourPage3Body, image: UIImage(named: "tour_3"))
                    let page4 = LGTourPage(title: .Text(LGLocalizedString.tourPage4Title), body: LGLocalizedString.tourPage4Body, image: UIImage(named: "tour_4"))
                    let pages = [page1, page2, page3, page4]
                    let tourVC = LGTourViewController(pages: pages)
                    tourVC.backgroundColor = UIColor(patternImage: UIImage(named: "pattern_red")!)
                    tourVC.pageTitleColor = UIColor.whiteColor()
                    tourVC.pageBodyColor = UIColor.whiteColor()
                    tourVC.closeButtonImage = UIImage(named: "ic_close")
                    tourVC.leftButtonImage = UIImage(named: "ic_arrow_white_left")
                    tourVC.skipButtonBackgroundColor = UIColor.whiteColor()
                    tourVC.skipButtonTextColor = StyleHelper.red
                    tourVC.skipButtonBorderRadius = 4
                    tourVC.skipButtonNonLastPageText = LGLocalizedString.tourPageSkipButton
                    tourVC.skipButtonLastPageText = LGLocalizedString.tourPageOkButton
                    tourVC.rightButtonImage = UIImage(named: "ic_arrow_white_right")
                    tourVC.delegate = self
                    
                    self.navigationController?.presentViewController(tourVC, animated: false, completion: nil)
                }
                else {
                    self.saveMyUserIfNew()
                }
 
            }
        }
    }
    
    // MARK: - LGTourViewControllerDelegate
    
    func tourViewControllerDidLoad(tourViewController: LGTourViewController) {
        // Save that the onboarding was shown so don't show it again
        UserDefaultsManager.sharedInstance.saveDidShowOnboarding()
        
        // Tracking
        let event = TrackerEvent.onboardingStart()
        TrackerProxy.sharedInstance.trackEvent(event)
    }
    
    func tourViewController(tourViewController: LGTourViewController, didShowPageAtIndex index: Int) {
        
    }
    
    func tourViewController(tourViewController: LGTourViewController, didAbandonWithButtonType buttonType: CloseButtonType, atIndex index: Int) {
        //Dismiss tour
        tourViewController.dismissViewControllerAnimated(false, completion: nil)
        
        // Save the user
        saveMyUserIfNew()
        
        // Tracking
        let event = TrackerEvent.onboardingAbandonAtPageNumber(index, buttonType: buttonType)
        TrackerProxy.sharedInstance.trackEvent(event)
    }
    
    func tourViewControllerDidFinish(tourViewController: LGTourViewController) {
        //Dismiss tour
        tourViewController.dismissViewControllerAnimated(false, completion: nil)
        
        // Save the user
        saveMyUserIfNew()
        
        // Tracking
        let event = TrackerEvent.onboardingComplete()
        TrackerProxy.sharedInstance.trackEvent(event)
    }
    
    // MARK: - Private methods
    
    private func saveMyUserIfNew() {
        MyUserManager.sharedInstance.saveOrRetrieveMyUser { [weak self] (result: UserSaveServiceResult) in
            if let strongSelf = self {
                let saveUserDidComplete = (result.value != nil)
                strongSelf.completionBlock?(saveUserDidComplete)
            }
            
            if let myUser = MyUserManager.sharedInstance.myUser() {
                TrackerProxy.sharedInstance.setUser(myUser)
            }
        }
    }
}
