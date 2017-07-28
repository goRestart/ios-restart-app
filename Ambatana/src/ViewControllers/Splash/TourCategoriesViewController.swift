//
//  TourCategoriesViewController.swift
//  LetGo
//
//  Created by Juan Iglesias on 28/07/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift

final class TourCategoriesViewController: BaseViewController {
    
    let viewModel: TourCategoriesViewModel
    private let collectionView: TourCategoriesCollectionView
    private let titleLabel = UILabel()
    private let containerButton = UIView()
    private let okButton = UIButton()
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    init(viewModel: TourCategoriesViewModel) {
        self.viewModel = viewModel
        self.collectionView = TourCategoriesCollectionView(categories: viewModel.categories, frame: CGRect.zero)
        super.init(viewModel: viewModel, nibName: nil)
        viewModel.delegate = self
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
        
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: [containerButton, okButton, titleLabel, collectionView, containerButton])
        containerButton.addSubview(okButton)
        view.addSubviews([titleLabel, collectionView, containerButton])
        
        titleLabel.text = LGLocalizedString.onboardingCategoriesTitle
        titleLabel.font = UIFont.systemBoldFont(size: 15)
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
        viewModel.okButtonText.asObservable().bindTo(okButton.rx.title).addDisposableTo(disposeBag)
    }
    
    private func setupAccessibilityIds() {
        okButton.accessibilityId = .tourCategoriesTitleOkButton
        titleLabel.accessibilityId = .tourCategoriesTitleLabel
    }
}

// MARK: - TourLocationViewModelDelegate

extension TourCategoriesViewController: TourCategoriesViewModelDelegate { }
