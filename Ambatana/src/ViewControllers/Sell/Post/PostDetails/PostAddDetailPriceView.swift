//
//  PostListingPriceDetailView.swift
//  LetGo
//
//  Created by Juan Iglesias on 19/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

class PostAddDetailPriceView: UIView {
    
    static private let currencyWidth: CGFloat = 20
    static private let priceViewMargin: CGFloat = 20
    
    private let currencyLabel = UILabel()
    private let priceTextField = UITextField()
    private let contentTextFieldView = UIView()
    private let separatorView = UIView()
    private let contentSwitchView = UIView()
    private let freeLabel = UILabel()
    private let freeSwitch = UISwitch()
    private let freeActive = Variable<Bool>(false)
    
    private var textFieldContainerHeightConstraint = NSLayoutConstraint()
    
    private let currencySymbol: String?
    private let freeEnabled: Bool
    
    private let disposeBag = DisposeBag()
    
    
    // MARK - Lifecycle
    
    init(currencySymbol: String?, freeEnabled: Bool, frame: CGRect) {
        self.currencySymbol = currencySymbol
        self.freeEnabled = freeEnabled
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupRx()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        
        separatorView.backgroundColor = UIColor.whiteTextLowAlpha
        currencyLabel.numberOfLines = 1
        currencyLabel.adjustsFontSizeToFitWidth = false
        currencyLabel.textAlignment = .center
        currencyLabel.textColor = UIColor.white
        currencyLabel.font = UIFont.systemBoldFont(size: 26)
        
        priceTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.productNegotiablePrice,
                                                                  attributes: [NSForegroundColorAttributeName: UIColor.grayLight, NSFontAttributeName: UIFont.systemBoldFont(size: 26)])
        priceTextField.keyboardType = .decimalPad
        priceTextField.font = UIFont.systemBoldFont(size: 26)
        priceTextField.textColor = UIColor.white
        
        freeLabel.numberOfLines = 1
        freeLabel.adjustsFontSizeToFitWidth = false
        freeLabel.textAlignment = .left
        freeLabel.textColor = UIColor.white
        freeLabel.font = UIFont.systemBoldFont(size: 26)
        
        contentSwitchView.isHidden = !freeEnabled
        separatorView.isHidden = !freeEnabled
        
        currencyLabel.text = currencySymbol
        freeLabel.text = LGLocalizedString.sellPostFreeLabel
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(freeContainerPressed))
        contentSwitchView.addGestureRecognizer(tap)
    }
    
    private func setupConstraints() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: [contentTextFieldView, currencyLabel, priceTextField, separatorView, freeLabel, contentSwitchView, freeSwitch])
        addSubviews([contentTextFieldView, separatorView, contentSwitchView])
        
        contentTextFieldView.addSubview(currencyLabel)
        contentTextFieldView.addSubview(priceTextField)
        contentSwitchView.addSubview(freeSwitch)
        contentSwitchView.addSubview(freeLabel)
        
        currencyLabel.clipsToBounds = true
        priceTextField.clipsToBounds = true
        
        contentTextFieldView.layout(with: self).fillHorizontal(by: 20).top(by: 20)
        contentTextFieldView.layout().height(50) { [weak self] constraint in
            self?.textFieldContainerHeightConstraint = constraint
        }
        
        currencyLabel.layout(with: contentTextFieldView).left().fillVertical()
        currencyLabel.layout().width(20)
        
        priceTextField.layout(with: currencyLabel).left(by: 50)
        priceTextField.layout(with: contentTextFieldView).right(by: Metrics.bigMargin).fillVertical()
        
        separatorView.layout(with: contentTextFieldView).below(by: Metrics.bigMargin)
        separatorView.layout(with: self).fillHorizontal(by: Metrics.bigMargin)
        separatorView.layout().height(2)
        
        contentSwitchView.layout(with: separatorView).below(by: Metrics.bigMargin)
        contentSwitchView.layout(with: self).fillHorizontal(by: Metrics.bigMargin)
        contentSwitchView.layout().height(50)
        
        freeLabel.layout(with: contentSwitchView).fillVertical().left()
        freeLabel.layout(with: freeSwitch).right()
        
        freeSwitch.layout(with: contentSwitchView).right().top(by: Metrics.shortMargin).bottom(by: -Metrics.shortMargin)
    }
    
    private func setupRx() {
        freeActive.asObservable().debug().bindTo(freeSwitch.rx.value(animated: true)).addDisposableTo(disposeBag)
        freeActive.asObservable().bindNext{[weak self] active in
            self?.showPriceContainer(hide: active)
            }.addDisposableTo(disposeBag)
        freeSwitch.rx.isOn.asObservable().bindTo(freeActive).addDisposableTo(disposeBag)
    }
    
    private func showPriceContainer(hide: Bool) {
        textFieldContainerHeightConstraint.constant = hide ? 0 : 50
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.separatorView.alpha = hide ? 0.0 : 1.0
            self?.currencyLabel.alpha = hide ? 0.0 : 1.0
            self?.layoutIfNeeded()
        })
    }
    
    
    // MARK: - Actions
    
    dynamic private func freeContainerPressed() {
        freeActive.value = !freeSwitch.isOn
    }
}
