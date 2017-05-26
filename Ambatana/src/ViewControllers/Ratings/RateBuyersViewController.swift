//
//  RateBuyersViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 03/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit
import RxSwift


class RateBuyersViewController: BaseViewController {
    
    static fileprivate let headerTableViewHeight: CGFloat = 10
    static fileprivate let numberOfSections = 2
    static fileprivate let numberOfExtraButtons = 2

    fileprivate let mainView: RateBuyersView
    fileprivate let viewModel: RateBuyersViewModel

    private let disposeBag = DisposeBag()

    init(with viewModel: RateBuyersViewModel) {
        self.viewModel = viewModel
        self.mainView = RateBuyersView()
        super.init(viewModel: viewModel, nibName: nil, navBarBackgroundStyle: .transparent(substyle: .light))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupRx()
    }

    // MARK: - Private

    private func setupUI() {
        automaticallyAdjustsScrollViewInsets = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: .plain,
                                                           target: self, action: #selector(closeButtonPressed))

        mainView.translatesAutoresizingMaskIntoConstraints = false
        mainView.addToViewController(self, inView: view)

        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self
        mainView.tableView.rowHeight = PossibleBuyerCell.cellHeight
        mainView.tableView.backgroundColor = UIColor.clear

        let cellNib = UINib(nibName: PossibleBuyerCell.reusableID, bundle: nil)
        mainView.tableView.register(cellNib, forCellReuseIdentifier: PossibleBuyerCell.reusableID)
    }

    private func setupRx() {
        viewModel.visibilityFormat.asObservable().bindNext { [weak self] _ in
            self?.mainView.tableView.reloadData()
        }.addDisposableTo(disposeBag)
    }
    
    dynamic private func closeButtonPressed() {
        viewModel.closeButtonPressed()
    }
}


// MARK: - TableView delegate & datasource

extension RateBuyersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel.buyersToShow + 1
        } else {
            return RateBuyersViewController.numberOfExtraButtons
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return RateBuyersViewController.numberOfSections
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let buyerCell = tableView.dequeueReusableCell(withIdentifier: PossibleBuyerCell.reusableID,
                                                            for: indexPath) as? PossibleBuyerCell else { return UITableViewCell() }
        
        let cellType: RateBuyerCellType
        let image: URL?
        let title: String?
        let subtitle: String?
        let topBorder: Bool
        let bottomBorder: Bool
        let disclosureDirection: DisclosureDirection
        
        switch indexPath.section {
        case 0:
            cellType = viewModel.cellTypeAt(index: indexPath.row)
            image = viewModel.imageAt(index: indexPath.row)
            title = viewModel.titleAt(index: indexPath.row)
            subtitle = nil
            topBorder = viewModel.topBorderAt(index: indexPath.row)
            bottomBorder = viewModel.bottomBorderAt(index: indexPath.row)
            disclosureDirection = viewModel.disclosureDirectionAt(index: indexPath.row)
        case 1:
            cellType = .otherCell
            image = nil
            topBorder = true
            disclosureDirection = .right
            bottomBorder = true
            title = viewModel.secondaryOptionsTitleAt(index: indexPath.row)
            subtitle = viewModel.secondaryOptionsSubtitleAt(index: indexPath.row)
        default:
            return UITableViewCell() // it should not happen
        }
        buyerCell.setupWith(cellType: cellType,
                            image: image,
                            title: title,
                            subtitle: subtitle,
                            topBorder: topBorder,
                            bottomBorder: bottomBorder,
                            disclouseDirection: disclosureDirection)
        return buyerCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section == 1 else { return 0 }
        return RateBuyersViewController.headerTableViewHeight
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scroll = scrollView.contentOffset.y + scrollView.contentInset.top
        mainView.headerTopMarginConstraint.constant = -scroll
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row < viewModel.buyersToShow {
                tableView.deselectRow(at: indexPath, animated: true)
                viewModel.selectedBuyerAt(index: indexPath.row)
            } else {
                viewModel.showMoreLessPressed()
            }
        } else {
            if indexPath.row == 0 {
                viewModel.notOnLetgoButtonPressed()
            } else {
                viewModel.closeButtonPressed()
            }
        }
    }
}

extension VisibilityFormat {
    var disclouseDirection: DisclosureDirection {
        switch self {
        case .compact:
            return .down
        case .full:
            return .up
        }
    }
}
