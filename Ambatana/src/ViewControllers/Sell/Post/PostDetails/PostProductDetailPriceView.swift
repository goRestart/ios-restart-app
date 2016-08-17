//
//  PostProductDetailPriceView.swift
//  LetGo
//
//  Created by Eli Kohen on 17/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class PostProductDetailPriceView: BaseView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var priceFieldContainer: UIView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!

    private let viewModel: PostProductDetailViewModel

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
        guard let priceTextField = priceTextField else { return false }
        return priceTextField.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        guard let priceTextField = priceTextField else { return false }
        return priceTextField.resignFirstResponder()
    }

    private func setup() {
        loadNibNamed("PostProductDetailPriceView", contentView: { [weak self] in return self?.contentView })
        setupUI()
        setupRx()
    }

    private func setupUI() {

        //i18n
        infoLabel.text = LGLocalizedString.productPostPriceLabel.uppercase
        priceTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.productNegotiablePrice,
                                                                  attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        doneButton.setTitle(LGLocalizedString.productPostDone, forState: UIControlState.Normal)

        //Layers
        doneButton.setStyle(.Primary(fontSize: .Medium))
        priceFieldContainer.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        priceFieldContainer.layer.borderColor = UIColor.whiteColor().CGColor
        priceFieldContainer.layer.borderWidth = 1

        currencyButton.setTitle(viewModel.currencySymbol, forState: UIControlState.Normal)
    }

    private func setupRx() {
        priceTextField.rx_text.bindTo(viewModel.price).addDisposableTo(disposeBag)
        doneButton.rx_tap.bindNext { [weak self] in
            self?.priceTextField.resignFirstResponder()
            self?.viewModel.doneButtonPressed()
        }.addDisposableTo(disposeBag)
    }
}


// MARK: - UITextFieldDelegate

extension PostProductDetailPriceView: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool {
        guard textField == priceTextField else { return true }
        return textField.shouldChangePriceInRange(range, replacementString: string)
    }
}
