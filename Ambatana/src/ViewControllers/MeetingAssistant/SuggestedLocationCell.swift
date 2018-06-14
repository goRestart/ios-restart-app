import UIKit
import LGCoreKit
import LGComponents

protocol SuggestedLocationCellImageDelegate: class {
    func suggestedLocationCellImageViewPressed(imageView: UIImageView, coordinates: LGLocationCoordinates2D?)
}

class SuggestedLocationCell: UICollectionViewCell, ReusableCell {

    @IBOutlet weak var checkBoxView: UIImageView!
    @IBOutlet weak var coloredBgView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var locationAddressLabel: UILabel!

    @IBOutlet weak var mapButton: UIButton!

    private var location: SuggestedLocation?
    private var buttonTitle: String {
        guard let _ = location else { return R.Strings.meetingCreationViewSearchCellSearch }
        return isSelected ? R.Strings.meetingCreationViewSuggestCellSelected : R.Strings.meetingCreationViewSuggestCellSelect
    }
    weak var imgDelegate: SuggestedLocationCellImageDelegate?

    private var mapImage: UIImage = R.Asset.ChatNorris.meetingMapPlaceholder.image

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }

    override var isSelected: Bool {
        didSet {
            guard let _ = location else { return }

            checkBoxView.isHidden = !isSelected
            selectButton.setTitle(buttonTitle, for: .normal)

            if isSelected {
                containerView.layer.borderColor = UIColor.primaryColor.cgColor
                containerView.layer.borderWidth = 2
                hideShadow()
            } else {
                containerView.layer.borderColor = UIColor.primaryColor.cgColor
                containerView.layer.borderWidth = 0
                showShadow()
            }
        }
    }

    func setupUI() {
        checkBoxView.image = R.Asset.IconsButtons.checkboxSelectedRound.image

        containerView.layer.borderWidth = 0
        coloredBgView.backgroundColor = UIColor.clear
        coloredBgView.layer.cornerRadius = 10.0
        containerView.layer.cornerRadius = 10.0
        checkBoxView.isHidden = true
        selectButton.setTitle(buttonTitle, for: .normal)
        selectButton.setTitleColor(UIColor.primaryColor, for: .normal)
        selectButton.backgroundColor = UIColor.clear
        selectButton.isUserInteractionEnabled = false
        mapButton.addTarget(self, action: #selector(imageTapped), for: .touchUpInside)
        showShadow()
    }

    private func showShadow() {
        containerView.layer.shadowRadius = 5
        containerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        containerView.layer.shadowOpacity = 0.5
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.masksToBounds = false
    }

    private func hideShadow() {
        containerView.layer.shadowRadius = 0
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.0
        containerView.layer.shadowOffset = CGSize.zero
        containerView.layer.masksToBounds = false
    }

    @objc func imageTapped() {
        imgDelegate?.suggestedLocationCellImageViewPressed(imageView: imageView, coordinates: location?.locationCoords)
    }

    private func resetUI() {
        locationNameLabel.text = ""
        locationAddressLabel.text = ""
        checkBoxView.isHidden = true
        selectButton.setTitle(buttonTitle, for: .normal)
        selectButton.setTitleColor(UIColor.primaryColor, for: .normal)
        selectButton.backgroundColor = UIColor.clear
        showShadow()
    }

    func setupWithSuggestedLocation(location: SuggestedLocation?, mapSnapshot: UIImage?) {
        locationNameLabel.numberOfLines = location != nil ? 1 : 0
        locationNameLabel.text = location?.locationName ?? R.Strings.meetingCreationViewSearchCellTitle
        locationAddressLabel.text = location?.locationAddress
        imageView.image = mapSnapshot ?? R.Asset.ChatNorris.meetingMapPlaceholder.image
        self.location = location
    }
}
