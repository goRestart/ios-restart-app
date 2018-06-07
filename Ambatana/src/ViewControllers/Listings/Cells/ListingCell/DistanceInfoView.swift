import UIKit
import LGComponents

final class DistanceInfoView: UIView {
    
    private let distanceIcon: UIImageView = {
        let iv = UIImageView(frame: .zero)
        iv.image = R.Asset.BackgroundsAndImages.itemLocation.image
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.isOpaque = true
        return iv
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = .white
        label.textAlignment = .left
        label.font = ListingCellMetrics.DistanceView.distanceLabelFont
        label.applyShadow(withOpacity: 0.5, radius: 5, color: UIColor.black.cgColor)
        label.isOpaque = true
        label.clipsToBounds = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        isOpaque = true
        clipsToBounds = true
    }
    
    func setDistance(_ distance: String) {
        distanceLabel.text = distance
        distanceIcon.image = R.Asset.BackgroundsAndImages.itemLocation.image
    }
    
    func clearAll() {
        distanceLabel.text = nil
        distanceIcon.image = nil
    }
    
    private func setupViews() {
        addSubviewsForAutoLayout([distanceIcon, distanceLabel])
        NSLayoutConstraint.activate([
            distanceIcon.heightAnchor.constraint(equalToConstant: ListingCellMetrics.DistanceView.iconHeight),
            distanceIcon.widthAnchor.constraint(equalToConstant: ListingCellMetrics.DistanceView.iconWidth),
            distanceIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            distanceIcon.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            distanceLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            distanceLabel.leadingAnchor.constraint(equalTo: distanceIcon.trailingAnchor, constant: ListingCellMetrics.DistanceView.gap),
            distanceLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            distanceLabel.heightAnchor.constraint(equalTo: distanceIcon.heightAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

