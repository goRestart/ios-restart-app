//
//  TaxonomiesTableView.swift
//  LetGo
//
//  Created by Juan Iglesias on 20/07/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit

final class TaxonomiesTableView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    static let cellIdentifier = "taxonomyCell"
    static let taxonomyCellIdentifier = "taxonomyCellIdentifier"
    
    private let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    private var taxonomies: [Taxonomy] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    let taxonomySelection = Variable<Taxonomy?>(nil)
    let taxonomyChildSelection = Variable<TaxonomyChild?>(nil)
    var selectedTaxonomy: Taxonomy?
    var selectedTaxonomyChild: TaxonomyChild?
    
    
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
    
    
    // MARK: - UI
    
    private func setupUI() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: TaxonomiesTableView.cellIdentifier)
        tableView.register(TaxonomyTableViewCell.self, forCellReuseIdentifier: TaxonomiesTableView.taxonomyCellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.indicatorStyle = .white
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);
    }
    
    private func setupLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        
        tableView.layout(with: self)
            .top(by: 10)
            .bottom()
            .leading()
            .trailing()
    }
    
    private func setupAccessibilityIds() {
        tableView.accessibilityId = .taxonomiesTableView
    }
    
    func setupTableView(values: [Taxonomy], selectedTaxonomy: Taxonomy?, selectedTaxonomyChild: TaxonomyChild?) {
        taxonomies = values
        self.selectedTaxonomy = selectedTaxonomy
        self.selectedTaxonomyChild = selectedTaxonomyChild
        tableView.reloadData()
    }
    
    
    // MARK: - UITableViewDataSource, UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taxonomies[section].children.count + 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return taxonomies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TaxonomiesTableView.taxonomyCellIdentifier) as? TaxonomyTableViewCell else {
                return UITableViewCell()
            }
            let value = taxonomies[indexPath.section]
            cell.updateWith(text: value.name, iconURL: value.icon, selected: selectedTaxonomy == value)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TaxonomiesTableView.cellIdentifier) else {
                return UITableViewCell()
            }
            let value = taxonomies[indexPath.section].children[indexPath.row-1]
            cell.selectionStyle = .none
            cell.textLabel?.text = value.name
            cell.textLabel?.font =  UIFont.systemBoldFont(size: 21)
            cell.textLabel?.textColor = UIColor.lgBlack
            cell.indentationLevel = 1
            cell.indentationWidth = 50
            
            if selectedTaxonomyChild == value {
                cell.accessoryType = .checkmark
                cell.tintColor = UIColor.redText
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0, let cell = tableView.cellForRow(at: indexPath) as? TaxonomyTableViewCell {
            cell.highlight()
            taxonomySelection.value = taxonomies[indexPath.section]
        } else if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = UIColor.redText
            cell.tintColor = UIColor.redText
            taxonomySelection.value = taxonomies[indexPath.section]
            taxonomyChildSelection.value = taxonomies[indexPath.section].children[indexPath.row-1]
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
            cell.textLabel?.textColor = UIColor.blackText
        }
    }
}
