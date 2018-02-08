//
//  PostingAddDetailSizeView.swift
//  LetGo
//
//  Created by Juan Iglesias on 22/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//


import LGCoreKit
import RxSwift


class PostingAddDetailSizeView: UIView, PostingViewConfigurable, UITextFieldDelegate {
    
    static private let sizeLabelWidth: CGFloat = 60
    static private let sizeViewMargin: CGFloat = 20
    static private let sizeTextFieldWidth: CGFloat = 150
    static private let maxLengthSize: Int = 8
    
    private let sizeLabel = UILabel()
    private let sizeTextField = UITextField()
    private let contentTextFieldView = UIView()
    
    private var textFieldContainerHeightConstraint = NSLayoutConstraint()
    
    private var sizeListing = Variable<Int?>(nil)
    
    var sizeListingObservable: Observable<Int?> {
        return sizeListing.asObservable()
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
        sizeLabel.textAlignment = .center
        sizeLabel.textColor = UIColor.white
        sizeLabel.font = UIFont.systemBoldFont(size: 26)
        sizeTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.realEstateSizeSquareMetersPlaceholder,
                                                                  attributes: [NSAttributedStringKey.foregroundColor: UIColor.grayLight,
                                                                               NSAttributedStringKey.font: UIFont.systemBoldFont(size: 26)])
        sizeTextField.keyboardType = .numberPad
        sizeTextField.font = UIFont.systemBoldFont(size: 26)
        sizeTextField.textColor = UIColor.white
        sizeTextField.autocorrectionType = .no
        sizeTextField.autocapitalizationType = .none
        sizeTextField.delegate = self
        
        let tapBackground = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        addGestureRecognizer(tapBackground)
        
        sizeLabel.text = Constants.sizeSquareMetersUnit
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
        
        sizeTextField.layout(with: contentTextFieldView).left().fillVertical()
        sizeTextField.layout().width(PostingAddDetailSizeView.sizeTextFieldWidth)
        
        sizeLabel.layout(with: sizeTextField).right(by: 50)
        sizeLabel.layout(with: contentTextFieldView).fillVertical()
    }
    
    private func setupRx() {
        sizeTextField.rx.text.asObservable().map { (text) -> Int? in
            guard let text = text else { return nil }
            return Int(text)
        }.bind(to: sizeListing).disposed(by: disposeBag)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard textField == sizeTextField else { return true }
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= PostingAddDetailSizeView.maxLengthSize
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
