//
//  CategoryDetailTableView.swift
//  LetGo
//
//  Created by Nestor on 12/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit
import RxSwift
import LGCoreKit

enum CategoryDetailStyle {
    case lightContent // Light content, for use on dark backgrounds
    case darkContent // Dark content, for use on light backgrounds
    
    var cellTextColor: UIColor {
        switch self {
        case .lightContent:
            return UIColor.whiteTextHighAlpha
        case .darkContent:
            return UIColor.blackTextHighAlpha
        }
    }
    
    var cellSelectedTextColor: UIColor {
        switch self {
        case .lightContent:
            return UIColor.white
        case .darkContent:
            return UIColor.blackText
        }
    }
    
    var cellBackgroundColor: UIColor {
        switch self {
        case .lightContent:
            return UIColor.clear
        case .darkContent:
            return UIColor.white
        }
    }
    
    var tableViewBackgroundColor: UIColor {
        switch self {
        case .lightContent:
            return UIColor.clear
        case .darkContent:
            return UIColor.white
        }
    }
    
    var tableViewTintColor: UIColor {
        switch self {
        case .lightContent:
            return UIColor.white
        case .darkContent:
            return UIColor.primaryColor
        }
    }

    var othersIconTintColor: UIColor {
        switch self {
        case .lightContent:
            return UIColor.white
        case .darkContent:
            return UIColor.blackText
        }
    }

    var searchBackgroundColor: UIColor {
        switch self {
        case .lightContent:
            return UIColor.white.withAlphaComponent(0.2)
        case .darkContent:
            return UIColor.grayBackground
        }
    }
    var searchIconColor: UIColor {
        switch self {
        case .lightContent:
            return UIColor.white
        case .darkContent:
            return UIColor.blackTextLowAlpha
        }
    }
    
    var searchTextColor: UIColor {
        switch self {
        case .lightContent:
            return UIColor.white
        case .darkContent:
            return UIColor.blackTextHighAlpha
        }
    }

    var placeholderTextColor: UIColor {
        switch self {
        case .lightContent:
            return UIColor.whiteTextHighAlpha
        case .darkContent:
            return UIColor.blackTextHighAlpha
        }
    }
}

enum CarDetailType {
    case make
    case model
    case year
    
    var addOtherString: String? {
        switch self {
        case .make: return LGLocalizedString.postCategoryDetailAddMake
        case .model: return LGLocalizedString.postCategoryDetailAddModel
        case .year: return nil
        }
    }
    
    static public func ==(lhs: CarDetailType, rhs: CarDetailType) -> Bool {
        switch (lhs, rhs) {
        case (.make, .make), (.model, .model), (.year, .year):
            return true
        default:
            return false
        }
    }
}

struct CarInfoWrapper: Equatable {
    let id: String // for Others it will be "", for year it will be equal to name
    let name: String
    let type: CarDetailType

    public static func ==(lhs: CarInfoWrapper, rhs: CarInfoWrapper) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.type == rhs.type
    }
}

enum CategoryDetailSelectedInfo {
    case index(i: Int, value: CarInfoWrapper)
    case custom(value: CarInfoWrapper) // for 'Others' options
    
    var name: String {
        switch self {
        case .index(_, let value): return value.name
        case .custom(let value): return value.name
        }
    }
    
    var id: String {
        switch self {
        case .index(_, let value): return value.id
        case .custom(let value): return value.id
        }
    }
    
    var type: CarDetailType {
        switch self {
        case .index(_, let value): return value.type
        case .custom(let value): return value.type
        }
    }
}

