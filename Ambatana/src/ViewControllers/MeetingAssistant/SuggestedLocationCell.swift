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
        guard let _ = location else { return "_ Search"}
        return isSelected ? "_ Selected" : "_ Select"
    }
    weak var imgDelegate: SuggestedLocationCellImageDelegate?

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
        let rect = imageView.convertToWindow(imageView.frame)
        imgDelegate?.imagePressed(coordinates: location?.locationCoords, originPoint: rect.center)
    }

    private func resetUI() {
        locationNameLabel.text = ""
        locationAddressLabel.text = ""
        imageView.image = nil
        checkBoxView.isHidden = true
        selectButton.setTitle("_ Select", for: .normal)
        selectButton.setTitleColor(UIColor.primaryColor, for: .normal)
        selectButton.backgroundColor = UIColor.clear
        showShadow()
    }

    func setupWithSuggestedLocation(location: SuggestedLocation?) {
        locationNameLabel.numberOfLines = location != nil ? 1 : 0
        locationNameLabel.text = location?.locationName ?? "_ Search another location"
        locationAddressLabel.text = location?.locationAddress
        setupImageWithCoords(coordinates: location?.locationCoords)
        self.location = location
    }

    func setupImageWithCoords(coordinates: LGLocationCoordinates2D?) {

        guard let coordinates = coordinates else {
            imageView.image = #imageLiteral(resourceName: "meeting_map_placeholder")
            return
        }

        // 🦄 Apple this!
        let mapStringUrl = "https://maps.googleapis.com/maps/api/staticmap?zoom=15&size=300x300&maptype=roadmap&markers=\(coordinates.latitude),\(coordinates.longitude)"

        if let url = URL(string: mapStringUrl) {
            imageView.lg_setImageWithURL(url, placeholderImage: #imageLiteral(resourceName: "meeting_map_placeholder"), completion: nil)
        } else {
            imageView.image = #imageLiteral(resourceName: "meeting_map_placeholder")
        }
    }
}
