import Foundation
import LGCoreKit
import LGComponents

protocol MeetingCellImageDelegate: class {
    func meetingCellImageViewPressed(imageView: UIImageView, coordinates: LGLocationCoordinates2D)
}

final class ChatMyMeetingCell: UITableViewCell, ReusableCell {

    @IBOutlet weak private var meetingContainer: UIView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var statusLabel: UILabel!
    @IBOutlet weak private var statusIcon: UIImageView!
    @IBOutlet weak private var locationLabel: UILabel!
    @IBOutlet weak private var locationView: UIImageView!
    @IBOutlet weak private var locationButton: UIButton!
    @IBOutlet weak private var meetingDateLabel: UILabel!
    @IBOutlet weak private var meetingTimeLabel: UILabel!

    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!

    @IBOutlet weak private var locationLabelHeight: NSLayoutConstraint!
    @IBOutlet weak private var locationLabelTop: NSLayoutConstraint!

    weak var locationDelegate: MeetingCellImageDelegate?

    private var coordinates: LGLocationCoordinates2D?


    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }
}


// MARK: - Public

extension ChatMyMeetingCell {

    func setupLocation(locationName: String?, coordinates: LGLocationCoordinates2D?, date: Date, status: MeetingStatus) {

        self.coordinates = coordinates

        if let locationName = locationName, locationName.isEmpty {
            locationLabel.isHidden = true
            locationLabelHeight.constant = 0
            locationLabelTop.constant = 0
        } else {
            locationLabel.isHidden = false
            locationLabel.text = locationName
        }

        meetingDateLabel.text = date.prettyDateForMeeting()
        meetingTimeLabel.text = date.prettyTimeForMeeting()

        updateStatus(status: status)
    }

    fileprivate func updateStatus(status: MeetingStatus) {
        switch status {
        case .pending:
            statusLabel.text = R.Strings.chatMeetingCellStatusPending
            statusLabel.textColor = UIColor.grayText
            statusIcon.image = R.Asset.ChatNorris.icTime.image
        case .accepted:
            statusLabel.text = R.Strings.chatMeetingCellStatusAccepted
            statusLabel.textColor = UIColor.asparagus
            statusIcon.image = nil
        case .rejected:
            statusLabel.text = R.Strings.chatMeetingCellStatusDeclined
            statusLabel.textColor = UIColor.primaryColor
            statusIcon.image = nil
        }
        layoutIfNeeded()
    }
}


// MARK: - Private

private extension ChatMyMeetingCell {
    func setupUI() {
        meetingContainer.layer.cornerRadius = LGUIKitConstants.mediumCornerRadius
        meetingContainer.layer.shouldRasterize = true
        meetingContainer.layer.rasterizationScale = UIScreen.main.scale
        backgroundColor = UIColor.clear
        titleLabel.text = R.Strings.chatMeetingCellTitle
        titleLabel.textColor = UIColor.grayText

        locationButton.addTarget(self, action: #selector(locationTapped), for: .touchUpInside)
        locationView.image = R.Asset.ChatNorris.meetingMapPlaceholder.image
        locationView.contentMode = .scaleAspectFill
        locationView.cornerRadius = LGUIKitConstants.mediumCornerRadius
    }

    func resetUI() {
        titleLabel.text = R.Strings.chatMeetingCellTitle
        locationView.image = R.Asset.ChatNorris.meetingMapPlaceholder.image
    }

    @objc func locationTapped() {
        guard let coords = coordinates else { return }
        locationDelegate?.meetingCellImageViewPressed(imageView: locationView, coordinates: coords)
    }
}
