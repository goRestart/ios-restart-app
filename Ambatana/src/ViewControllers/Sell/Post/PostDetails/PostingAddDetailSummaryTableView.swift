//
//  PostingAddDetailSummaryTableView.swift
//  LetGo
//
//  Created by Juan Iglesias on 23/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit

protocol PostingAddDetailSummaryTableViewDelegate: class {
    func postingAddDetailSummary(_ postingAddDetailSummary: PostingAddDetailSummaryTableView, didSelectIndex: Int)
    func valueFor(section: PostingSummaryOption) -> String
}

enum PostingSummaryOption {
    case price
    case propertyType
    case offerType
    case bedrooms
    case bathrooms
    case location
    case make
    case model
    case year
    
    var emptyLocalizeString: String {
        switch self {
        case .price:
            return LGLocalizedString.realEstateSummaryPriceEmpty
        case .propertyType:
            return LGLocalizedString.realEstateSummaryTypePropertyEmpty
        case .offerType:
            return LGLocalizedString.realEstateSummaryOfferTypeEmpty
        case .bedrooms:
            return LGLocalizedString.realEstateSummaryBedroomsEmtpy
        case .bathrooms:
            return LGLocalizedString.realEstateSummaryBathroomsEmpty
        case .location:
            return LGLocalizedString.realEstateSummaryLocationEmpty
        case .make:
            return LGLocalizedString.postCategoryDetailAddMake
        case .model:
            return LGLocalizedString.postCategoryDetailAddModel
        case .year:
            return ""
        }
    }
    static func optionsIncluded(with postCategory: PostCategory) -> [PostingSummaryOption] {
        switch postCategory {
        case .car:
            return [.price, .make, .model, .year, .location]
        case .motorsAndAccessories, .unassigned:
            return [.price, .location]
        case .realEstate:
            return [.price, .propertyType, .offerType, .bedrooms, .bathrooms, .location]
        }
    }
}


final class PostingAddDetailSummaryTableView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    static let cellIdentifier = "PostingAddDetailSummaryCell"
    static let cellAddDetailHeight: CGFloat = 67
    
    private var postingSummaryOptions: [PostingSummaryOption]
    private let tableView = UITableView()
    weak var delegate: PostingAddDetailSummaryTableViewDelegate?
    
    
    // MARK: - Lifecycle
    
    init(postCategory: PostCategory?) {
        self.postingSummaryOptions = PostingSummaryOption.optionsIncluded(with: postCategory ?? .unassigned)
        super.init(frame: CGRect.zero)
        setupUI()
        setupAccessibilityIds()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Layout
    
    private func setupUI() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: PostingAddDetailSummaryTableView.cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.backgroundColor = UIColor.clear
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Metrics.margin, right: 0)
    }
    
    private func setupLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        
        tableView.layout(with: self)
            .top()
            .bottom()
            .leading()
            .trailing()
        setupTableView(values: postingSummaryOptions)
    }
    
    // MARK: - Accessibility
    
    private func setupAccessibilityIds() {
        tableView.accessibilityId = .postingAddDetailTableView
    }
    
    
    // MARK: - UITableView delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postingSummaryOptions.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PostingAddDetailSummaryTableView.cellAddDetailHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostingAddDetailSummaryTableView.cellIdentifier) else {
            return UITableViewCell()
        }
        let sectionSummary = postingSummaryOptions[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = setValue(section: sectionSummary)
        cell.textLabel?.font = UIFont.selectableItem
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.grayLight
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.textLabel?.textColor = UIColor.white
            delegate?.postingAddDetailSummary(self, didSelectIndex: indexPath.row)
        }
    }
    
    func setupTableView(values: [PostingSummaryOption]) {
        postingSummaryOptions = values
        tableView.reloadData()
    }
    
    func setValue(section: PostingSummaryOption) -> String {
        return delegate?.valueFor(section: section) ?? section.emptyLocalizeString
    }
}
