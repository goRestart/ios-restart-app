//
//  PostingAddDetailTableView.swift
//  LetGo
//
//  Created by Juan Iglesias on 10/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit

protocol PostingAddDetailTableViewDelegate: class {
    func indexSelected(index: Int)
}


final class PostingAddDetailTableView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    static let cellIdentifier = "postingAddDetailCell"
    static let cellAddDetailHeight: CGFloat = 67
    
    private var contentCell: [String]
    private let tableView = UITableView()
    private var selectedValue: IndexPath?
    weak var delegate: PostingAddDetailTableViewDelegate?
    
    
    // MARK: - Lifecycle
    
    init(values: [String]) {
        self.contentCell = values
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
        addSubview(tableView)
        
        tableView.layout(with: self)
            .top()
            .bottom()
            .leading()
            .trailing()
        
        setupTableView(values: contentCell)
    }
    
    // MARK: - Accessibility
    
    private func setupAccessibilityIds() {
        tableView.accessibilityId = .postingAddDetailTableView
    }
    
    
    // MARK: - UITableView delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentCell.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PostingAddDetailTableView.cellAddDetailHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostingAddDetailTableView.cellIdentifier) else {
            return UITableViewCell()
        }
        let value = contentCell[indexPath.row]
        cell.selectionStyle = .none
        cell.textLabel?.text = value
        cell.textLabel?.font = UIFont.selectableItem
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.grayLight
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if let selectedValue = selectedValue, let cellAlreadySelected = tableView.cellForRow(at: selectedValue) {
                cellAlreadySelected.accessoryType = .none
                cellAlreadySelected.accessoryView = nil
                cellAlreadySelected.textLabel?.textColor = UIColor.grayLight
            }
            
            let image = #imageLiteral(resourceName: "ic_checkmark").withRenderingMode(.alwaysTemplate)
            let checkmark  = UIImageView()
            checkmark.image = image
            checkmark.tintColor = UIColor.white
            cell.accessoryView = checkmark
            
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = UIColor.white
            selectedValue = indexPath
            delegate?.indexSelected(index: indexPath.row)
            
        }
    }
    
    func setupTableView(values: [String]) {
        contentCell = values
        tableView.reloadData()
    }
}
