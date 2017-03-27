//
//  AdminViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 23/3/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import FLEX
import bumper
import LGCoreKit

class AdminViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private static let cellIdentifier = "AdminCell"
    var tableView: UITableView = UITableView()
    
    static func canOpenAdminPanel() -> Bool {
        var compiledInGodMode = false
        #if GOD_MODE
            compiledInGodMode = true
        #endif
        return compiledInGodMode || KeyValueStorage.sharedInstance[.isGod]
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: AdminViewController.cellIdentifier)
        view.addSubview(tableView)
        title = "🙏 God Panel 🙏"
        
        let closeButton = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: UIBarButtonItemStyle.plain,
            target: self, action: #selector(AdminViewController.closeButtonPressed))
        self.navigationItem.leftBarButtonItem = closeButton;
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        title = "🙏 God Panel 🙏"
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        title = "God Panel"
    }

    func closeButtonPressed() {
        dismiss(animated: true, completion: nil)
    }


    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: AdminViewController.cellIdentifier)
        cell.textLabel?.text = titleForCellAtIndexPath(indexPath)
        cell.detailTextLabel?.text = subtitleForCellAtIndexPath(indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            openFlex()
        case 1:
            openFeatureToggle()
        case 5:
            cleanInstall(keepInstallation: false)
        case 6:
            cleanInstall(keepInstallation: true)
        default:
            UIPasteboard.general.string = subtitleForCellAtIndexPath(indexPath)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        #if GOD_MODE
            return 7
        #else
            return 5
        #endif

    }
    
    // MARK: - Private
    
    private func openFlex() {
        FLEXManager.shared().showExplorer()
    }
    
    private func openFeatureToggle() {
        let vc = BumperViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    private func cleanInstall(keepInstallation: Bool) {
        let message = keepInstallation ?
            "You're about to reset stored state and bumper information. (Push, location, photos and camera permissions will remain)" :
            "You're about to reset all stored state, bumper and keychain information, installation will be new. (Push, location, photos and camera permissions will remain)"

        ask(message: message, andExecute: {
            GodModeManager.sharedInstance.setCleanInstallOnNextStart(keepingInstallation: keepInstallation)
            #if GOD_MODE
                exit(0)
            #endif
        })
    }

    private func ask(message: String, andExecute action: @escaping () -> Void) {
        let cancelAction = UIAction(interface: .styledText("Cancel", .cancel), action: {})
        let okAction = UIAction(interface: .styledText("Do it!", .standard), action: action)
        showAlert(nil, message: message, actions: [cancelAction, okAction])
    }
    
    private func titleForCellAtIndexPath(_ indexPath: IndexPath) -> String {
        switch indexPath.row {
        case 0:
            return "👾 FLEX"
        case 1:
            return "🎪 Bumper Features"
        case 2:
            return "📱 Installation id"
        case 3:
            return "😎 User id"
        case 4:
            return "📲 Push token"
        case 5:
            return "🌪 New install"
        case 6:
            return "⏮ Remove & install"
        default:
            return "Not implemented"
        }
    }
    
    private func subtitleForCellAtIndexPath(_ indexPath: IndexPath) -> String {
        let propertyNotFound = "None"
        switch indexPath.row {
        case 2:
            return Core.installationRepository.installation?.objectId ?? propertyNotFound
        case 3:
            return Core.myUserRepository.myUser?.objectId ?? propertyNotFound
        case 4:
            return Core.installationRepository.installation?.deviceToken ?? propertyNotFound
        case 5:
            return "Next start will be as a fresh install start (except system permissions)"
        case 6:
            return "Next start will be as re-install (keeping installation_id)"
        default:
            return ""
        }
    }
}
