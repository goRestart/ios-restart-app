//
//  PostProductDetailFullView.swift
//  LetGo
//
//  Created by Eli Kohen on 17/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import RxSwift
import KMPlaceholderTextView

class PostProductDetailFullView: BaseView {

    @IBOutlet var contentView: UIView!

    @IBOutlet weak var titleContainer: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var titleInfo: UILabel!

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var descriptionTextView: KMPlaceholderTextView!
    @IBOutlet weak var charCounterLabel: UILabel!
    @IBOutlet weak var descriptionInfo: UILabel!

    @IBOutlet weak var doneButton: UIButton!

    private let viewModel: PostProductDetailViewModel

    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init(viewModel: PostProductDetailViewModel) {
        self.init(viewModel: viewModel, frame: CGRect.zero)
    }

    init(viewModel: PostProductDetailViewModel, frame: CGRect) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, frame: frame)
        setup()
    }

    init?(viewModel: PostProductDetailViewModel, coder aDecoder: NSCoder) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, coder: aDecoder)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func becomeFirstResponder() -> Bool {
        guard let titleTextField = titleTextField else { return false }
        return titleTextField.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        guard let priceTextField = priceTextField, titleTextField = titleTextField,
            descriptionTextView = descriptionTextView else { return false }
        titleTextField.resignFirstResponder()
        priceTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
        return true
    }


    // MARK: - Private

    private func setup() {
        loadNibNamed("PostProductDetailFullView", contentView: { [weak self] in return self?.contentView })
        setupUI()
        setAccesibilityIds()
        setupRx()
    }

    private func setupUI() {
        contentView.backgroundColor = UIColor.clearColor()
        titleContainer.layer.cornerRadius = 10
        priceTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.productNegotiablePrice,
                                            attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        priceTextField.tintColor = UIColor.whiteColor()
        titleTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.sellTitleFieldHint,
                       attributes: [NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.7)])
        titleTextField.tintColor = UIColor.whiteColor()
        descriptionTextView.placeholder = LGLocalizedString.sellDescriptionFieldHint
        descriptionTextView.placeholderColor = UIColor.whiteColor().colorWithAlphaComponent(0.7)
        descriptionTextView.tintColor = UIColor.whiteColor()
        priceLabel.text = LGLocalizedString.sellPriceField
        titleInfo.text = LGLocalizedString.sellTitleInformation
        descriptionInfo.text = LGLocalizedString.sellDescriptionInformation
        doneButton.setTitle(LGLocalizedString.productPostDone, forState: UIControlState.Normal)
        currencyButton.setTitle(viewModel.currencySymbol, forState: UIControlState.Normal)

        doneButton.setStyle(.Primary(fontSize: .Big))
    }

    private func setupRx() {
        priceTextField.rx_text.bindTo(viewModel.price).addDisposableTo(disposeBag)
        titleTextField.rx_text.bindTo(viewModel.title).addDisposableTo(disposeBag)
        descriptionTextView.rx_text.bindTo(viewModel.description).addDisposableTo(disposeBag)
        viewModel.descrCharactersLeft.asObservable().map { String($0) }.bindTo(charCounterLabel.rx_text)
            .addDisposableTo(disposeBag)
        doneButton.rx_tap.bindNext { [weak self] in
            self?.resignFirstResponder()
            self?.viewModel.doneButtonPressed()
        }.addDisposableTo(disposeBag)
    }
}


// MARK: - UITextFieldDelegate | UITextViewDelegate

extension PostProductDetailFullView: UITextFieldDelegate, UITextViewDelegate {

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField === titleTextField && string.hasEmojis() {
            let text = textField.textReplacingCharactersInRange(range, replacementString: string.stringByRemovingEmoji())
            textField.text = text
            return false
        } else if textField === priceTextField {
            return textField.shouldChangePriceInRange(range, replacementString: string, acceptsSeparator: true)
        }
        return true
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField === titleTextField {
            priceTextField.becomeFirstResponder()
            return false
        } else if textField === priceTextField {
            descriptionTextView.becomeFirstResponder()
            return false
        }
        return true
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        guard let textViewText = textView.text else { return true }
        let cleanReplacement = text.stringByRemovingEmoji()
        let finalText = (textViewText as NSString).stringByReplacingCharactersInRange(range, withString: cleanReplacement)
        if text.hasEmojis() {
            //Forcing the new text (without emojis) by returning false
            textView.text = finalText
            return false
        }
        return true
    }
}


// MARK: - Accesibility

extension PostProductDetailFullView {
    func setAccesibilityIds() {
        doneButton.accessibilityId = .PostingDoneButton
        currencyButton.accessibilityId = .PostingCurrencyButton
        titleTextField.accessibilityId = .PostingTitleField
        priceTextField.accessibilityId = .PostingPriceField
        descriptionTextView.accessibilityId = .PostingDescriptionField
    }
}
