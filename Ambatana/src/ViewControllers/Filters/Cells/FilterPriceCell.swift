//
//  FilterPriceCell.swift
//  LetGo
//
//  Created by Dídac on 26/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

protocol FilterPriceCellDelegate: class {
    func priceTextFieldValueActive()
    func priceTextFieldValueChanged(_ value: String?, tag: Int)
}

class FilterPriceCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var topSeparator: UIView!
    @IBOutlet weak var bottomSeparator: UIView!
    
    @IBOutlet weak var bottomSeparatorHeight: NSLayoutConstraint!
    @IBOutlet weak var topSeparatorHeight: NSLayoutConstraint!

    weak var delegate: FilterPriceCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        resetUI()
        setAccessibilityIds()
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

    private func setAccessibilityIds() {
        self.accessibilityId =  .filterPriceCell
        titleLabel.accessibilityId =  .filterPriceCellTitleLabel
        textField.accessibilityId =  .filterPriceCellTextField
    }
}

extension FilterPriceCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.priceTextFieldValueActive()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard textField.shouldChangePriceInRange(range, replacementString: string, acceptsSeparator: false) else { return false }
        let updatedText = textField.textReplacingCharactersInRange(range, replacementString: string)
        delegate?.priceTextFieldValueChanged(updatedText, tag: tag)
        return true
    }
}
