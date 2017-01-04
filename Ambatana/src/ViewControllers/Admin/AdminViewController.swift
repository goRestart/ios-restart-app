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
        default:
            UIPasteboard.general.string = subtitleForCellAtIndexPath(indexPath) ?? ""
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    // MARK: - Private
    
    private func openFlex() {
        FLEXManager.shared().showExplorer()
    }
    
    private func openFeatureToggle() {
        let vc = BumperViewController()
        navigationController?.pushViewController(vc, animated: true)
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
        default:
            return ""
        }
    }
}
