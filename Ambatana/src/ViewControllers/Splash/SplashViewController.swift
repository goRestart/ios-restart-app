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

class SplashViewController: BaseViewController, LGTourViewControllerDelegate, SplashViewModelDelegate {

    let viewModel: SplashViewModel   
    
    
    // MARK: - Lifecycle
    
    init(viewModel: SplashViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "SplashViewController")
        self.viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    func tourViewController(tourViewController: LGTourViewController,
        didAbandonWithButtonType buttonType: CloseButtonType, atIndex index: Int) {
            //Dismiss tour
            tourViewController.dismissViewControllerAnimated(false, completion: nil)
            
            // Tracking
            let event = TrackerEvent.onboardingAbandonAtPageNumber(index, buttonType: buttonType)
            TrackerProxy.sharedInstance.trackEvent(event)
            
            // Run completion
            viewModel.completion?()
    }
    
    func tourViewControllerDidFinish(tourViewController: LGTourViewController) {
        //Dismiss tour
        tourViewController.dismissViewControllerAnimated(false, completion: nil)
        
        // Tracking
        let event = TrackerEvent.onboardingComplete()
        TrackerProxy.sharedInstance.trackEvent(event)
        
        // Run completion
        viewModel.completion?()
    }
    
    
    // MARK: - SplashViewModelDelegate
    
    func viewModelShouldForceUpdate(viewModel: SplashViewModel) {
        let alert = UIAlertController(title: LGLocalizedString.forcedUpdateTitle,
            message: LGLocalizedString.forcedUpdateMessage, preferredStyle: .Alert)
        let action = UIAlertAction(title: LGLocalizedString.forcedUpdateUpdateButton, style: .Default,
            handler: { [weak self] action in
                self?.viewModel.openAppStore()
        })
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func viewModel(viewModel: SplashViewModel, shouldShowOnBoarding tourViewController: LGTourViewController) {
        tourViewController.backgroundColor = UIColor(patternImage: UIImage(named: "pattern_red")!)
        tourViewController.pageTitleColor = UIColor.whiteColor()
        tourViewController.pageBodyColor = UIColor.whiteColor()
        tourViewController.closeButtonImage = UIImage(named: "ic_close")
        tourViewController.leftButtonImage = UIImage(named: "ic_arrow_white_left")
        tourViewController.skipButtonBackgroundColor = UIColor.whiteColor()
        tourViewController.skipButtonTextColor = StyleHelper.primaryColor
        tourViewController.skipButtonBorderRadius = 4
        tourViewController.skipButtonNonLastPageText = LGLocalizedString.tourPageSkipButton
        tourViewController.skipButtonLastPageText = LGLocalizedString.tourPageOkButton
        tourViewController.rightButtonImage = UIImage(named: "ic_arrow_white_right")
        tourViewController.delegate = self
        navigationController?.presentViewController(tourViewController, animated: false, completion: nil)
    }
    
    func viewModelShouldContinue(viewModel: SplashViewModel) {
        // Run completion
        viewModel.completion?()
    }
    
    
}
