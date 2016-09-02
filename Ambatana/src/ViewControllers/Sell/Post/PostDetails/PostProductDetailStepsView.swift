//
//  PostProductDetailStepsView.swift
//  LetGo
//
//  Created by Eli Kohen on 17/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import KMPlaceholderTextView
import RxSwift


private enum PostDetailStep {
    case Title, Price, Description
}

class PostProductDetailStepsView: BaseView {

    @IBOutlet var contentView: UIView!

    @IBOutlet weak var titleContainer: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var titleInfo: UILabel!

    @IBOutlet weak var priceContainer: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var currencyButton: UIButton!

    @IBOutlet weak var descriptionContainer: UIView!
    @IBOutlet weak var descriptionTextView: KMPlaceholderTextView!
    @IBOutlet weak var charCounterLabel: UILabel!
    @IBOutlet weak var descriptionInfo: UILabel!

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var backButton: UIButton!

    private let viewModel: PostProductDetailViewModel

    private let step = Variable<PostDetailStep>(.Title)
    private let disposeBag = DisposeBag()

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
        switch step.value {
        case .Title:
            guard let titleTextField = titleTextField else { return false }
            return titleTextField.becomeFirstResponder()
        case .Price:
            guard let priceTextField = priceTextField else { return false }
            return priceTextField.becomeFirstResponder()
        case .Description:
            guard let descriptionTextView = descriptionTextView else { return false }
            return descriptionTextView.becomeFirstResponder()
        }
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
        loadNibNamed("PostProductDetailStepsView", contentView: { [weak self] in return self?.contentView })
        setupUI()
        setAccesibilityIds()
        setupRx()
    }

    private func setupUI() {
        contentView.backgroundColor = UIColor.clearColor()
        titleContainer.layer.cornerRadius = 10
        priceContainer.layer.cornerRadius = 10
        descriptionContainer.layer.cornerRadius = 10
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
        currencyButton.setTitle(viewModel.currencySymbol, forState: .Normal)

        doneButton.setStyle(.Primary(fontSize: .Big))
        backButton.setTitle(LGLocalizedString.sellBackButton, forState: .Normal)

        setupInitialStep()
    }

    private func setupRx() {
        priceTextField.rx_text.bindTo(viewModel.price).addDisposableTo(disposeBag)
        titleTextField.rx_text.bindTo(viewModel.title).addDisposableTo(disposeBag)
        descriptionTextView.rx_text.bindTo(viewModel.description).addDisposableTo(disposeBag)
        viewModel.descrCharactersLeft.asObservable().map { String($0) }.bindTo(charCounterLabel.rx_text)
            .addDisposableTo(disposeBag)
        doneButton.rx_tap.bindNext { [weak self] in
            guard let step = self?.step.value else { return }
            switch step {
            case .Title:
                self?.step.value = .Price
            case .Price:
                self?.step.value = .Description
            case .Description:
                self?.resignFirstResponder()
                self?.viewModel.doneButtonPressed()
            }
        }.addDisposableTo(disposeBag)

        backButton.rx_tap.bindNext { [weak self] in
            guard let step = self?.step.value else { return }
            switch step {
            case .Title:
                break
            case .Price:
                self?.step.value = .Title
            case .Description:
                self?.step.value = .Price
            }
        }.addDisposableTo(disposeBag)

        step.asObservable().skip(1).bindNext { [weak self] step in
            self?.animateToStep(step)
        }.addDisposableTo(disposeBag)
    }

    private func animateToStep(step: PostDetailStep) {
        let buttonTitle: String
        var titleAlpha: CGFloat = 0
        var priceAlpha: CGFloat = 0
        var descriptionAlpha: CGFloat = 0
        var backButtonAlpha: CGFloat = 1
        var responderView: UIView
        switch step {
        case .Title:
            buttonTitle = LGLocalizedString.commonNext
            titleAlpha = 1
            backButtonAlpha = 0
            responderView = titleTextField
        case .Price:
            buttonTitle = LGLocalizedString.commonNext
            priceAlpha = 1
            responderView = priceTextField
        case .Description:
            buttonTitle = LGLocalizedString.productPostDone
            descriptionAlpha = 1
            responderView = descriptionTextView
        }

        UIView.animateWithDuration(0.2, animations: { [weak self] in
            self?.titleContainer.alpha = titleAlpha
            self?.titleInfo.alpha = titleAlpha
            self?.priceContainer.alpha = priceAlpha
            self?.descriptionContainer.alpha = descriptionAlpha
            self?.descriptionInfo.alpha = descriptionAlpha
            self?.doneButton.setTitle(buttonTitle, forState: UIControlState.Normal)
            self?.backButton.alpha = backButtonAlpha
        }, completion: { _ in
                responderView.becomeFirstResponder()
        })
    }

    private func setupInitialStep() {
        titleContainer.alpha = 1
        titleInfo.alpha = 1
        priceContainer.alpha = 0
        descriptionContainer.alpha = 0
        descriptionInfo.alpha = 0
        doneButton.setTitle(LGLocalizedString.commonNext, forState: UIControlState.Normal)
        backButton.alpha = 0
    }
}



// MARK: - UITextFieldDelegate | UITextViewDelegate

extension PostProductDetailStepsView: UITextFieldDelegate, UITextViewDelegate {

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
        switch step.value {
        case .Title:
            step.value = .Price
            return false
        case .Price:
            step.value = .Description
            return false
        case .Description:
            return true
        }
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

extension PostProductDetailStepsView {
    func setAccesibilityIds() {
        doneButton.accessibilityId = .PostingDoneButton
        currencyButton.accessibilityId = .PostingCurrencyButton
        titleTextField.accessibilityId = .PostingTitleField
        priceTextField.accessibilityId = .PostingPriceField
        descriptionTextView.accessibilityId = .PostingDescriptionField
        backButton.accessibilityId = .PostingBackButton
    }
}
