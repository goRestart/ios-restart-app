//
//  BlockingPostingAddPriceViewController.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 19/02/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

class BlockingPostingAddPriceViewController: KeyboardViewController {
    
    fileprivate let doneButton = UIButton()
    fileprivate let addDetailPriceView = UIView()
    
    fileprivate let headerView = BlockingPostingStepHeaderView()
    
    fileprivate let viewModel: BlockingPostingAddPriceViewModel
    
    
    // MARK: - Lifecycle
    
    init(viewModel: BlockingPostingAddPriceViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        headerView.updateWith(stepNumber: BlockingPostingAddPriceViewModel.postingStepNumber, title: viewModel.headerTitle)
        
        doneButton.setTitle(LGLocalizedString.productPostDone, for: .normal)
        doneButton.setStyle(.primary(fontSize: .medium))
        doneButton.addTarget(self, action: #selector(doneButtonAction), for: .touchUpInside)
        
        viewModel.makePriceView(view: addDetailPriceView)
    }
    
    private func setupConstraints() {
        let subviews = [headerView, doneButton, addDetailPriceView]
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        view.addSubviews(subviews)
        
        headerView.layout(with: view)
            .fillHorizontal()
            .top()
        headerView.layout().height(headerView.height)
        
        doneButton.layout(with: view).bottom(by: -Metrics.margin)
        doneButton.layout().height(44)
        doneButton.layout().width(100, relatedBy: .greaterThanOrEqual)
        doneButton.layout(with: keyboardView).bottom(to: .top, by: -Metrics.bigMargin)
        doneButton.layout(with: view).right(by: -Metrics.bigMargin)
        
        let addDetailPriceViewTopMargin: CGFloat = 30
        addDetailPriceView.layout(with: view)
            .fillHorizontal()
            .top(by: BlockingPostingStepHeaderView.height + addDetailPriceViewTopMargin)
            .bottom(by: -(44+Metrics.bigMargin*2))
    }
    
    @objc private func openListingPosted() {
        viewModel.openListingPosted()
    }
    
    
    // MARK: - UI Actions
    
    @objc func doneButtonAction() {
        viewModel.nextButtonAction()
    }
    
}
