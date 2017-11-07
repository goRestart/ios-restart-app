//
//  PostingAddDetailSummaryTableViewCell.swift
//  LetGo
//
//  Created by Juan Iglesias on 20/07/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

class PostingAddDetailSummaryTableViewCell: UITableViewCell {
    
    private let separatorView = UIView()
    
    
    // MARK: - Lifecycle
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupLayout()
    }
    
    override func prepareForReuse() {
        separatorView.isHidden = true
    }
    
    // MARK: - UI
    
    private func setupUI() {
        textLabel?.font = UIFont.selectableItem
        backgroundColor = UIColor.clear
        textLabel?.textColor = UIColor.grayLight
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        separatorView.backgroundColor = UIColor.grayLighter
        separatorView.isHidden = true
    }
    
    private func setupLayout() {
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorView)
        separatorView.layout(with: self).top(by: Metrics.bigMargin).fillHorizontal(by: Metrics.bigMargin)
        separatorView.layout().height(1)
    }
    
    func showSeparator() {
        separatorView.isHidden = false
    }
}
