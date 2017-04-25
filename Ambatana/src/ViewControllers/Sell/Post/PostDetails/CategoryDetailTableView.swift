//
//  CategoryDetailTableView.swift
//  LetGo
//
//  Created by Nestor on 12/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

enum CategoryDetailStyle {
    case lightContent // Light content, for use on dark backgrounds
    case darkContent // Dark content, for use on light backgrounds
}

enum CategoryDetailSelectedInfo {
    case index(Int)
    case custom(string: String) // for 'Others' options
}

final class CategoryDetailTableView: UIView, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    static let cellIdentifier = "categoryDetailCell"
    
    private let style: CategoryDetailStyle
    private var values: [String] = []
    private var selectedIndex: Int? = nil
    
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    
    var selectedDetail: Observable<CategoryDetailSelectedInfo> {
        return selectedDetailPublishSubject.asObservable()
    }
    private let selectedDetailPublishSubject = PublishSubject<CategoryDetailSelectedInfo>()
    
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

        let searchIconColor: UIColor
        let searchTextColor: UIColor
        switch style {
        case .lightContent:
            tableView.backgroundColor = UIColor.clear
            tableView.tintColor = UIColor.white
            searchIconColor = UIColor.white
            searchTextColor = UIColor.white
        case .darkContent:
            tableView.backgroundColor = UIColor.white
            tableView.tintColor = UIColor.primaryColor
            searchIconColor = UIColor.green
            searchTextColor = UIColor.blackTextHighAlpha
            break
        }
        
        searchBar.delegate = self
        searchBar.barStyle = .default
        searchBar.barTintColor = UIColor.clear
        searchBar.backgroundColor = nil
        searchBar.tintColor = UIColor.redText
        let imageWithColor = UIImage.imageWithColor(UIColor.white.withAlphaComponent(0.2),
                                           size: CGSize(width: Metrics.screenWidth-Metrics.margin*2, height: 44))
        let searchBarBackground = UIImage.roundedImage(image: imageWithColor, cornerRadius: 10)
        searchBar.setSearchFieldBackgroundImage(nil, for: .normal)
        searchBar.setBackgroundImage(searchBarBackground, for: .any, barMetrics: .default)
        searchBar.searchTextPositionAdjustment = UIOffsetMake(10, 0);
        
        if let textField: UITextField = searchBar.firstSubview(ofType: UITextField.self) {
            textField.clearButtonMode = .never
            textField.backgroundColor = UIColor.clear
            textField.textColor = searchTextColor
            textField.attributedPlaceholder =
                NSAttributedString(string: LGLocalizedString.postCategoryDetailSearchPlaceholder,
                    attributes: [NSForegroundColorAttributeName: UIColor.whiteTextHighAlpha])
            if let iconSearchImageView = textField.leftView as? UIImageView {
                iconSearchImageView.image = iconSearchImageView.image?.withRenderingMode(.alwaysTemplate)
                iconSearchImageView.tintColor = searchIconColor
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
        
    }
    
    // MARK: - UISearchBar delegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

    }
    
    // MARK: - UITableView delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryDetailTableView.cellIdentifier) else {
            return UITableViewCell()
        }
        cell.textLabel?.text = values[indexPath.row]
        cell.selectionStyle = .none
        switch style {
        case .lightContent:
            cell.backgroundColor = UIColor.clear
            cell.textLabel?.textColor = UIColor.whiteTextHighAlpha
        case .darkContent:
            cell.backgroundColor = UIColor.white
            cell.textLabel?.textColor = UIColor.blackTextHighAlpha
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedDetailPublishSubject.onNext(.index(indexPath.row))
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            switch style {
            case .lightContent:
                cell.textLabel?.textColor = UIColor.white
                cell.textLabel?.font = UIFont.bigBodyFont
            case .darkContent:
                cell.textLabel?.textColor = UIColor.blackText
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
            switch style {
            case .lightContent:
                cell.textLabel?.textColor = UIColor.whiteTextHighAlpha
            case .darkContent:
                cell.textLabel?.textColor = UIColor.blackTextHighAlpha
            }
        }
    }
    
    // MARK: - Public methods
    
    func setupTableView(withValues values: [String], selectedValueIndex: Int?) {
        self.values = values
        tableView.reloadData()
        if let selectedIndex = selectedValueIndex, selectedIndex < values.count {
            let indexPath = IndexPath(row: selectedIndex, section: 0)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
        }
    }
}
