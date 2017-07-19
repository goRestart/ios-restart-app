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

    @IBOutlet weak var titleLabelFrom: UILabel!
    @IBOutlet weak var titleLabelTo: UILabel!
    @IBOutlet weak var textFieldFrom: UITextField!
    @IBOutlet weak var textFieldTo: UITextField!
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
        titleLabelFrom.textColor = UIColor.blackText
        titleLabelTo.textColor = UIColor.blackText
        textFieldFrom.tintColor = UIColor.primaryColor
        textFieldTo.tintColor = UIColor.primaryColor
        textFieldFrom.placeholder = LGLocalizedString.filtersSectionPrice
        textFieldTo.placeholder = LGLocalizedString.filtersSectionPrice
        textFieldFrom.delegate = self
        textFieldTo.delegate = self
        textFieldFrom.tag = 0
        textFieldTo.tag = 1
    }

    private func resetUI() {
        textFieldFrom.text = nil
        titleLabelFrom.text = nil
        textFieldTo.text = nil
        titleLabelTo.text = nil
    }

    private func setAccessibilityIds() {
        self.accessibilityId =  .filterPriceCell
        titleLabelFrom.accessibilityId =  .filterPriceCellTitleLabelFrom
        titleLabelTo.accessibilityId =  .filterPriceCellTitleLabelTo
        textFieldFrom.accessibilityId =  .filterPriceCellTextFieldFrom
        textFieldTo.accessibilityId =  .filterPriceCellTextFieldTo
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
        delegate?.priceTextFieldValueChanged(updatedText, tag: textField.tag)
        return true
    }
}
