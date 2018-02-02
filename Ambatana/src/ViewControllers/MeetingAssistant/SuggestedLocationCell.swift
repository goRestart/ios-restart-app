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
    func imagePressed(coords: LGLocationCoordinates2D)
}

class SuggestedLocationCell: UICollectionViewCell {

    static let reuseId: String = "SuggestedLocationCell"

    static func cellSize() -> CGSize {
        return CGSize(width: 140, height: 180)
    }

    @IBOutlet weak var checkBoxView: UIImageView!
    @IBOutlet weak var coloredBgView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var selectButton: UIButton!

    @IBOutlet weak var mapButton: UIButton!

    private var location: SuggestedLocation?
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
            coloredBgView.backgroundColor = isSelected ? UIColor.primaryColor : UIColor.clear
            checkBoxView.isHidden = isSelected ? false : true

            if isSelected {
                selectButton.setTitle("Selected", for: .normal)
                selectButton.setTitleColor(UIColor.primaryColor, for: .normal)
                selectButton.backgroundColor = UIColor.clear
            } else {
                selectButton.setTitle("Select", for: .normal)
                selectButton.setTitleColor(UIColor.white, for: .normal)
                selectButton.backgroundColor = UIColor.primaryColor
            }
        }
    }

    func setupUI() {
        coloredBgView.backgroundColor = UIColor.clear
        coloredBgView.layer.cornerRadius = 10.0
        containerView.layer.cornerRadius = 9.0
        checkBoxView.isHidden = true
        selectButton.setTitle("Select", for: .normal)
        selectButton.setTitleColor(UIColor.primaryColor, for: .normal)
        selectButton.backgroundColor = UIColor.clear
        selectButton.isUserInteractionEnabled = false
        mapButton.addTarget(self, action: #selector(imageTapped), for: .touchUpInside)
    }

    @objc func imageTapped() {
        guard let coords = location?.locationCoords else { return }
        imgDelegate?.imagePressed(coords: coords)
    }


    private func resetUI() {
        locationNameLabel.text = ""
        imageView.image = nil
        checkBoxView.isHidden = true
        selectButton.setTitle("Select", for: .normal)
        selectButton.setTitleColor(UIColor.primaryColor, for: .normal)
        selectButton.backgroundColor = UIColor.clear
    }

    func setupWithSuggestedLocation(location: SuggestedLocation) {
        locationNameLabel.text = location.locationName
        setupImageWithCoords(coordinates: location.locationCoords)
        self.location = location
    }

    func setupImageWithCoords(coordinates: LGLocationCoordinates2D) {

        let mapStringUrl = "https://maps.googleapis.com/maps/api/staticmap?zoom=15&size=300x300&maptype=roadmap&markers=\(coordinates.latitude),\(coordinates.longitude)"

        if let url = URL(string: mapStringUrl) {
            imageView.lg_setImageWithURL(url, placeholderImage: UIImage(named: "chuck-body-ok"), completion: nil)
//            { [weak self] (result, url) in
//                if let _ = result.error {
//
//                }
//            }
        } else {
            imageView.image = UIImage(named: "chuck-body-ok")
        }
    }

    @objc func selectTheCell() {
        self.isSelected = true
    }
}
