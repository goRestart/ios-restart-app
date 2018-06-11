import UIKit
import LGComponents

class ListingStatsView: UIView {

    enum Style {
        case light, dark

        var favIcon: UIImage {
            switch self {
            case .light: return R.Asset.IconsButtons.icStatsFavorite.image.withRenderingMode(.alwaysTemplate)
            case .dark: return R.Asset.IconsButtons.icStatsFavorite.image
            }
        }
        var statsIcon: UIImage {
            switch self {
            case .light: return  R.Asset.IconsButtons.icStatsViews.image.withRenderingMode(.alwaysTemplate)
            case .dark: return  R.Asset.IconsButtons.icStatsViews.image
            }
        }
        var timeIcon: UIImage {
            switch self {
            case .light: return  R.Asset.IconsButtons.icStatsTime.image.withRenderingMode(.alwaysTemplate)
            case .dark: return   R.Asset.IconsButtons.icStatsTime.image
            }
        }

        var timePostedBorderWidth: CGFloat { return self == .light ? 1 : 0 }


        var iconTint: UIColor {
            switch self {
            case .light: return .grayDark
            case .dark: return .white
            }
        }
        var timePostedBackground: UIColor { return .white }

        var statBackground: UIColor {
            switch self {
            case .light: return UIColor.black.withAlphaComponent(0.05)
            case .dark: return UIColor.black.withAlphaComponent(0.54)
            }
        }
        var statsBorder: UIColor {
            switch self {
            case .light: return UIColor.grayLighter
            case .dark: return .clear
            }
        }
    }

    @IBOutlet weak var timePostedLeading: NSLayoutConstraint!
    @IBOutlet weak var favouriteStatsView: UIView!
    @IBOutlet weak var favouriteStatsLabel: UILabel!
    @IBOutlet weak var favouriteIcon: UIImageView!
    @IBOutlet weak var statsIcon: UIImageView!

    @IBOutlet weak var viewsStatsView: UIView!
    @IBOutlet weak var viewsStatsLabel: UILabel!

    @IBOutlet weak var timePostedView: UIView!
    @IBOutlet weak var timePostedLabel: UILabel!
    @IBOutlet weak var timePostedIcon: UIImageView!
    @IBOutlet weak var timePostedWidthConstraint: NSLayoutConstraint!

    private let statsViewMaxWidth: CGFloat = 80
    private let statsSeparationWidth: CGFloat = 17
    private let maxStatsDisplayedCount = 999
    private let timeViewMinWidth: CGFloat = 55

    override var intrinsicContentSize: CGSize { return CGSize(width: UIViewNoIntrinsicMetric, height: 24.0) }

    private var style: Style = .dark {
        didSet { updateStyle() }
    }

    // MARK: - Lifecycle

    static func make() -> ListingStatsView? {
        let view = Bundle.main.loadNibNamed("ListingStatsView", owner: self, options: nil)?.first as? ListingStatsView
        view?.setupUI()
        view?.setupAccessibilityIds()
        return view
    }

    static func make(withStyle style: Style) -> ListingStatsView? {
        let view = make()
        view?.style = style
        return view
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    fileprivate func setupUI() {
        favouriteStatsView.layer.cornerRadius = 12
        viewsStatsView.layer.cornerRadius = 12
        timePostedView.layer.cornerRadius = 12

        // until we have a ghost view
        favouriteStatsView.isHidden = true
        viewsStatsView.isHidden = true
        timePostedView.isHidden = true

        favouriteStatsLabel.layer.add(CATransition(), forKey: kCATransition)
        timePostedView.layer.add(CATransition(), forKey: kCATransition)
        viewsStatsLabel.layer.add(CATransition(), forKey: kCATransition)

        updateStyle()
    }

    private func setupRAssets() {
        timePostedIcon.image = R.Asset.IconsButtons.icNewStripe.image
        statsIcon.image = R.Asset.IconsButtons.icStatsViews.image
        favouriteIcon.image = R.Asset.IconsButtons.icStatsFavorite.image
    }
    
    private func setupAccessibilityIds() {       
        favouriteStatsView.set(accessibilityId: .listingStatsViewFavouriteStatsView)
        favouriteStatsLabel.set(accessibilityId: .listingStatsViewFavouriteStatsLabel)
        viewsStatsView.set(accessibilityId: .listingStatsViewFavouriteViewCountView)
        viewsStatsLabel.set(accessibilityId: .listingStatsViewFavouriteViewCountLabel)
        timePostedView.set(accessibilityId: .listingStatsViewFavouriteTimePostedView)
        timePostedLabel.set(accessibilityId: .listingStatsViewFavouriteTimePostedLabel)
    }

    private func updateStyle() {
        setupFavsView()
        setupStatsView()
        setupTimeView()
    }

    func updateStatsWithInfo(_ viewsCount: Int, favouritesCount: Int, postedDate: Date?) {
        favouriteStatsView.isHidden = favouritesCount < Constants.minimumStatsCountToShow
        viewsStatsView.isHidden = viewsCount < Constants.minimumStatsCountToShow

        favouriteStatsLabel.text = favouritesCount > maxStatsDisplayedCount ? "+999" : String(favouritesCount)

        viewsStatsLabel.text = viewsCount > maxStatsDisplayedCount ? "+999" : String(viewsCount)

        setupPostedTimeViewWithDate(postedDate)
    }

    func setupPostedTimeViewWithDate(_ postedDate: Date?) {
        guard let postedDate = postedDate else {
            timePostedView.isHidden = true
            return
        }
        setupTimeViewWithDate(postedDate)
    }

    private func setupTimeView() {
        setupTimeForMoreThan24hs()
    }

    private func setupStatsView() {
        statsIcon.tintColor = style.iconTint
        viewsStatsLabel.textColor = style.iconTint
        viewsStatsView.backgroundColor = style.statBackground
        statsIcon.image = style.statsIcon
    }

    private func setupFavsView() {
        favouriteIcon.tintColor = style.iconTint
        favouriteStatsLabel.textColor = style.iconTint
        favouriteStatsView.backgroundColor = style.statBackground
        favouriteIcon.image = style.favIcon
    }

    private func setupTimeViewWithDate(_ postedDate: Date) {
        timePostedView.isHidden = false
        timePostedWidthConstraint.constant = timeViewMinWidth
        timePostedLabel.text = postedDate.relativeTimeString(true)
        timePostedView.layer.borderColor = style.statsBorder.cgColor

        if postedDate.isFromLast24h() {
            setupTimeForLessThan24hs()
        } else {
            setupTimeForMoreThan24hs()
        }
    }

    private func setupTimeForLessThan24hs() {
        timePostedIcon.image = R.Asset.IconsButtons.icNewStripe.image
        timePostedLabel.textColor = UIColor.primaryColor
        timePostedView.backgroundColor = style.timePostedBackground
        timePostedView.layer.borderWidth = style.timePostedBorderWidth
    }

    private func setupTimeForMoreThan24hs() {
        timePostedView.layer.borderWidth = 0
        timePostedIcon.image = style.timeIcon
        timePostedView.backgroundColor = style.statBackground
        timePostedLabel.textColor = style.iconTint
        timePostedIcon.tintColor = style.iconTint
    }
}
