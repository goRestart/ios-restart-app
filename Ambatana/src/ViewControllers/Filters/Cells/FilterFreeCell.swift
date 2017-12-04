//
//  FilterFreeCell.swift
//  LetGo
//
//  Created by Juan Iglesias on 18/07/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxSwift

protocol FilterFreeCellDelegate: class {
    func freeSwitchChanged(isOn: Bool)
}


class FilterFreeCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var freeSwitch: UISwitch!
    @IBOutlet weak var topSeparator: UIView!
    @IBOutlet weak var bottomSeparator: UIView!
    
    @IBOutlet weak var bottomSeparatorHeight: NSLayoutConstraint!
    @IBOutlet weak var topSeparatorHeight: NSLayoutConstraint!
    
    weak var delegate: FilterFreeCellDelegate?
    let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupRx()
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
    
    private func setupRx() {
        freeSwitch.rx.value.asObservable().bind { [weak self] isOn in
            if let imageView = self?.freeSwitch.firstSubview(ofType: UIImageView.self) {
                imageView.contentMode = .center
                imageView.image = isOn ? #imageLiteral(resourceName: "free_switch_active") : #imageLiteral(resourceName: "free_switch_inactive")
            }
        }.disposed(by: disposeBag)
    }
    
    
    private func resetUI() {
        titleLabel.text = nil
    }
    
    @IBAction func freeSwitchChanged(_ sender: Any) {
        delegate?.freeSwitchChanged(isOn: freeSwitch.isOn)
    }
    
    private func setAccessibilityIds() {
        self.accessibilityId =  .filterPriceCell
        titleLabel.accessibilityId =  .filterFreeCellTitleLabel
    }
}

