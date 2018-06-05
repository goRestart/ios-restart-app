import Foundation
import LGCoreKit
import LGComponents

protocol OtherMeetingCellDelegate: class {
    func acceptMeeting()
    func rejectMeeting()
}

final class ChatOtherMeetingCell: UITableViewCell, ReusableCell {

    @IBOutlet weak private var meetingContainer: UIView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var statusLabel: UILabel!
    @IBOutlet weak private var statusIcon: UIImageView!
    @IBOutlet weak private var locationLabel: UILabel!
    @IBOutlet weak private var locationView: UIImageView!
    @IBOutlet weak private var locationButton: UIButton!
    @IBOutlet weak private var meetingDateLabel: UILabel!
    @IBOutlet weak private var meetingTimeLabel: UILabel!

    @IBOutlet weak private var actionsContainer: UIView!
    @IBOutlet weak private var actionAccept: UIButton!
    @IBOutlet weak private var actionReject: UIButton!

    @IBOutlet weak var messageDateLabel: UILabel!

    @IBOutlet weak private var actionsContainerHeight: NSLayoutConstraint!

    @IBOutlet weak private var locationLabelHeight: NSLayoutConstraint!
    @IBOutlet weak private var locationLabelTop: NSLayoutConstraint!

    weak var delegate: OtherMeetingCellDelegate?

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

extension ChatOtherMeetingCell {

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
            actionsContainerHeight.constant = 44
            actionsContainer.isHidden = false
        case .accepted:
            statusLabel.text = R.Strings.chatMeetingCellStatusAccepted
            statusLabel.textColor = UIColor.asparagus
            statusIcon.image = nil
            actionsContainerHeight.constant = 0
            actionsContainer.isHidden = true
        case .rejected:
            statusLabel.text = R.Strings.chatMeetingCellStatusDeclined
            statusLabel.textColor = UIColor.primaryColor
            statusIcon.image = nil
            actionsContainerHeight.constant = 0
            actionsContainer.isHidden = true
        }
        setNeedsLayout()
    }
}


// MARK: - Private

private extension ChatOtherMeetingCell {
    func setupUI() {
        meetingContainer.layer.cornerRadius = LGUIKitConstants.mediumCornerRadius
        meetingContainer.layer.shouldRasterize = true
        meetingContainer.layer.rasterizationScale = UIScreen.main.scale
        backgroundColor = UIColor.clear
        titleLabel.text = R.Strings.chatMeetingCellTitle
        titleLabel.textColor = UIColor.grayText

        actionAccept.setTitle(R.Strings.chatMeetingCellAcceptButton, for: .normal)
        actionReject.setTitle(R.Strings.chatMeetingCellDeclineButton, for: .normal)
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

    @IBAction func acceptMeeting(_ sender: AnyObject) {
        delegate?.acceptMeeting()
        updateStatus(status: .accepted)
    }

    @IBAction func rejectMeeting(_ sender: AnyObject) {
        delegate?.rejectMeeting()
        updateStatus(status: .rejected)
    }
}
