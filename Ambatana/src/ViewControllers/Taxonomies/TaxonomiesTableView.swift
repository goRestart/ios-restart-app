//
//  TaxonomiesTableView.swift
//  LetGo
//
//  Created by Juan Iglesias on 20/07/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit

final class TaxonomiesTableView: UIView, UITableViewDelegate, UITableViewDataSource, TaxonomyHeaderViewDelegate {
    
    static let cellIdentifier = "taxonomyCell"
    
    private let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    private var taxonomies: [Taxonomy] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    let taxonomySelected = Variable<Taxonomy?>(nil)
    let taxonomyChildSelected = Variable<TaxonomyChild?>(nil)
    var selectedTaxonomy: Taxonomy?
    var selectedTaxonomyChild2: TaxonomyChild?
    
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: TaxonomiesTableView.cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.indicatorStyle = .white
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
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
    
    
    // MARK: - Accessibility
    
    private func setupAccessibilityIds() {
        tableView.accessibilityId = .taxonomiesTableView
    }
    
    
    // MARK: - UITableView delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taxonomies[section].children.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return taxonomies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaxonomiesTableView.cellIdentifier) else {
            return UITableViewCell()
        }
        let value = taxonomies[indexPath.section].children[indexPath.row]
        cell.selectionStyle = .none
        cell.textLabel?.text = value.name
        cell.textLabel?.font =  UIFont.systemBoldFont(size: 21)
        cell.textLabel?.textColor = UIColor.lgBlack
        cell.indentationLevel = 1
        cell.indentationWidth = 50
        
        if selectedTaxonomyChild2 == value {
            cell.accessoryType = .checkmark
            cell.tintColor = UIColor.redText
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = UIColor.redText
            cell.tintColor = UIColor.redText
            taxonomySelected.value = taxonomies[indexPath.section]
            taxonomyChildSelected.value = taxonomies[indexPath.section].children[indexPath.row]
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
            cell.textLabel?.textColor = UIColor.blackText
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let isSelected = taxonomies[section] == selectedTaxonomy && selectedTaxonomyChild2 == nil
        let view = TaxonomyHeaderView(taxonomy: taxonomies[section], isSelected: isSelected)
        view.delegate = self
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    func setupTableView(values: [Taxonomy], selectedTaxonomy: Taxonomy?, selectedTaxonomyChild2: TaxonomyChild?) {
        taxonomies = values
        self.selectedTaxonomy = selectedTaxonomy
        self.selectedTaxonomyChild2 = selectedTaxonomyChild2
        tableView.reloadData()
    }
    
    
    // MARK: - TaxonomyHeaderViewDelegate
    
    func didSelectTaxonomy(taxonomy: Taxonomy) {
        taxonomySelected.value = taxonomy
    }
}
