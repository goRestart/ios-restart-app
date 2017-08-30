//
//  RateBuyersViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 03/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

enum RateBuyersSection: Int {
    case possibleBuyers = 0
    case otherActions = 1
}

class RateBuyersViewController: BaseViewController, RateBuyersViewModelDelegate {
    
    static fileprivate let headerTableViewHeight: CGFloat = 200
    static fileprivate let numberOfSections = 2
    static fileprivate let numberOfExtraButtons = 2
    static fileprivate let topContentInsetTableView: CGFloat = 80

    fileprivate let mainHeader: RateBuyersHeader
    fileprivate let tableView: UITableView
    fileprivate let viewModel: RateBuyersViewModel

    private let disposeBag = DisposeBag()

    init(with viewModel: RateBuyersViewModel) {
        self.viewModel = viewModel
        self.mainHeader = RateBuyersHeader(source: viewModel.source)
        self.tableView = UITableView(frame: CGRect.zero, style: .grouped)
        super.init(viewModel: viewModel, nibName: nil, navBarBackgroundStyle: .transparent(substyle: .light))
        
        viewModel.delegate = self
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

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.addToViewController(self, inView: view)
        tableView.layout(with: view).top().left().right().bottom()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = PossibleBuyerCell.cellHeight
        tableView.backgroundColor = UIColor.clear
        tableView.contentInset = UIEdgeInsets(top: RateBuyersViewController.topContentInsetTableView,
                                              left: 0,
                                              bottom: Metrics.shortMargin,
                                              right: 0)
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension

        let cellNib = UINib(nibName: PossibleBuyerCell.reusableID, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: PossibleBuyerCell.reusableID)
    }

    private func setupRx() {
        viewModel.visibilityFormat.asObservable().bindNext { [weak self] _ in
            self?.tableView.reloadData()
        }.addDisposableTo(disposeBag)
    }
    
    dynamic private func closeButtonPressed() {
        viewModel.closeButtonPressed()
    }
}


// MARK: - TableView delegate & datasource

extension RateBuyersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let rateBuyersSection = RateBuyersSection(rawValue: section) else { return 0 }
        switch rateBuyersSection {
        case .possibleBuyers:
            return viewModel.shouldShowSeeMoreOption ? viewModel.buyersToShow + 1 : viewModel.buyersToShow
        case .otherActions:
            return RateBuyersViewController.numberOfExtraButtons
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return RateBuyersViewController.numberOfSections
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let buyerCell = tableView.dequeueReusableCell(withIdentifier: PossibleBuyerCell.reusableID,
                                                            for: indexPath) as? PossibleBuyerCell else { return UITableViewCell() }
        guard let rateBuyersSection = RateBuyersSection(rawValue: indexPath.section) else { return UITableViewCell() }
        
        let cellType: RateBuyerCellType
        let image: URL?
        let title: String?
        let subtitle: String?
        let topBorder: Bool
        let bottomBorder: Bool
        let disclosureDirection: DisclosureDirection
        
        switch rateBuyersSection {
        case .possibleBuyers:
            cellType = viewModel.cellTypeAt(index: indexPath.row)
            image = viewModel.imageAt(index: indexPath.row)
            title = viewModel.titleAt(index: indexPath.row)
            subtitle = nil
            topBorder = viewModel.topBorderAt(index: indexPath.row)
            bottomBorder = viewModel.bottomBorderAt(index: indexPath.row)
            disclosureDirection = viewModel.disclosureDirectionAt(index: indexPath.row)
        case .otherActions:
            cellType = .otherCell
            image = nil
            topBorder = viewModel.secondaryActionstopBorderAt(index: indexPath.row)
            disclosureDirection = .right
            bottomBorder = viewModel.secondaryActionsbottomBorderAt(index: indexPath.row)
            title = viewModel.secondaryOptionsTitleAt(index: indexPath.row)
            subtitle = viewModel.secondaryOptionsSubtitleAt(index: indexPath.row)
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let rateBuyersSection = RateBuyersSection(rawValue: section) else { return nil }
        switch rateBuyersSection {
        case .possibleBuyers:
            return mainHeader
        case .otherActions:
            let view = UIView()
            view.backgroundColor = UIColor.grayBackground
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        guard let rateBuyersSection = RateBuyersSection(rawValue: section) else { return 0 }
        switch rateBuyersSection {
        case .possibleBuyers:
            return RateBuyersViewController.headerTableViewHeight
        case .otherActions:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let rateBuyersSection = RateBuyersSection(rawValue: indexPath.section) else { return }
        switch rateBuyersSection {
        case .possibleBuyers:
            if indexPath.row < viewModel.buyersToShow {
                tableView.deselectRow(at: indexPath, animated: true)
                viewModel.selectedBuyerAt(index: indexPath.row)
            } else {
                viewModel.showMoreLessPressed()
            }
        case .otherActions:
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
