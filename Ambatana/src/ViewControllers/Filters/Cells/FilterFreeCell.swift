//
//  FilterFreeCell.swift
//  LetGo
//
//  Created by Juan Iglesias on 18/07/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//


protocol FilterFreeCellDelegate: class {
    func freeSwitchChanged(on: Bool)
}


class FilterFreeCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var freeSwitch: UISwitch!
    @IBOutlet weak var topSeparator: UIView!
    @IBOutlet weak var bottomSeparator: UIView!
    
    @IBOutlet weak var bottomSeparatorHeight: NSLayoutConstraint!
    @IBOutlet weak var topSeparatorHeight: NSLayoutConstraint!
    
    weak var delegate: FilterFreeCellDelegate?
    
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
        freeSwitch.onTintColor = UIColor.primaryColor
        
    }
    
    private func resetUI() {
        titleLabel.text = nil
    }
    
    @IBAction func freeSwitchChanged(_ sender: Any) {
        delegate?.freeSwitchChanged(on: freeSwitch.isOn)
    }
    
    private func setAccessibilityIds() {
        self.accessibilityId =  .filterPriceCell
        titleLabel.accessibilityId =  .filterFreeCellTitleLabel
    }
}

