//
//  UserRatingViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 12/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class UserRatingViewController: BaseViewController {

    private let viewModel: UserRatingViewModel

    // MARK: - Lifecycle

    init(viewModel: UserRatingViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "UserRatingViewController")
        self.viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }


    // MARK: - Private methods

    private func setupUI() {
        // View
        view.backgroundColor = UIColor.listBackgroundColor

        // Navigation bar
        let closeButton = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: .Plain, target: self,
                                          action: #selector(closeButtonPressed))
        navigationItem.leftBarButtonItem = closeButton
    }

    dynamic private func closeButtonPressed() {
        //TODO: NAVIGATOR!
        dismissViewControllerAnimated(true, completion: nil)
    }
}


// MARK: - UserRatingViewModelDelegate

extension UserRatingViewController: UserRatingViewModelDelegate {}