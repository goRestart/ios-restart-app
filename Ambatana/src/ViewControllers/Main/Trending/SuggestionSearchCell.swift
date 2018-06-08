import UIKit
import LGComponents

struct SuggestionSearchCellContent {
    let title: String
    let titleSkipHighlight: String?
    let subtitle: String?
    let icon: UIImage?
    let fillSearchWithCellTextButtonAction: (() -> Void)?
    
    init(title: String, titleSkipHighlight: String? = nil, subtitle: String? = nil, icon: UIImage? = nil, fillSearchButtonBlock: (() -> Void)? = nil) {
        self.title = title
        self.titleSkipHighlight = titleSkipHighlight
        self.subtitle = subtitle
        self.icon = icon
        self.fillSearchWithCellTextButtonAction = fillSearchButtonBlock
    }
}

class SuggestionSearchCell: UITableViewCell, ReusableCell {
    static let estimatedHeight: CGFloat = 44
    private static let titleSubtitleSpacing: CGFloat = 0
    
    private let searchIconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private var titleSubtitleSpacing: NSLayoutConstraint?
    private let fillSearchButton = UIButton()
    
    private var fillSearchButtonBlock: (() -> Void)? {
        didSet {
            fillSearchButton.isHidden = fillSearchButtonBlock == nil
        }
    }
    
    
    // MARK: - Lifecycle
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        resetUI()
        setAccessibilityIds()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }
    
    // MARK: - UI
    
    private func setupUI() {
        backgroundColor = .clear
        
        searchIconImageView.contentMode = .center
        searchIconImageView.image = R.Asset.IconsButtons.icSearch.image
        
        fillSearchButton.contentVerticalAlignment = .top
        fillSearchButton.setImage(R.Asset.IconsButtons.icSearchFill.image, for: .normal)
        
        titleLabel.textColor = UIColor.lgBlack
        titleLabel.font = UIFont.systemBoldFont(size: 21)
        
        titleLabel.numberOfLines = 1
        subtitleLabel.textColor = UIColor.gray
        subtitleLabel.font = UIFont.systemFont(size: 15)
        subtitleLabel.numberOfLines = 1
        
        fillSearchButton.addTarget(self, action: #selector(fillSearchButtonPressed), for: .touchUpInside)
        
        let subviews = [searchIconImageView, titleLabel, subtitleLabel, fillSearchButton]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        contentView.addSubviews(subviews)

        searchIconImageView.layout()
            .width(24)
        searchIconImageView.layout(with: contentView)
            .leading(by: Metrics.margin)
            .top(by: Metrics.shortMargin)
            .bottom(by: -Metrics.shortMargin)
        
        titleLabel.layout(with: contentView)
            .top(by: Metrics.margin)
        titleLabel.layout(with: searchIconImageView)
            .toLeft(by: 25)
        
        subtitleLabel.layout(with: contentView)
            .bottom(by: -Metrics.margin)
        subtitleLabel.layout(with: titleLabel)
            .below(by: 5) { [weak self] constraint in
                self?.titleSubtitleSpacing = constraint
            }
        subtitleLabel.layout(with: searchIconImageView)
            .toLeft(by: 25)
        
        fillSearchButton.layout()
            .width(28)
        let titleFontAdjustment = titleLabel.font.ascender - titleLabel.font.capHeight
        fillSearchButton.layout(with: contentView)
            .trailing(by: -Metrics.margin)
            .top(by: Metrics.shortMargin + titleFontAdjustment)
            .bottom()
        fillSearchButton.layout(with: titleLabel)
            .toLeft(by: Metrics.margin)
        fillSearchButton.layout(with: subtitleLabel)
            .toLeft(by: Metrics.margin)
    }
    
    private func setAccessibilityIds() {
        set(accessibilityId: .suggestionSearchCell)
        titleLabel.set(accessibilityId: .suggestionSearchCellTitle)
        subtitleLabel.set(accessibilityId: .suggestionSearchCellSubtitle)
    }
    
    private func resetUI() {
        searchIconImageView.image = R.Asset.IconsButtons.icSearch.image
        titleLabel.text = nil
        subtitleLabel.text = nil
        fillSearchButton.isHidden = true
    }
    
    @objc private func fillSearchButtonPressed(sender: AnyObject) {
        fillSearchButtonBlock?()
    }
    
    // MARK: - Setup
    
    func set(_ data: SuggestionSearchCellContent) {
        if let titleLabelFont = titleLabel.font,
           let titleSkipHighlight = data.titleSkipHighlight {
            let titleWithHighlight = NSMutableAttributedString(string: data.title,
                                                               attributes: [NSAttributedStringKey.font: titleLabelFont])
            let range = NSString(string: data.title).range(of: titleSkipHighlight,
                                                      options: [.caseInsensitive, .diacriticInsensitive])
            
            titleWithHighlight.addAttribute(
                NSAttributedStringKey.foregroundColor,
                value: UIColor.gray,
                range: range)
            titleLabel.attributedText = titleWithHighlight
        } else {
            titleLabel.text = data.title
        }
        subtitleLabel.text = data.subtitle
        
        let spacing: CGFloat = data.subtitle == nil ? 0 : SuggestionSearchCell.titleSubtitleSpacing
        titleSubtitleSpacing?.constant = spacing
        
        searchIconImageView.image = data.icon
        fillSearchButtonBlock = data.fillSearchWithCellTextButtonAction
    }
}
