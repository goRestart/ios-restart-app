//
//  PushPrePermissionsSettings.swift
//  LetGo
//
//  Created by Isaac Roldan on 7/3/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

final class PushPrePermissionsSettingsViewController: BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var firstSectionLabel: UILabel!
    @IBOutlet weak var notificationsLabel: UILabel!
    @IBOutlet weak var secondSectionLabel: UILabel!
    @IBOutlet weak var allowNotificationsLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    
    
    // MARK: - Lifecycle
    
    init() {
        switch DeviceFamily.current {
        case .iPhone4, .iPhone5:
            super.init(viewModel: nil, nibName: "PushPrePermissionsSettingsViewControllerMini")
        case .iPhone6, .iPhone6Plus, .unknown:
            super.init(viewModel: nil, nibName: "PushPrePermissionsSettingsViewController")
        }
        
        modalPresentationStyle = .OverCurrentContext
        modalTransitionStyle = .CrossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI
    
    func setupUI() {
        
    }
    
    
    
    // MARK: - Actions
    
    @IBAction func yesButtonPressed(sender: AnyObject) {
    
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
    
    }
}