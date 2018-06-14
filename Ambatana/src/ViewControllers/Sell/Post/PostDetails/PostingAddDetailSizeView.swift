import LGCoreKit
import RxSwift
import LGComponents

class PostingAddDetailSizeView: UIView, PostingViewConfigurable, UITextFieldDelegate {
    
    static private let sizeLabelTextMargin: CGFloat = 40
    static private let maxLengthSize: Int = 8
    
    private let sizeLabel = UILabel()
    private let sizeTextField = UITextField()
    private let contentTextFieldView = UIView()
    
    private var textFieldContainerHeightConstraint = NSLayoutConstraint()
    
    private var sizeListing = Variable<Int?>(nil)
    
    var sizeListingObservable: Observable<Int?> {
        return sizeListing.asObservable()
    }
    
    var placeholder: NSAttributedString {
        return NSAttributedString(string: R.Strings.realEstateSizeSquareMetersPlaceholder,
                           attributes: [NSAttributedStringKey.foregroundColor: UIColor.grayLight,
                                        NSAttributedStringKey.font: UIFont.systemBoldFont(size: 26)])
    }
    
    private let disposeBag = DisposeBag()
    
    
    // MARK - Lifecycle
    
    override init(frame: CGRect) {
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
        sizeLabel.numberOfLines = 1
        sizeLabel.adjustsFontSizeToFitWidth = false
        sizeLabel.textAlignment = .left
        sizeLabel.textColor = UIColor.white
        sizeLabel.font = UIFont.systemBoldFont(size: 26)
        sizeTextField.attributedPlaceholder = placeholder
        sizeTextField.keyboardType = .numberPad
        sizeTextField.font = UIFont.systemBoldFont(size: 26)
        sizeTextField.textColor = UIColor.white
        sizeTextField.autocorrectionType = .no
        sizeTextField.autocapitalizationType = .none
        sizeTextField.becomeFirstResponder()
        sizeTextField.delegate = self
        
        let tapBackground = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        addGestureRecognizer(tapBackground)
        
        sizeLabel.text = SharedConstants.sizeSquareMetersUnit + ":"
    }
    
    private func setupConstraints() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: [contentTextFieldView, sizeLabel, sizeTextField])
        addSubviews([contentTextFieldView])
        
        contentTextFieldView.addSubview(sizeLabel)
        contentTextFieldView.addSubview(sizeTextField)
        
        sizeLabel.clipsToBounds = true
        sizeTextField.clipsToBounds = true
        
        contentTextFieldView.layout(with: self).fillHorizontal(by: 20).top(by: 20)
        contentTextFieldView.layout().height(50)

        sizeLabel.layout(with: contentTextFieldView).left()
        sizeLabel.layout(with: contentTextFieldView).fillVertical()

        sizeTextField.layout(with: sizeLabel).leading(by: PostingAddDetailSizeView.sizeLabelTextMargin)
        sizeTextField.layout(with: contentTextFieldView).centerY()
    }
    
    private func setupRx() {
        sizeTextField.rx.text.asObservable().map { (text) -> Int? in
            guard let text = text else { return nil }
            return Int(text)
        }.bind(to: sizeListing).disposed(by: disposeBag)
        
        sizeTextField.rx.text.asObservable().subscribeNext { [weak self] (text) in
            guard let strongSelf = self else { return }
            strongSelf.sizeTextField.sizeToFit()
            if let text = text, !text.isEmpty {
                strongSelf.sizeTextField.attributedPlaceholder = nil
            } else {
                strongSelf.sizeTextField.attributedPlaceholder = strongSelf.placeholder
            }
        }.disposed(by: disposeBag)
    }

    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard textField == sizeTextField else { return true }
        guard let text = textField.text else { return true }
        guard text.count + string.count - range.length <= PostingAddDetailSizeView.maxLengthSize else { return false }
        return true
    }
    
    
    // MARK: - Actions
    
    @objc private func closeKeyboard() {
        sizeTextField.resignFirstResponder()
    }
    
    
    // MARK: - PostingViewConfigurable
    
    func setupContainerView(view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        layout(with: view).fill()
    }
    
    func setupView(viewModel: PostingDetailsViewModel) {
        guard let size = viewModel.currentSizeSquareMeters else { return }
            sizeTextField.text = String(size)
    }
}
