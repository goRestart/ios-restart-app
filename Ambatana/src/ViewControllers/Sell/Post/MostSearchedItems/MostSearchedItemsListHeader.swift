import LGComponents

class MostSearchedItemsListHeader: UITableViewHeaderFooterView, ReusableCell {
    
    static let viewHeight: CGFloat = 200
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let subtitleView = UIView()
    private let subtitleImageView = UIImageView()
    private let subtitleLabel = UILabel()
    
    
    // MARK: - Lifecycle
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        contentView.backgroundColor = .white
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 23)
        titleLabel.textColor = UIColor.black
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.2
        
        descriptionLabel.font = UIFont.systemRegularFont(size: 17)
        descriptionLabel.textColor = UIColor.darkGrayText
        descriptionLabel.numberOfLines = 2
        descriptionLabel.text = R.Strings.trendingItemsViewSubtitle
        descriptionLabel.adjustsFontSizeToFitWidth = true
        descriptionLabel.minimumScaleFactor = 0.2
        
        subtitleImageView.image = UIImage(named: "ic_search")
        
        subtitleLabel.font = UIFont.systemMediumFont(size: 13)
        subtitleLabel.textColor = UIColor.grayText
        subtitleLabel.text = R.Strings.trendingItemsViewNumberOfSearchesTitle
    }
    
    private func setupConstraints() {
        let containerSubviews = [titleLabel, descriptionLabel, subtitleView]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: containerSubviews)
        contentView.addSubviews(containerSubviews)
    
        let subtitleViews = [subtitleImageView, subtitleLabel]
        subtitleView.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subtitleViews)
        subtitleView.addSubviews(subtitleViews)
        
        titleLabel.layout(with: contentView).fillHorizontal(by: Metrics.bigMargin)
        titleLabel.layout(with: contentView).top(by: Metrics.bigMargin)
        titleLabel.layout().height(56)

        descriptionLabel.layout(with: contentView).fillHorizontal(by: Metrics.bigMargin)
        descriptionLabel.layout(with: titleLabel).top(to: .bottom, by: Metrics.margin)
        descriptionLabel.layout().height(60)
        
        subtitleView.layout(with: contentView).fillHorizontal()
        subtitleView.layout(with: descriptionLabel).top(to: .bottom, by: Metrics.margin)
        subtitleView.layout().height(15)
        
        subtitleImageView.layout(with: subtitleView)
            .fillVertical()
            .leading(by: Metrics.bigMargin)
        subtitleImageView.layout()
            .width(15)
            .height(15)
        
        subtitleLabel.layout(with: subtitleView)
            .fillVertical()
            .trailing(by: Metrics.bigMargin)
        subtitleLabel.layout(with: subtitleImageView).toLeft(by: Metrics.margin)
    }
    
    func updateTitleTo(_ title: String) {
        titleLabel.text = title
    }
}
