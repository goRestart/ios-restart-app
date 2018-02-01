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
    func postingAddDetailSummary(_ postingAddDetailSummary: PostingAddDetailSummaryTableView, didSelectIndex: PostingSummaryOption)
    func valueFor(section: PostingSummaryOption) -> String?
}

protocol PostingViewConfigurable {
    func setupView(viewModel: PostingDetailsViewModel)
    func setupContainerView(view: UIView)
}

enum PostingSummaryOption {
    case price
    case propertyType
    case offerType
    case bedrooms
    case rooms
    case sizeSquareMeters
    case bathrooms
    case location
    case make
    case model
    case year
    
    
    var postingDetailStep: PostingDetailStep {
        switch self {
        case .price:
            return .price
        case .propertyType:
            return .propertyType
        case .offerType:
            return .offerType
        case .bedrooms:
            return .bedrooms
        case .rooms:
            return .rooms
        case .sizeSquareMeters:
            return .sizeSquareMeters
        case .bathrooms:
            return .bathrooms
        case .location:
            return .location
        case .make:
            return .make
        case .model:
            return .model
        case .year:
            return .year
        }
    }
    
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
        case .rooms:
            return LGLocalizedString.realEstateSummaryRoomsEmpty
        case .sizeSquareMeters:
            return LGLocalizedString.realEstateSummarySizeEmpty
        case .bathrooms:
            return LGLocalizedString.realEstateSummaryBathroomsEmpty
        case .location:
            return LGLocalizedString.realEstateSummaryLocationEmpty
        case .make:
            return LGLocalizedString.postCategoryDetailAddMake
        case .model:
            return LGLocalizedString.postCategoryDetailAddModel
        case .year:
            return LGLocalizedString.postCategoryDetailCarYear
        }
    }
    static func optionsIncluded(with postCategory: PostCategory, postingFlowType: PostingFlowType) -> [PostingSummaryOption] {
        switch postCategory {
        case .car:
            return [.price, .make, .model, .year, .location]
        case .motorsAndAccessories, .otherItems:
            return [.price, .location]
        case .realEstate:
            return postingFlowType == .turkish ? [.price, .propertyType, .offerType, .rooms, .sizeSquareMeters, .location] : [.price, .propertyType, .offerType, .bedrooms, .bathrooms, .location]
        }
    }
}


final class PostingAddDetailSummaryTableView: UIView, UITableViewDelegate, UITableViewDataSource, PostingViewConfigurable {
    
    
    
    func setupContainerView(view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        layout(with: view).fill()
    }
    
    func setupView(viewModel: PostingDetailsViewModel) { }

    
    static let cellIdentifier = "PostingAddDetailSummaryCell"
    
    static let cellAddDetailSummaryHeight: CGFloat = 70
    static let cellAddLocationSummaryHeight: CGFloat = 150
    
    private var postingSummaryOptions: [PostingSummaryOption]
    private let tableView = UITableView()
    weak var delegate: PostingAddDetailSummaryTableViewDelegate?
    
    
    // MARK: - Lifecycle
    
    init(postCategory: PostCategory?, postingFlowType: PostingFlowType) {
        self.postingSummaryOptions = PostingSummaryOption.optionsIncluded(with: postCategory ?? .otherItems(listingCategory: nil),
                                                                          postingFlowType: postingFlowType)
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
        tableView.register(PostingAddDetailSummaryTableViewCell.self, forCellReuseIdentifier: PostingAddDetailSummaryTableView.cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.backgroundColor = .clear
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
        if indexPath.row == postingSummaryOptions.count - 1 {
            return PostingAddDetailSummaryTableView.cellAddLocationSummaryHeight
        } else {
            return PostingAddDetailSummaryTableView.cellAddDetailSummaryHeight
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostingAddDetailSummaryTableView.cellIdentifier) as? PostingAddDetailSummaryTableViewCell else {
            return UITableViewCell()
        }
        let sectionSummary = postingSummaryOptions[indexPath.row]
        if let text = getValueSelected(section: sectionSummary) {
           cell.textLabel?.text = text
        } else {
            cell.textLabel?.text = sectionSummary.emptyLocalizeString
            cell.imageView?.image = UIImage(named: "items")
            cell.imageView?.tintColor = UIColor.grayLighter
        }
        
        if indexPath.row == postingSummaryOptions.count - 1 {
            cell.showSeparator()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = tableView.cellForRow(at: indexPath) {
            delegate?.postingAddDetailSummary(self, didSelectIndex: postingSummaryOptions[indexPath.row])
        }
    }
    
    func setupTableView(values: [PostingSummaryOption]) {
        postingSummaryOptions = values
        tableView.reloadData()
    }
    
    func getValueSelected(section: PostingSummaryOption) -> String? {
        return delegate?.valueFor(section: section)
    }
}
