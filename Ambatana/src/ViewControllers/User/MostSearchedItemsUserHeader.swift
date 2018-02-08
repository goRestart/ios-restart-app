//
//  MostSearchedItemsUserHeader.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 16/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

protocol MostSearchedItemsUserHeaderDelegate: class {
    func didTapMostSearchedItemsHeader()
}

class MostSearchedItemsUserHeader: UIView {
    
    static let viewHeight: CGFloat = 88
    
    private let corneredBackgroundView = UIView()
    private let trendingImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let disclosureImageView = UIImageView()
    
    weak var delegate: MostSearchedItemsUserHeaderDelegate?
    
    
    // MARK: - Lifecycle
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        corneredBackgroundView.backgroundColor = .white
        corneredBackgroundView.layer.cornerRadius = LGUIKitConstants.smallCornerRadius
        
        trendingImageView.image = UIImage(named: "trending_icon")
        trendingImageView.contentMode = .scaleAspectFit
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = UIColor.black
        titleLabel.text = LGLocalizedString.trendingItemsProfileTitle
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.4
        
        subtitleLabel.font = UIFont.systemRegularFont(size: 11)
        subtitleLabel.textColor = UIColor.black
        subtitleLabel.text = LGLocalizedString.trendingItemsProfileSubtitle
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.minimumScaleFactor = 0.4
        
        disclosureImageView.image = UIImage(named: "ic_disclosure")
        disclosureImageView.contentMode = .center
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        addGestureRecognizer(tap)
    }
    
    private func setupConstraints() {
        let subviews = [corneredBackgroundView, trendingImageView, titleLabel, subtitleLabel, disclosureImageView]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        addSubviews(subviews)
        
        corneredBackgroundView.layout(with: self).fill(by: Metrics.shortMargin)
        
        trendingImageView.layout(with: self)
            .centerY()
            .leading(by: Metrics.bigMargin)
        trendingImageView.layout()
            .width(46)
            .height(46)
        
        titleLabel.layout(with: trendingImageView).leading(to: .trailing, by: Metrics.shortMargin)
        titleLabel.layout(with: disclosureImageView).trailing(by: -Metrics.shortMargin)
        titleLabel.layout(with: self).centerY(by: -(titleLabel.height/2 + Metrics.shortMargin))
        titleLabel.layout().height(30)
        
        subtitleLabel.layout(with: trendingImageView).leading(to: .trailing, by: Metrics.shortMargin)
        subtitleLabel.layout(with: disclosureImageView).trailing(by: -Metrics.shortMargin)
        subtitleLabel.layout(with: self).centerY(by: subtitleLabel.height/2 + Metrics.margin)
        subtitleLabel.layout().height(13)
        
        disclosureImageView.layout(with: self)
            .centerY()
            .trailing(by: -Metrics.bigMargin)
        disclosureImageView.layout()
            .width(8)
            .height(13)
    }
    
    
    // MARK: - UI Actions
    
    @objc private dynamic func tapAction() {
        delegate?.didTapMostSearchedItemsHeader()
    }
}
