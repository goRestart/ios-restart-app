//
//  MostSearchedItemsListViewController.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 03/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

class MostSearchedItemsListViewController: BaseViewController, UITableViewDelegate,
    UITableViewDataSource, MostSearchedItemsListCellDelegate {
    
    let closeButton = UIBarButtonItem()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let subtitleView = UIView()
    let subtitleImageView = UIImageView()
    let subtitleLabel = UILabel()
    let tableView = UITableView()
    
    let viewModel: MostSearchedItemsListViewModel
    
    
    // MARK: - Lifecycle
    
    init(viewModel: MostSearchedItemsListViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil, navBarBackgroundStyle: .transparent(substyle: .light))
        
        tableView.register(MostSearchedItemsListCell.self, forCellReuseIdentifier: MostSearchedItemsListCell.reusableID)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        closeButton.image = UIImage(named: "navbar_close")
        closeButton.style = .plain
        closeButton.target = self
        closeButton.action = #selector(MostSearchedItemsListViewController.closeButtonPressed)
        navigationItem.leftBarButtonItem = closeButton
        
        view.backgroundColor = .white
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 23)
        titleLabel.textColor = UIColor.black
        titleLabel.numberOfLines = 2
        titleLabel.text = LGLocalizedString.trendingItemsViewTitle("TODO") // TODO: Set user location with city
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.2
        
        descriptionLabel.font = UIFont.systemRegularFont(size: 17)
        descriptionLabel.textColor = UIColor.darkGrayText
        descriptionLabel.numberOfLines = 2
        descriptionLabel.text = LGLocalizedString.trendingItemsViewSubtitle
        
        subtitleImageView.image = UIImage(named: "ic_search")
        
        subtitleLabel.font = UIFont.systemMediumFont(size: 13)
        subtitleLabel.textColor = UIColor.grayText
        subtitleLabel.text = LGLocalizedString.trendingItemsViewNumberOfSearchesTitle
        
        tableView.estimatedRowHeight = MostSearchedItemsListCell.cellHeight
    }
    
    private func setupConstraints() {
        let containerSubviews = [titleLabel, descriptionLabel, subtitleView, tableView]
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: containerSubviews)
        view.addSubviews(containerSubviews)
        
        let subtitleViews = [subtitleImageView, subtitleLabel]
        subtitleView.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subtitleViews)
        subtitleView.addSubviews(subtitleViews)
        
        titleLabel.layout(with: view)
            .leading(by: Metrics.bigMargin)
            .trailing(by: -Metrics.bigMargin)
        titleLabel.layout(with: topLayoutGuide).below(by: Metrics.bigMargin)
        titleLabel.layout().height(56)
        
        descriptionLabel.layout(with: view)
            .leading(by: Metrics.bigMargin)
            .trailing(by: -Metrics.bigMargin)
        descriptionLabel.layout(with: titleLabel).below(by: Metrics.margin)
        descriptionLabel.layout().height(50)
        
        subtitleView.layout(with: view).fillHorizontal()
        subtitleView.layout(with: descriptionLabel).below(by: Metrics.margin)
        subtitleView.layout().height(15)
        
        subtitleImageView.layout(with: subtitleView)
            .fillVertical()
            .leading(by: Metrics.bigMargin)
        subtitleImageView.layout()
            .width(15)
            .height(15)
        
        subtitleLabel.layout(with: subtitleView)
            .fillVertical()
            .trailing(by: Metrics.bigMargin)
        subtitleLabel.layout(with: subtitleImageView).toLeft(by: Metrics.margin)
        
        tableView.layout(with: view).fillHorizontal()
        tableView.layout(with: bottomLayoutGuide).above()
        tableView.layout(with: subtitleView).below(by: Metrics.bigMargin)
    }

    
    // MARK: - UI Actions
    
    @objc private func closeButtonPressed() {
        viewModel.closeButtonPressed()
    }
    
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.mostSearchedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MostSearchedItemsListCell.reusableID,
                                                        for: indexPath) as? MostSearchedItemsListCell else { return UITableViewCell() }
        let item = viewModel.itemAtIndex(indexPath.row)
        cell.delegate = self
        cell.updateWith(item: item, showSearchButton: !viewModel.isSearchEnabled)
        return cell
    }
    
    
    // MARK: - MostSearchedItemsCellDelegate
    
    func didPostAction(item: LocalMostSearchedItem) {
        viewModel.postButtonAction(item: item)
    }
    
    func didSearchAction(listingTitle: String) {
        viewModel.searchButtonAction(listingTitle: listingTitle)
    }
    
}
