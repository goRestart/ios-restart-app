//
//  UserRatingViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 12/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class RateUserViewController: BaseViewController {

    private let viewModel: RateUserViewModel

    // MARK: - Lifecycle

    init(viewModel: RateUserViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "RateUserViewController")
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
        viewModel.closeButtonPressed()
    }
}


// MARK: - UserRatingViewModelDelegate

extension RateUserViewController: RateUserViewModelDelegate {}