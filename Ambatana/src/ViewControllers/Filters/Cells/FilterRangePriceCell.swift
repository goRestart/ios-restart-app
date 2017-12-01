//
//  FilterPriceCell.swift
//  LetGo
//
//  Created by Dídac on 26/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

protocol FilterRangePriceCellDelegate: class {
    func priceTextFieldValueActive()
    func priceTextFieldValueChanged(_ value: String?, tag: Int)
}

enum TextFieldPriceType: Int {
    case priceFrom = 0
    case priceTo = 1
}

class FilterRangePriceCell: UICollectionViewCell {
    
    static let identifier = "\(FilterRangePriceCell.self)"

    @IBOutlet weak var titleLabelFrom: UILabel!
    @IBOutlet weak var titleLabelTo: UILabel!
    @IBOutlet weak var textFieldFrom: UITextField!
    @IBOutlet weak var textFieldTo: UITextField!
    @IBOutlet weak var topSeparator: UIView!
    @IBOutlet weak var bottomSeparator: UIView!
    
    @IBOutlet weak var bottomSeparatorHeight: NSLayoutConstraint!
    @IBOutlet weak var topSeparatorHeight: NSLayoutConstraint!

    weak var delegate: FilterRangePriceCellDelegate?

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
        textFieldFrom.tag = TextFieldPriceType.priceFrom.rawValue
        textFieldTo.tag = TextFieldPriceType.priceTo.rawValue
    }

    private func resetUI() {
        textFieldFrom.text = nil
        titleLabelFrom.text = nil
        textFieldTo.text = nil
        titleLabelTo.text = nil
    }

    private func setAccessibilityIds() {
        accessibilityId =  .filterPriceCell
        titleLabelFrom.accessibilityId =  .filterPriceCellTitleLabelFrom
        titleLabelTo.accessibilityId =  .filterPriceCellTitleLabelTo
        textFieldFrom.accessibilityId =  .filterPriceCellTextFieldFrom
        textFieldTo.accessibilityId =  .filterPriceCellTextFieldTo
    }
}

extension FilterRangePriceCell: UITextFieldDelegate {
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
