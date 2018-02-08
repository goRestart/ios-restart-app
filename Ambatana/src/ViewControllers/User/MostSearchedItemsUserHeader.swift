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
    
    static let viewHeight: CGFloat = 68
    
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
        trendingImageView.image = UIImage(named: "trending_icon")
        trendingImageView.contentMode = .scaleAspectFit
        addSubview(trendingImageView)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = UIColor.black
        titleLabel.text = LGLocalizedString.trendingItemsProfileTitle
        addSubview(titleLabel)
        
        subtitleLabel.font = UIFont.boldSystemFont(ofSize: 11)
        subtitleLabel.textColor = UIColor.black
        subtitleLabel.text = LGLocalizedString.trendingItemsProfileSubtitle
        addSubview(subtitleLabel)
        
        disclosureImageView.image = UIImage(named: "ic_disclosure")
        disclosureImageView.contentMode = .center
        addSubview(disclosureImageView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        addGestureRecognizer(tap)
    }
    
    private func setupConstraints() {
        let subviews = [trendingImageView, titleLabel, subtitleLabel, disclosureImageView]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        addSubviews(subviews)
        
        trendingImageView.layout(with: self)
            .centerY()
            .leading(by: Metrics.bigMargin)
        trendingImageView.layout()
            .width(46)
            .height(46)
        
        titleLabel.layout(with: trendingImageView).toLeft(by: Metrics.shortMargin)
        titleLabel.layout(with: disclosureImageView).toRight(by: Metrics.shortMargin)
        titleLabel.layout(with: self).top(by: Metrics.shortMargin)
        titleLabel.layout().height(30)
        
        subtitleLabel.layout(with: trendingImageView).toLeft(by: Metrics.shortMargin)
        subtitleLabel.layout(with: disclosureImageView).toRight(by: Metrics.shortMargin)
        subtitleLabel.layout(with: titleLabel).below(by: Metrics.veryShortMargin)
        subtitleLabel.layout().height(13)
        
        disclosureImageView.layout(with: self)
            .centerY()
            .trailing(by: -Metrics.shortMargin)
        disclosureImageView.layout()
            .width(8)
            .height(13)
    }
    
    
    // MARK: - UI Actions
    
    @objc private dynamic func tapAction() {
        delegate?.didTapMostSearchedItemsHeader()
    }
}
