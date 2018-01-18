//
//  MostSearchedItemsListCell.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 04/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

protocol MostSearchedItemsListCellDelegate: class {
    func didSearchAction(itemName: String)
}

class MostSearchedItemsListCell: UITableViewCell, ReusableCell {
    
    static let cellHeight: CGFloat = 84
    
    let titleLabel = UILabel()
    let numberOfSearchesView = UIView()
    let numberOfSearchesImageView = UIImageView()
    let numberOfSearchesLabel = UILabel()
    let searchButton = UIButton(type: .custom)
    let postButton = UIButton(type: .custom)
    
    weak var delegate: MostSearchedItemsListCellDelegate?
    var item: LocalMostSearchedItem?
    
    // MARK: - Lifecycle
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        postButton.rounded = true
    }
    
    // TODO: Check if we need to implement prepareForReuse when further navigation is done
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        resetUI()
//    }
//
//    private func resetUI() {
//        accessoryType = .none
//    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        selectionStyle = .none
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 19)
        titleLabel.textColor = UIColor.black
        
        numberOfSearchesImageView.image = UIImage(named: "ic_search")
        
        // TODO: Localize strings
        numberOfSearchesLabel.font = UIFont.systemMediumFont(size: 13)
        numberOfSearchesLabel.textColor = UIColor.grayText
        numberOfSearchesLabel.text = "4,394 searches"
        numberOfSearchesLabel.adjustsFontSizeToFitWidth = true
        numberOfSearchesLabel.minimumScaleFactor = 0.2
        
        searchButton.setTitle("Search", for: .normal)
        searchButton.setTitleColor(UIColor.grayText, for: .normal)
        searchButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        searchButton.setImage(UIImage(named: "ic_search")?.withRenderingMode(.alwaysTemplate), for: .normal)
        searchButton.tintColor = UIColor.gray
        searchButton.centerTextAndImage(spacing: 4)
        searchButton.titleLabel?.adjustsFontSizeToFitWidth = true
        searchButton.titleLabel?.minimumScaleFactor = 0.2
        searchButton.addTarget(self, action: #selector(searchAction), for: .touchUpInside)
        
        postButton.setStyle(.primary(fontSize: .big))
        postButton.setTitle("Post", for: .normal)
        postButton.titleLabel?.adjustsFontSizeToFitWidth = true
        postButton.titleLabel?.minimumScaleFactor = 0.2
    }
    
    private func setupConstraints() {
        let containerSubviews = [titleLabel, numberOfSearchesView, searchButton, postButton]
        contentView.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: containerSubviews)
        contentView.addSubviews(containerSubviews)
        
        let numberOfSearchesSubviews = [numberOfSearchesImageView, numberOfSearchesLabel]
        numberOfSearchesView.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: numberOfSearchesSubviews)
        numberOfSearchesView.addSubviews(numberOfSearchesSubviews)
        
        titleLabel.layout(with: contentView)
            .leading(by: Metrics.bigMargin)
            .trailing(by: -Metrics.bigMargin)
            .top(by: Metrics.bigMargin)
        titleLabel.layout().height(23)
        
        numberOfSearchesView.layout(with: contentView)
            .leading()
            .bottom(by: -Metrics.bigMargin)
        numberOfSearchesView.layout(with: searchButton)
            .toRight(by: -Metrics.shortMargin)
        numberOfSearchesView.layout(with: titleLabel)
            .below(by: Metrics.shortMargin)
        
        numberOfSearchesImageView.layout(with: numberOfSearchesView)
            .fillVertical()
            .leading(by: Metrics.bigMargin)
        numberOfSearchesImageView.layout()
            .width(12)
            .height(12)
        
        numberOfSearchesLabel.layout(with: numberOfSearchesView)
            .fillVertical()
            .trailing(by: Metrics.shortMargin)
        numberOfSearchesLabel.layout(with: numberOfSearchesImageView)
            .leading(by: Metrics.margin)
        
        searchButton.layout(with: contentView)
            .centerY()
        searchButton.layout(with: postButton)
            .toRight(by: -Metrics.veryShortMargin)
        searchButton.layout()
            .width(100)
            .height(30)
        
        postButton.layout(with: contentView)
            .centerY()
            .trailing(by: -Metrics.bigMargin)
        postButton.layout()
            .width(75)
            .height(30)
    }
    
    func updateWith(item: LocalMostSearchedItem, showSearchButton: Bool) {
        self.item = item
        titleLabel.text = item.name
        numberOfSearchesLabel.text = item.searchCount
        searchButton.isHidden = showSearchButton
    }
    
    
    // MARK: - UI Actions
    
    @objc func searchAction() {
        guard let itemName = item?.name else { return }
        delegate?.didSearchAction(itemName: itemName)
    }
}
