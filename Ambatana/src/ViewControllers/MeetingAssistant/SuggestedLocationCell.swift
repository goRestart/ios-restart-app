//
//  SuggestedLocationCell.swift
//  LetGo
//
//  Created by Dídac on 23/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit

protocol SuggestedLocationCellImageDelegate: class {
    func imagePressed(coordinates: LGLocationCoordinates2D?, originPoint: CGPoint)
}

class SuggestedLocationCell: UICollectionViewCell {

    static let reuseId: String = "SuggestedLocationCell"

    static func cellSize() -> CGSize {
        return CGSize(width: 160, height: 220)
    }

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
        guard let _ = location else { return LGLocalizedString.meetingCreationViewSearchCellSearch }
        return LGLocalizedString.meetingCreationViewSuggestCellSelect
    }
    weak var imgDelegate: SuggestedLocationCellImageDelegate?

    private var mapImage: UIImage = #imageLiteral(resourceName: "meeting_map_placeholder")

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }

    override var isSelected: Bool {
        didSet {
            guard let _ = location else { return }

            checkBoxView.isHidden = isSelected ? false : true

            if isSelected {
                selectButton.setTitle(LGLocalizedString.meetingCreationViewSuggestCellSelected, for: .normal)
                containerView.layer.borderColor = UIColor.primaryColor.cgColor
                containerView.layer.borderWidth = 2
                hideShadow()
            } else {
                selectButton.setTitle(LGLocalizedString.meetingCreationViewSuggestCellSelect, for: .normal)
                containerView.layer.borderColor = UIColor.primaryColor.cgColor
                containerView.layer.borderWidth = 0
                showShadow()
            }
        }
    }

    func setupUI() {
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
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowOffset = CGSize.zero
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
        let rect = imageView.convert(imageView.frame, to: nil)
        imgDelegate?.imagePressed(coordinates: location?.locationCoords, originPoint: rect.center)
    }

    private func resetUI() {
        locationNameLabel.text = ""
        locationAddressLabel.text = ""
        checkBoxView.isHidden = true
        selectButton.setTitle(LGLocalizedString.meetingCreationViewSuggestCellSelect, for: .normal)
        selectButton.setTitleColor(UIColor.primaryColor, for: .normal)
        selectButton.backgroundColor = UIColor.clear
        showShadow()
    }

    func setupWithSuggestedLocation(location: SuggestedLocation?, mapSnapshot: UIImage?) {
        locationNameLabel.numberOfLines = location != nil ? 1 : 0
        locationNameLabel.text = location?.locationName ?? LGLocalizedString.meetingCreationViewSearchCellTitle
        locationAddressLabel.text = location?.locationAddress
        imageView.image = mapSnapshot ?? #imageLiteral(resourceName: "meeting_map_placeholder")
        self.location = location
    }
}
