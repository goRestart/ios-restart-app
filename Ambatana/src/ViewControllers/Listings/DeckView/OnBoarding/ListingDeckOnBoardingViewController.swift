//
//  ListingDeckOnBoardingViewController.swift
//  LetGo
//
//  Created by Facundo Menzella on 24/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

protocol ListingDeckOnBoardingViewModelType {
    func close()
}

final class ListingDeckOnBoardingViewController: BaseViewController {

    private let onboardingiew = ListingDeckOnBoardingView()
    private let viewModel: ListingDeckOnBoardingViewModelType

    override func loadView() {
        self.view = onboardingiew
    }

    init<T>(viewModel: T) where T: ListingDeckOnBoardingViewModelType, T: BaseViewModel {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        tapGesture.delaysTouchesBegan = true
        onboardingiew.addGestureRecognizer(tap)
    }

    private func didTapView() {
        viewModel.close()
    }
}
