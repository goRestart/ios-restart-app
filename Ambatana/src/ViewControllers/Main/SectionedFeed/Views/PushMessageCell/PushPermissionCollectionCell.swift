import UIKit

final class PushPermissionsCollectionCell: UICollectionViewCell {
    
    static let viewHeight: CGFloat = 50
    
    private let pushPermissionHeaderView = PushMessageBannerView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubviewForAutoLayout(pushPermissionHeaderView)
        pushPermissionHeaderView.layout(with: contentView).fill()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

