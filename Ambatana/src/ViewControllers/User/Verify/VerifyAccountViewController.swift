//
//  VerifyAccountViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 31/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class VerifyAccountViewController: BaseViewController {

    @IBOutlet weak var contentContainer: UIView!

    @IBOutlet weak var iconImage: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!

    @IBOutlet weak var actionButtonIcon: UIImageView!
    @IBOutlet weak var actionButton: UIButton!

    private let viewModel: VerifyAccountViewModel

    // MARK: - View Lifecycle

    init(viewModel: VerifyAccountViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "VerifyAccountViewController", statusBarStyle: .LightContent)
        viewModel.delegate = self
        modalPresentationStyle = .OverCurrentContext
        modalTransitionStyle = .CrossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }


    // MARK: - Private methods

    private func setupUI() {
        contentContainer.layer.cornerRadius = StyleHelper.defaultCornerRadius
        setupButtonUI()
    }

    private func setupButtonUI() {
        switch viewModel.type {
        case .Facebook:
            actionButton.setStyle(.Facebook)
            actionButtonIcon.image = UIImage(named: "ic_facebook_rounded")
        case .Google:
            actionButton.setStyle(.Google)
            actionButtonIcon.image = UIImage(named: "ic_google_rounded")
        case .Email:
            actionButton.setStyle(.Primary(fontSize: .Big))
            actionButtonIcon.hidden = true
        }
    }
}


// MARK: - Actions

extension VerifyAccountViewController {

    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func actionButtonPressed(sender: AnyObject) {
        viewModel.actionButtonPressed()
    }
}



// MARK: - VerifyAccountViewModelDelegate

extension VerifyAccountViewController: VerifyAccountViewModelDelegate {

}
