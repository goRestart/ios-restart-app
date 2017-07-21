//
//  TaxonomiesViewController.swift
//  LetGo
//
//  Created by Juan Iglesias on 20/07/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift

class TaxonomiesViewController : BaseViewController, TaxonomiesViewModelDelegate {
    
    private let tableView = TaxonomiesTableView()
    fileprivate let viewModel: TaxonomiesViewModel
    
    let disposeBag = DisposeBag()
    
    
    // MARK: - LifeCycle
    
    init(viewModel: TaxonomiesViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        self.viewModel.delegate = self
        self.title = viewModel.title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRx()
        updateTableView(values: viewModel.taxonomies, selectedValueIndex: nil)
    }
    
     // MARK: - UI
    
    private func setupUI() {
        view.backgroundColor = UIColor.white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        tableView.layout(with: view).fill()
    }
    
    private func updateTableView(values: [Taxonomy], selectedValueIndex: Int?) {
        tableView.setupTableView(values: values,
                                 selectedValueIndex: selectedValueIndex)
    }
    
    private func setupRx() {
        // Rx to select info
        tableView.itemSelected.asObservable().bindNext { [weak self] taxonomyChild in
            guard let strongSelf = self else { return }
            guard let selectedId = taxonomyChild?.id,
                let selectedName = taxonomyChild?.name,
                let selectedType = taxonomyChild?.type else { return }
            strongSelf.viewModel.taxonomyChildSelected(id: selectedId, name: selectedName, type: selectedType)
            }.addDisposableTo(disposeBag)
    }
}