final class CategoryDetailTableView: UIView, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    static let cellIdentifier = "categoryDetailCell"
    
    private let style: CategoryDetailStyle
    private var rawValues: [CarInfoWrapper] = []
    private var filteredValues: [CarInfoWrapper] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private var addOtherString: String?
    private var detailType: CarDetailType = .make
    
    let selectedDetail = Variable<CategoryDetailSelectedInfo?>(nil)
    
    // MARK: - Lifecycle
    
    init(withStyle style: CategoryDetailStyle) {
        self.style = style
        
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CategoryDetailTableView.cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.backgroundColor = style.tableViewBackgroundColor
        tableView.tintColor = style.tableViewTintColor
        tableView.indicatorStyle = .white
        tableView.keyboardDismissMode = .onDrag
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Metrics.margin, right: 0)
        
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
        searchBar.barStyle = .default
        searchBar.barTintColor = UIColor.clear
        searchBar.backgroundColor = nil
        searchBar.tintColor = UIColor.redText
        let imageWithColor = UIImage.imageWithColor(style.searchBackgroundColor,
                                           size: CGSize(width: Metrics.screenWidth-Metrics.margin*2, height: 44))
        let searchBarBackground = UIImage.roundedImage(image: imageWithColor, cornerRadius: 10)
        searchBar.setSearchFieldBackgroundImage(nil, for: .normal)
        searchBar.setBackgroundImage(searchBarBackground, for: .any, barMetrics: .default)
        searchBar.searchTextPositionAdjustment = UIOffsetMake(10, 0);
        
        if let textField: UITextField = searchBar.firstSubview(ofType: UITextField.self) {
            textField.font = UIFont.bigBodyFont
            textField.clearButtonMode = .never
            textField.backgroundColor = UIColor.clear
            textField.textColor = style.searchTextColor
            textField.attributedPlaceholder =
                NSAttributedString(string: LGLocalizedString.postCategoryDetailSearchPlaceholder,
                    attributes: [NSForegroundColorAttributeName: style.placeholderTextColor])
            if let iconSearchImageView = textField.leftView as? UIImageView {
                iconSearchImageView.image = iconSearchImageView.image?.withRenderingMode(.alwaysTemplate)
                iconSearchImageView.tintColor = style.searchIconColor
            }
        }
    }
    
    private func setupLayout() {
        let subviews = [searchBar, tableView]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        addSubviews(subviews)
        
        searchBar.layout()
            .height(44)
        searchBar.layout(with: self)
            .top()
            .leading(by: Metrics.margin)
            .trailing(by: -Metrics.margin)
        searchBar.layout(with: tableView)
            .bottom(to: .top, by: -Metrics.margin)
        tableView.layout(with: self)
            .bottom()
            .leading(by: Metrics.margin)
            .trailing(by: -Metrics.margin)
    }
    
    // MARK: - Accessibility
    
    private func setupAccessibilityIds() {
        searchBar.accessibilityId = .postingCategoryDeatilSearchBar
        tableView.accessibilityId = .postingCategoryDeatilTableView
    }
    
    // MARK: - UISearchBar delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredValues = rawValues
        } else {
            // we want to show "Other" always ---> $0.id == ""
            filteredValues = rawValues.filter { $0.name.lowercased().contains(searchText.lowercased()) || $0.id == "" }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - UITableView delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredValues.count + (shouldAddOtherCell() ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if shouldAddOtherCell() && isOtherCell(forIndexPath: indexPath) {
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            cell.textLabel?.text = addOtherString
            cell.textLabel?.font = UIFont.systemBoldFont(size: 17)
            cell.backgroundColor = style.cellBackgroundColor
            cell.textLabel?.textColor = style.cellSelectedTextColor
            cell.imageView?.image = UIImage(named: "ic_cirle_plus")?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.tintColor = style.othersIconTintColor
            cell.imageView?.contentMode = .left
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryDetailTableView.cellIdentifier) else {
            return UITableViewCell()
        }
        let value = filteredValues[indexPath.row]
        let selected = isValueSelected(value)
        cell.selectionStyle = .none
        cell.textLabel?.text = value.name
        cell.textLabel?.font = selected ? UIFont.mediumButtonFont : UIFont.bigBodyFont
        cell.accessoryType = selected ? .checkmark : .none
        cell.backgroundColor = style.cellBackgroundColor
        cell.textLabel?.textColor = selected ? style.cellSelectedTextColor : style.cellTextColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !isOtherCell(forIndexPath: indexPath) else {
            if let searchBarText = searchBar.text, !searchBarText.isEmpty {
                selectedDetail.value = .custom(value: CarInfoWrapper(id: "", name: searchBarText, type: detailType))
                searchBar.resignFirstResponder()
            } else {
                searchBar.becomeFirstResponder()
            }
            return
        }
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = style.cellSelectedTextColor
            cell.textLabel?.font = UIFont.mediumButtonFont
        }
        
        searchBar.resignFirstResponder()
        
        let value = filteredValues[indexPath.row]
        guard let index = rawValues.index(of: value) else { return }
        selectedDetail.value = .index(i: index, value: value)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
            cell.textLabel?.textColor = style.cellTextColor
        }
    }
    
    private func isValueSelected(_ value: CarInfoWrapper) -> Bool {
        if let selectedId = selectedDetail.value?.id, selectedId == value.id {
            return true
        }
        return false
    }
    
    private func isOtherCell(forIndexPath indexPath: IndexPath) -> Bool {
        return indexPath.row == filteredValues.count
    }
    
    private func shouldAddOtherCell() -> Bool {
        if let addOtherString = addOtherString, !addOtherString.isEmpty {
            return true
        }
        return false
    }
    
    // MARK: - Public methods
    
    func hideKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    func setupTableView(withDetailType type: CarDetailType, values: [CarInfoWrapper], selectedValueIndex: Int?, addOtherString: String?) {
        searchBar.text = nil
        searchBar.keyboardType = type == .year ? .numberPad : .default
        self.addOtherString = addOtherString
        detailType = type
        rawValues = values
        filteredValues = values

        layoutIfNeeded() // Forces the tableView to be properly drawn before scroll to position
        if let selectedIndex = selectedValueIndex, selectedIndex < filteredValues.count {
            let indexPath = IndexPath(row: selectedIndex, section: 0)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark
                cell.textLabel?.textColor = style.cellSelectedTextColor
                cell.textLabel?.font = UIFont.mediumButtonFont
            }
        } else {
            tableView.setContentOffset(CGPoint.zero, animated: false)
        }
    }
}
