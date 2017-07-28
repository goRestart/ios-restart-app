//
//  TourCategoriesViewController.swift
//  LetGo
//
//  Created by Juan Iglesias on 28/07/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

final class TourCategoriesViewController: BaseViewController {
    
    let viewModel: TourCategoriesViewModel
    private let collectionView: TourCategoriesCollectionView
    private let titleLabel = UILabel()
    private let containerButton = UIView()
    private let okButton = UIButton()
    
    // MARK: - Lifecycle
    
    init(viewModel: TourCategoriesViewModel) {
        self.viewModel = viewModel
        self.collectionView = TourCategoriesCollectionView(categories: viewModel.categories, frame: CGRect.zero)
        self.viewModel.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setupRx()
        setupAccessibilityIds()
    }
    
    
    // MARK: - IBActions
    
    @IBAction func yesButtonPressed(_ sender: AnyObject) {
        viewModel.okButtonPressed()
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        
        containerButton.addSubview(okButton)
        view.addSubviews([titleLabel, collectionView, containerButton])
        
        titleLabel.text = LGLocalizedString.onboardingCategoriesTitle
    }
    
    private func setupLayout() {
        containerButton.layout(with: view).bottom().right().left()
        containerButton.layout().height(40)
        okButton.layout(with: containerButton).fill()
        
        titleLabel.layout(with: view).top().right().left()
        
        collectionView.layout(with: titleLabel).below()
        collectionView.layout(with: view).right().left()
        collectionView.layout(with: containerButton).above()
    }
    
    private func setupRx() {
        viewModel.okButtonText.asObservable().bindTo(okButton.rx.title)
    }
    
    private func setupAccessibilityIds() {
        okButton.accessibilityId = .tourCategoriesOkButton
        titleLabel.accesibilityId = .tourCategoriesTitleLabel
    }
}

// MARK: - TourLocationViewModelDelegate

extension TourCategoriesViewController: TourCategoriesViewModelDelegate { }
