//
//  MostSearchedItemsListViewController.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 03/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

class MostSearchedItemsListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    let closeButton = UIBarButtonItem()
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
        // TODO: Check further flow for navigationBar behaviours (didLoad vs didAppear)
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        closeButton.image = UIImage(named: "navbar_close")
        closeButton.style = .plain
        closeButton.target = self
        closeButton.action = #selector(MostSearchedItemsListViewController.closeButtonPressed)
        navigationItem.leftBarButtonItem = closeButton
        
        view.backgroundColor = .white
        
        edgesForExtendedLayout = []
        tableView.estimatedRowHeight = MostSearchedItemsListCell.cellHeight
        tableView.sectionHeaderHeight = MostSearchedItemsListHeader.viewHeight
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        tableView.layout(with: view).fillHorizontal()
        tableView.layout(with: topLayoutGuide).below()
        tableView.layout(with: bottomLayoutGuide).above()
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
        cell.updateWith(item: item, showSearchButton: !viewModel.isSearchEnabled)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = MostSearchedItemsListHeader()
        return header
    }
}
