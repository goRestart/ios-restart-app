//
//  CarsAttributesChoiceViewController.swift
//  LetGo
//
//  Created by Dídac on 24/04/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift

class CarsAttributesChoiceViewController : BaseViewController, CarsAttributesChoiceViewModelDelegate {

    static var cellIdentifier = "CarsAttributesCellId"

    private let tableView: UITableView
    fileprivate let viewModel: CarsAttributesChoiceViewModel
    fileprivate var showingAttributeType: CarsAttributeType = .make(makesList: [])

    let disposeBag = DisposeBag()

    init(viewModel: CarsAttributesChoiceViewModel) {
        self.viewModel = viewModel
        self.tableView = UITableView()
        super.init(viewModel: viewModel, nibName: nil)
        self.viewModel.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRx()
    }

    private func setupUI() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layout(with: view).fill()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CarsAttributesChoiceViewController.cellIdentifier)
    }

    private func setupRx() {
        viewModel.carsAttributeType.asObservable().bindNext { [weak self] attrType in
            self?.showingAttributeType = attrType
            self?.tableView.reloadData()
        }.addDisposableTo(disposeBag)
    }
}

extension CarsAttributesChoiceViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showingAttributeType.list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: CarsAttributesChoiceViewController.cellIdentifier)

        cell.textLabel?.text = showingAttributeType.nameForItemAtPosition(position: indexPath.row)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch showingAttributeType {
        case .make:
            guard let selectedMake = showingAttributeType.itemAtPosition(position: indexPath.row) as? CarsMake else { return }
            viewModel.makeSelected(make: selectedMake)
        case .model:
            guard let selectedModel = showingAttributeType.itemAtPosition(position: indexPath.row) as? CarsModel else { return }
            viewModel.modelSelected(model: selectedModel)
        case .year:
            guard let selectedYear = showingAttributeType.itemAtPosition(position: indexPath.row) as? Int else { return }
            viewModel.yearSelected(year: selectedYear)
        }
    }
}
