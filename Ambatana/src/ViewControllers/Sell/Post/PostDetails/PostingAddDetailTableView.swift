//
//  PostingAddDetailTableView.swift
//  LetGo
//
//  Created by Juan Iglesias on 10/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit



final class PostingAddDetailTableView: UIView, UITableViewDelegate, UITableViewDataSource {
        
        static let cellIdentifier = "postingAddDetailCell"
    
        private var values: [String] = [] {
            didSet {
                tableView.reloadData()
            }
        }
    
        private let tableView = UITableView()
        
        let selectedDetail = Variable<CategoryDetailSelectedInfo?>(nil)
        
        // MARK: - Lifecycle
        
        init() {
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
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: PostingAddDetailTableView.cellIdentifier)
            tableView.delegate = self
            tableView.dataSource = self
            tableView.separatorStyle = UITableViewCellSeparatorStyle.none
            tableView.backgroundColor = UIColor.clear
            tableView.tintColor = UIColor.white
            tableView.indicatorStyle = .white
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Metrics.margin, right: 0)
        }
        
        private func setupLayout() {
            tableView.translatesAutoresizingMaskIntoConstraints = false
            addSubviews(subviews)
           
            tableView.layout(with: self)
                .top()
                .bottom()
                .leading(by: Metrics.margin)
                .trailing(by: -Metrics.margin)
        }
        
        // MARK: - Accessibility
        
        private func setupAccessibilityIds() {
            tableView.accessibilityId = .postingCategoryDeatilTableView
        }
    
        // MARK: - UITableView delegate
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return values.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryDetailTableView.cellIdentifier) else {
                return UITableViewCell()
            }
            let value = values[indexPath.row]
           // let selected = isValueSelected(value)
            cell.selectionStyle = .none
            cell.textLabel?.text = value
            cell.textLabel?.font = UIFont.mediumButtonFont
           // cell.accessoryType = selected ? .checkmark : .none
            cell.backgroundColor = UIColor.clear
            cell.textLabel?.textColor = UIColor.white
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark
                cell.textLabel?.textColor = UIColor.white
                cell.textLabel?.font = UIFont.mediumButtonFont
            }
            
//            
//            let value = values[indexPath.row]
//            guard let index = rawValues.index(of: value) else { return }
//            selectedDetail.value = .index(i: index, value: value)
        }
        
        func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .none
                cell.textLabel?.textColor = UIColor.white
            }
        }
}
