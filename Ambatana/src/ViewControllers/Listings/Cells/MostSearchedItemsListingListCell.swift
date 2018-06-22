import Foundation
import LGComponents

class MostSearchedItemsListingListCell: UICollectionViewCell, ReusableCell {
    
    static let height: CGFloat = 230
    
    private struct Layout {
        struct FontSize {
            static let title = 17
            static let actionTitle = 14
        }
        struct Margin {
            static let cardVerticalMargin: CGFloat = 30
        }
        struct Height {
            static let trendingImageView: CGFloat = 60
            static let actionBackgroundView: CGFloat = 32
        }
    }
    private var actionBackgroundViewLateralMargin: CGFloat {
        return self.contentView.width/5
    }

    private let corneredView = UIView()
    private let trendingImageView = UIImageView()
    private let titleLabel = UILabel()
    private let actionBackgroundView = UIView()
    private let actionLabel = UILabel()
    
    
    // MARK: - Lifecycle
    
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
        backgroundColor = UIColor.clear
        corneredView.backgroundColor = UIColor.lgBlack
    
        corneredView.cornerRadius = LGUIKitConstants.mediumCornerRadius

        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.2
        
        actionBackgroundView.backgroundColor = UIColor.grayDark
        actionBackgroundView.cornerRadius = 15

        actionLabel.font = UIFont.systemMediumFont(size: 14)
        actionLabel.textColor = UIColor.white
        actionLabel.textAlignment = .center
        actionLabel.adjustsFontSizeToFitWidth = true
        actionLabel.minimumScaleFactor = 0.2
    }

    private func setupConstraints() {
        let containerSubviews = [corneredView, trendingImageView, titleLabel, actionBackgroundView, actionLabel]
        contentView.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: containerSubviews)
        contentView.addSubviews(containerSubviews)

        corneredView.layout(with: contentView).fill()
        
        trendingImageView.layout(with: contentView)
            .centerX()
            .top(by: Layout.Margin.cardVerticalMargin)
        trendingImageView.layout()
            .height(Layout.Height.trendingImageView)
            .widthProportionalToHeight()

        titleLabel.layout(with: trendingImageView).below(by: Metrics.margin)
        titleLabel.layout(with: contentView).fillHorizontal(by: Metrics.shortMargin)
        titleLabel.layout(with: actionBackgroundView).above(by: -Metrics.margin)
        
        let actionBackgroundViewLateralMargin = contentView.width/5
        actionBackgroundView.layout(with: contentView)
            .centerX()
            .leading(by: actionBackgroundViewLateralMargin)
            .trailing(by: -actionBackgroundViewLateralMargin)
            .bottom(by: -Layout.Margin.cardVerticalMargin)
        actionBackgroundView.layout().height(32)
        
        actionLabel.layout(with: actionBackgroundView).fill()
    }
    
    func setupWith(data: MostSearchedItemsCardData) {
        titleLabel.text = data.title
        actionLabel.text = data.actionTitle
        trendingImageView.image = data.icon
    }
}
