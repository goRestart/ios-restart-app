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
    
    override func viewDidLayoutSubviews() {
        okButton.cornerRadius = okButton.height/2
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
        titleLabel.font = UIFont.systemBoldFont(size: 30)
        titleLabel.numberOfLines = 0
        
        okButton.setStyle(.primary(fontSize: .medium))
    }
    
    private func setupLayout() {
        containerButton.layout(with: view).bottom().right().left()
        containerButton.layout().height(80)
        okButton.layout().height(Metrics.buttonHeight)
        okButton.layout(with: containerButton).right(by: -20).left(by: 20).centerY()
        
        titleLabel.layout(with: view).top(by: 2*Metrics.bigMargin).right(by: -20).left(by: 20)
        
        collectionView.layout(with: titleLabel).below(by:30)
        collectionView.layout(with: view).right().left()
        collectionView.layout(with: containerButton).above()
    }
    
    private func setupRx() {
        collectionView.categoriesSelected.asObservable().bindTo(viewModel.categoriesSelected).addDisposableTo(disposeBag)
        viewModel.okButtonText.asObservable().bindTo(okButton.rx.title).addDisposableTo(disposeBag)
        okButton.rx.tap.asObservable().bindNext { [weak self] in
            self?.viewModel.okButtonPressed()
        }.addDisposableTo(disposeBag)
        viewModel.minimumCategoriesSelected.asObservable().bindTo(okButton.rx.isEnabled).addDisposableTo(disposeBag)
    }
    
    private func setupAccessibilityIds() {
        okButton.accessibilityId = .tourCategoriesTitleOkButton
        titleLabel.accessibilityId = .tourCategoriesTitleLabel
    }
}

// MARK: - TourLocationViewModelDelegate

extension TourCategoriesViewController: TourCategoriesViewModelDelegate { }
