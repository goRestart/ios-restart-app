//
//  GalleryImageCell.swift
//  LetGo
//
//  Created by Eli Kohen on 04/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class GalleryImageCell: UICollectionViewCell, ReusableCell {

    static var reusableID = "GalleryImageCell"

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var selectedCountlabel: UILabel!
    @IBOutlet weak var disabledView: UIView!

    var disabled: Bool = false {
        didSet {
            disabledView.hidden = !disabled
        }
    }
    
    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        self.resetUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }

    override var selected: Bool {
        didSet {
            selectedCountlabel.hidden = !selected
        }
    }

    // MARK: - Private methods

    // Sets up the UI
    private func setupUI() {
        selectedCountlabel.layer.borderWidth = 2
        selectedCountlabel.layer.borderColor = UIColor.whiteColor().CGColor
    }

    // Resets the UI to the initial state
    private func resetUI() {
        image.image = nil
        selectedCountlabel.hidden = true
        self.disabled = false
    }
}
