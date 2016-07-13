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
        super.init(viewModel: viewModel, nibName: "RateUserViewController", navBarBackgroundStyle: .Transparent)
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
        view.backgroundColor = UIColor.listBackgroundColor
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: .Plain,
                                                           target: self, action: #selector(closeButtonPressed))
    }

    dynamic private func closeButtonPressed() {
        viewModel.closeButtonPressed()
    }
}


// MARK: - UserRatingViewModelDelegate

extension RateUserViewController: RateUserViewModelDelegate {}