//
//  FilterPriceCell.swift
//  LetGo
//
//  Created by Dídac on 26/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

protocol FilterPriceCellDelegate {
    func priceTextFieldValueActive(tag: Int)
    func priceTextFieldValueChanged(value: String?, tag: Int)
}

class FilterPriceCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var topSeparator: UIView!
    @IBOutlet weak var bottomSeparator: UIView!
    
    @IBOutlet weak var bottomSeparatorHeight: NSLayoutConstraint!
    @IBOutlet weak var topSeparatorHeight: NSLayoutConstraint!

    var delegate: FilterPriceCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        resetUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }

    private func setupUI() {
        bottomSeparatorHeight.constant = LGUIKitConstants.onePixelSize
        topSeparatorHeight.constant = LGUIKitConstants.onePixelSize
        titleLabel.textColor = UIColor.blackText
        textField.tintColor = UIColor.primaryColor
        textField.placeholder = LGLocalizedString.filtersSectionPrice
        textField.delegate = self
    }

    private func resetUI() {
        textField.text = nil
        titleLabel.text = nil
    }
}

extension FilterPriceCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        delegate?.priceTextFieldValueActive(tag)
    }

    func textFieldDidEndEditing(textField: UITextField) {
        delegate?.priceTextFieldValueChanged(textField.text, tag: tag)
    }
}