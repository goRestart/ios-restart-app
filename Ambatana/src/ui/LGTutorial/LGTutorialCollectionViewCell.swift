//
//  LGTutorialCollectionViewCell.swift
//  LetGo
//
//  Created by Facundo Menzella on 11/17/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGComponents

final class LGTutorialCollectionViewCell: UICollectionViewCell {
    
    let stackViewContent = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    override func prepareForReuse() {
        stackViewContent.arrangedSubviews.forEach({$0.removeFromSuperview()})
    }
    
    func populate(with page: LGTutorialPage) {
        
        let titlePageLabel: UILabel = UILabel()
        titlePageLabel.numberOfLines = 0
        titlePageLabel.preferredMaxLayoutWidth = contentView.bounds.width
        titlePageLabel.textColor = UIColor.primaryColor
        titlePageLabel.font = UIFont.systemBoldFont(size: 26)
        titlePageLabel.text = page.title
        titlePageLabel.textAlignment = .center
        stackViewContent.addArrangedSubview(titlePageLabel)
        
        page.sections.forEach { section in
            let imageView: UIImageView = UIImageView()
            imageView.image = section.image
            imageView.contentMode = .scaleAspectFit
            stackViewContent.addArrangedSubview(imageView)
            
            let sectionLabelTitle: UILabel = UILabel()
            sectionLabelTitle.numberOfLines = 0
            sectionLabelTitle.preferredMaxLayoutWidth = contentView.bounds.width
            sectionLabelTitle.textColor = UIColor.blackText
            sectionLabelTitle.font = UIFont.systemBoldFont(size: 26)
            sectionLabelTitle.text = section.title
            sectionLabelTitle.textAlignment = page.aligment
            sectionLabelTitle.adjustsFontSizeToFitWidth = true
            stackViewContent.addArrangedSubview(sectionLabelTitle)
            
            let sectionLabelDescription: UILabel = UILabel()
            sectionLabelDescription.numberOfLines = 0
            sectionLabelDescription.preferredMaxLayoutWidth = contentView.bounds.width
            sectionLabelDescription.textColor = UIColor.grayDark
            sectionLabelDescription.font = UIFont.systemFont(size: 16)
            sectionLabelDescription.text = section.description
            sectionLabelDescription.textAlignment = page.aligment
            sectionLabelDescription.adjustsFontSizeToFitWidth = true
            stackViewContent.addArrangedSubview(sectionLabelDescription)
        }
        self.setNeedsLayout()
    }
    
    private func setupUI() {
        cornerRadius = 10.0
        contentView.backgroundColor = .white
        contentView.clipsToBounds = true
        
        setupStackView()
    }
    
    private func setupStackView() {
        
        stackViewContent.axis = .vertical
        stackViewContent.distribution = .fillProportionally
        stackViewContent.alignment = .fill
        stackViewContent.spacing = 10
        
        stackViewContent.layoutMargins = UIEdgeInsets(top: 0, left: Metrics.margin, bottom: 0, right: Metrics.margin)
        stackViewContent.isLayoutMarginsRelativeArrangement = true
        
        stackViewContent.translatesAutoresizingMaskIntoConstraints = false
        stackViewContent.backgroundColor = UIColor.redBarBackground
        contentView.addSubview(stackViewContent)
        stackViewContent.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.margin).isActive = true
        stackViewContent.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        stackViewContent.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        stackViewContent.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metrics.margin).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}
