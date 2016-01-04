//
//  SplashViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 04/01/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import LGTour


protocol SplashViewModelDelegate: class {
    func viewModelShouldForceUpdate(viewModel: SplashViewModel)
    func viewModel(viewModel: SplashViewModel, shouldShowOnBoarding tourViewController: LGTourViewController)
    func viewModelShouldContinue(viewModel: SplashViewModel)
}


class SplashViewModel: BaseViewModel {

    let configManager: ConfigManager
    let completion: (() -> ())?
    var configRequested: Bool
    weak var delegate: SplashViewModelDelegate?
    
    
    // MARK: - Lifecycle
    
    init(configManager: ConfigManager, completion: (() -> ())?) {
        self.configManager = configManager
        self.completion = completion
        self.configRequested = false
    }
    
    override func didSetActive(active: Bool) {
        if active {
            if !configRequested {
                updateConfig()
            } else {
                afterConfigUpdate()
            }
        }
    }
    
    
    // MARK: - Public methods
    
    /**
    Opens the AppStore at letgo's page.
    */
    func openAppStore() {
        guard let appStoreURL = EnvironmentProxy.sharedInstance.appStoreURL else { return }
        UIApplication.sharedApplication().openURL(appStoreURL)
    }
    
    
    // MARK: - Private methods
    
    /**
    Updates the configuration file.
    */
    private func updateConfig() {
        configRequested = true
        configManager.updateWithCompletion { [weak self] in
            self?.afterConfigUpdate()
        }
    }
    
    /**
    Called after configuration is updated. Forces update or shows on-boarding, if required.
    */
    private func afterConfigUpdate() {
        if shouldForceUpdate {
           delegate?.viewModelShouldForceUpdate(self)
        } else if shouldShowOnBoarding {
            let tourViewController = LGTourViewController(pages: onBoardingPages)
            delegate?.viewModel(self, shouldShowOnBoarding: tourViewController)
        } else {
            delegate?.viewModelShouldContinue(self)
        }
    }
    
    /**
    Informs if the application should force an update.
    */
    private var shouldForceUpdate: Bool {
        guard let appStoreURL = EnvironmentProxy.sharedInstance.appStoreURL else { return false }
        guard UIApplication.sharedApplication().canOpenURL(appStoreURL) else { return false }
        return configManager.shouldForceUpdate
    }
    
    /**
    Informs if the application should show the on-boarding.
    */
    private var shouldShowOnBoarding: Bool {
        let didShowOnboarding = UserDefaultsManager.sharedInstance.loadDidShowOnboarding()
        return !didShowOnboarding && configManager.shouldShowOnboarding
    }
    
    /**
    The page data objects that should be shown in the on-boarding.
    */
    private var onBoardingPages: [LGTourPage] {
        let page1 = LGTourPage(title: .Image(UIImage(named: "logo_white")), body: LGLocalizedString.tourPage1Body, image: UIImage(named: "tour_1"))
        let page2 = LGTourPage(title: .Text(LGLocalizedString.tourPage2Title), body: LGLocalizedString.tourPage2Body, image: UIImage(named: "tour_2"))
        let page3 = LGTourPage(title: .Text(LGLocalizedString.tourPage3Title), body: LGLocalizedString.tourPage3Body, image: UIImage(named: "tour_3"))
        let page4 = LGTourPage(title: .Text(LGLocalizedString.tourPage4Title), body: LGLocalizedString.tourPage4Body, image: UIImage(named: "tour_4"))
        return [page1, page2, page3, page4]
    }
}
