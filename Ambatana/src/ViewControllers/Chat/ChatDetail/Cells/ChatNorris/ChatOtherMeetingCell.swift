//
//  ChatOtherMeetingCell.swift
//  LetGo
//
//  Created by Dídac on 20/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

protocol OtherMeetingCellDelegate: class {
    func acceptMeeting()
    func rejectMeeting()
}

final class ChatOtherMeetingCell: UITableViewCell, ReusableCell {

    @IBOutlet weak var meetingContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusIcon: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationView: UIImageView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var meetingDateLabel: UILabel!
    @IBOutlet weak var meetingTimeLabel: UILabel!

    @IBOutlet weak var actionsContainer: UIView!
    @IBOutlet weak var actionAccept: UIButton!
    @IBOutlet weak var actionReject: UIButton!

    @IBOutlet weak var messageDateLabel: UILabel!

    @IBOutlet weak var actionsContainerHeight: NSLayoutConstraint!

    @IBOutlet weak var locationLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var locationLabelTop: NSLayoutConstraint!

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
            statusLabel.text = LGLocalizedString.chatMeetingCellStatusPending
            statusLabel.textColor = UIColor.grayText
            statusIcon.image = #imageLiteral(resourceName: "ic_time")
            actionsContainerHeight.constant = 44
            actionsContainer.isHidden = false
        case .accepted:
            statusLabel.text = LGLocalizedString.chatMeetingCellStatusAccepted
            statusLabel.textColor = UIColor.asparagus
            statusIcon.image = nil
            actionsContainerHeight.constant = 0
            actionsContainer.isHidden = true
        case .rejected:
            statusLabel.text = LGLocalizedString.chatMeetingCellStatusDeclined
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
        titleLabel.text = LGLocalizedString.chatMeetingCellTitle
        titleLabel.textColor = UIColor.grayText

        actionAccept.setTitle(LGLocalizedString.chatMeetingCellAcceptButton, for: .normal)
        actionReject.setTitle(LGLocalizedString.chatMeetingCellDeclineButton, for: .normal)
        locationButton.addTarget(self, action: #selector(locationTapped), for: .touchUpInside)

        locationView.image = #imageLiteral(resourceName: "meeting_map_placeholder")
        locationView.contentMode = .scaleAspectFill
        locationView.cornerRadius = LGUIKitConstants.mediumCornerRadius
    }

    func resetUI() {
        titleLabel.text = LGLocalizedString.chatMeetingCellTitle
        locationView.image = #imageLiteral(resourceName: "meeting_map_placeholder")
    }

    @objc func locationTapped() {
        guard let coords = coordinates else { return }
        let rect = locationView.convertToWindow(locationView.frame)
        locationDelegate?.imagePressed(coordinates: coords, originPoint: rect.center)
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
