//
//  MostSearchedItemsListViewController.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 03/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

class MostSearchedItemsListViewController: BaseViewController {
    
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
        super.init(viewModel: viewModel, nibName: nil)
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
        // TODO: Localize strings
        titleLabel.font = UIFont.boldSystemFont(ofSize: 23)
        titleLabel.textColor = UIColor.black
        titleLabel.numberOfLines = 2
        titleLabel.text = "Most popular items in {{ user-location }}"
        
        descriptionLabel.font = UIFont.systemRegularFont(size: 17)
        descriptionLabel.textColor = UIColor.darkGrayText
        descriptionLabel.numberOfLines = 2
        descriptionLabel.text = "Post one of these, and make money in under a week"
        
        subtitleLabel.font = UIFont.systemMediumFont(size: 13)
        subtitleLabel.textColor = UIColor.grayText
        subtitleLabel.text = "Searches this week"
    }
    
    private func setupConstraints() {
        let containerSubviews = [titleLabel, descriptionLabel, subtitleView, tableView]
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: containerSubviews)
        view.addSubviews(containerSubviews)
        
        let subtitleViews = [subtitleImageView, subtitleLabel]
        subtitleView.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subtitleViews)
        subtitleView.addSubviews(subtitleViews)
        
        titleLabel.layout(with: view).leading(by: Metrics.margin).trailing(by: -Metrics.margin).top(by: 64)
        titleLabel.layout().height(56)
        
        descriptionLabel.layout(with: view).leading(by: Metrics.margin).trailing(by: -Metrics.margin)
        descriptionLabel.layout(with: titleLabel).below(by: Metrics.margin)
        descriptionLabel.layout().height(40)
        
        subtitleView.layout(with: view).fillHorizontal()
        subtitleView.layout(with: descriptionLabel).below(by: Metrics.margin)
        subtitleView.layout().height(15)
        
        subtitleImageView.layout(with: subtitleView).fillVertical().leading(by: Metrics.margin)
        subtitleImageView.layout().width(15).height(15)
        
        subtitleLabel.layout(with: subtitleView).fillVertical().trailing(by: Metrics.margin)
        subtitleLabel.layout(with: subtitleImageView).leading()
        
        tableView.layout(with: view).fillHorizontal().bottom()
        tableView.layout(with: subtitleView).top(by: 20)
    }

}
