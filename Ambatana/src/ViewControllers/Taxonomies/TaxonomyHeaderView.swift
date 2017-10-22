//
//  TaxonomyHeaderView.swift
//  LetGo
//
//  Created by Juan Iglesias on 20/07/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

protocol TaxonomyHeaderViewDelegate: class {
    func didSelectTaxonomy(taxonomy: Taxonomy)
}

class TaxonomyHeaderView: UIView {
    
    weak var delegate: TaxonomyHeaderViewDelegate?
    private let taxonomy: Taxonomy
    private let isSelected: Bool
    
    private let containerView = UIView()
    private let label = UILabel()
    private let iconView = UIImageView()
    private let selectionButton = UIButton()
    private let checkmarkImageView = UIImageView()
    
    
    // MARK: - Lifecycle
    
    init(taxonomy: Taxonomy, isSelected: Bool) {
        self.taxonomy = taxonomy
        self.isSelected = isSelected
        super.init(frame: CGRect.zero)
        setupUI()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        iconView.contentMode = .scaleAspectFit
        label.font = UIFont.smallBodyFont
        label.textColor = UIColor.grayDark
        label.numberOfLines = 1
        label.textAlignment = .left
        
        label.text = taxonomy.name.uppercased()
        if let url = taxonomy.icon {
            iconView.lg_setImageWithURL(url)
        }
        
        selectionButton.addTarget(self, action:#selector(headerTap), for: .touchUpInside)
        
        if isSelected {
            checkmarkImageView.image = UIImage(named: "ic_checkmark")
        }
    }
    
    private func setupLayout() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: [containerView, iconView, label, selectionButton, checkmarkImageView])
        
        addSubview(containerView)
        containerView.addSubviews([iconView, label, selectionButton, checkmarkImageView])
        
        containerView.layout(with: self).fill()
        
        iconView.layout().width(36).height(36)
        iconView.layout(with: containerView).left(by: Metrics.margin).centerY()
        
        label.layout(with: iconView).fillVertical().left(to: .right, by: Metrics.margin)
        label.layout(with: containerView).right(by: -Metrics.margin)
        
        selectionButton.layout(with: containerView).fill()
        
        checkmarkImageView.layout(with:containerView).trailing(by: -22).centerY()
        checkmarkImageView.layout().width(14).height(10)
    }
    
    
    // MARK: - UI Actions
    
    func headerTap() {
        delegate?.didSelectTaxonomy(taxonomy: taxonomy)
    }
}
