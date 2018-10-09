import LGCoreKit
import RxSwift
import LGComponents

class PostingAddDetailPriceView: UIView, PostingViewConfigurable, UITextFieldDelegate {
    
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
    
    var priceListing = Variable<ListingPrice>(SharedConstants.defaultPrice)
    
    private let disposeBag = DisposeBag()
    
    
    // MARK - Lifecycle
    
    init(currencySymbol: String?, frame: CGRect) {
        self.currencySymbol = currencySymbol
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
        priceTextField.attributedPlaceholder = NSAttributedString(string: R.Strings.productNegotiablePrice,
                                                                  attributes: [NSAttributedStringKey.foregroundColor: UIColor.grayLight,
                                                                               NSAttributedStringKey.font: UIFont.systemBoldFont(size: 26)])
        priceTextField.keyboardType = .decimalPad
        priceTextField.font = UIFont.systemBoldFont(size: 26)
        priceTextField.textColor = UIColor.white
        priceTextField.keyboardType = .decimalPad
        priceTextField.autocorrectionType = .no
        priceTextField.autocapitalizationType = .none
        priceTextField.delegate = self
        freeLabel.numberOfLines = 1
        freeLabel.adjustsFontSizeToFitWidth = false
        freeLabel.textAlignment = .left
        freeLabel.textColor = UIColor.white
        freeLabel.font = UIFont.systemBoldFont(size: 26)
        
        currencyLabel.text = currencySymbol
        freeLabel.text = R.Strings.sellPostFreeLabel
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(freeContainerPressed))
        contentSwitchView.addGestureRecognizer(tap)
        
        let tapBackground = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        addGestureRecognizer(tapBackground)
        
        freeSwitch.onTintColor = UIColor.primaryColor
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
        freeActive.asObservable().bind(to: freeSwitch.rx.isOn).disposed(by: disposeBag)
        freeActive.asObservable().skip(1).bind{ [weak self] active in
            self?.showPriceContainer(hide: active)
            }.disposed(by: disposeBag)
        freeSwitch.rx.isOn.asObservable().skip(1).bind(to: freeActive).disposed(by: disposeBag)
        
        Observable.combineLatest(freeSwitch.rx.isOn.asObservable(), priceTextField.rx.text.asObservable()) { ($0, $1) }.bind { [weak self] (isOn, textFieldValue) in
            guard let strongSelf = self else { return }
            if isOn {
                strongSelf.priceListing.value = .free
                strongSelf.priceTextField.resignFirstResponder()
            } else if let value = textFieldValue {
                strongSelf.priceListing.value = .normal(value.toPriceDouble())
            } else {
                strongSelf.priceListing.value = SharedConstants.defaultPrice
            }
        }.disposed(by: disposeBag)
    }
    
    private func showPriceContainer(hide: Bool) {
        textFieldContainerHeightConstraint.constant = hide ? 0 : 50
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.separatorView.alpha = hide ? 0.0 : 1.0
            self?.currencyLabel.alpha = hide ? 0.0 : 1.0
            self?.layoutIfNeeded()
        })
    }
    
    func updatePriceTextFieldToFirstResponder() {
        priceTextField.becomeFirstResponder()
    }

    
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard textField == priceTextField else { return true }
        return textField.shouldChangePriceInRange(range, replacementString: string, acceptsSeparator: true)
    }
    
    
    // MARK: - Actions
    
    @objc private func freeContainerPressed() {
        freeActive.value = !freeSwitch.isOn
    }
    
    @objc private func closeKeyboard() {
        priceTextField.resignFirstResponder()
    }
    
    
    // MARK: - PostingViewConfigurable

    func setupContainerView(view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        layout(with: view).fill()
    }
    
    func setupView(viewModel: PostingDetailsViewModel) {
        guard let price = viewModel.currentPrice else { return }
        switch price {
        case .normal:
            let priceString = price.value == 0 ? "" : String.fromPriceDouble(price.value)
            priceTextField.text = priceString
        case .free:
            freeActive.value = true
        }
    }
}
