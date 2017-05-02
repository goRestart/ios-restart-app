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

    private let tableView = CategoryDetailTableView(withStyle: .darkContent)
    fileprivate let viewModel: CarsAttributesChoiceViewModel

    private var isDrawingInitialSelection: Bool = false

    let disposeBag = DisposeBag()

    init(viewModel: CarsAttributesChoiceViewModel) {
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
    }

    private func setupUI() {
        view.backgroundColor = UIColor.white
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        tableView.layout(with: view).left().right()
        tableView.layout(with: topLayoutGuide).top(to: .bottom, by: Metrics.margin)
        tableView.layout(with: bottomLayoutGuide).bottom(to: .top)
    }

    private func setupRx() {

        // Rx to fill the table
        viewModel.wrappedInfoList.asObservable().bindNext { [weak self] carInfoList in
            self?.updateTableView(values: carInfoList, selectedValueIndex: self?.viewModel.selectedIndex, addOtherString: self?.viewModel.detailType.addOtherString)
        }.addDisposableTo(disposeBag)

        // Rx to select info
        tableView.selectedDetail.asObservable().bindNext { [weak self] detailSelectedInfo in
            guard let strongSelf = self else { return }
            guard !strongSelf.isDrawingInitialSelection else {
                strongSelf.isDrawingInitialSelection = false
                return
            }
            guard let selectedId = detailSelectedInfo?.id,
                let selectedName = detailSelectedInfo?.name,
                let selectedType = detailSelectedInfo?.type else { return }

            self?.viewModel.carInfoSelected(id: selectedId, name: selectedName, type: selectedType)
        }.addDisposableTo(disposeBag)
    }

    private func updateTableView(values: [CarInfoWrapper], selectedValueIndex: Int?, addOtherString: String?) {
        tableView.setupTableView(withDetailType: viewModel.detailType, values: values,
                                 selectedValueIndex: selectedValueIndex,
                                 addOtherString: addOtherString)

        guard let selectedIndex = selectedValueIndex, 0..<values.count ~= selectedIndex else { return }
        isDrawingInitialSelection = true
        tableView.selectedDetail.value = .index(i: selectedIndex, value: values[selectedIndex])
    }
}
