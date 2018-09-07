import UIKit
import GoogleMobileAds

final class ConversationAdCell: UITableViewCell, ReusableCell {
    
    func setupWith(dfpData: ConversationAdCellData) {
        selectionStyle = .none
        guard let bannerView = dfpData.bannerView else { return }
        contentView.addSubviewsForAutoLayout([bannerView])
        bannerView.layout(with: contentView).top().bottom().centerX()
        bannerView.set(accessibilityId: .advertisementCellBanner)
    }
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        resetUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }
    
    private func resetUI() {
        contentView.subviews.forEach { subView in
            subView.removeFromSuperview()
        }
    }
    
}

struct ConversationAdCellData {
    var adUnitId: String
    var bannerHeight: CGFloat
    var bannerView: GADBannerView?
    var position: Int
}
