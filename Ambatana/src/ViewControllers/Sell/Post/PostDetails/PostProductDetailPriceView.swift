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
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var priceViewContainer: UIView!
    @IBOutlet weak var priceFieldContainer: UIView!
    @IBOutlet weak var postFreeViewContainer: UIView!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var freePostSwitch: UISwitch!
    @IBOutlet weak var giveAwayContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorContainerDistanceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var priceContainerHeightConstraint: NSLayoutConstraint!
    
    static let separatorContainerDistance: CGFloat = 1
    static let containerHeight: CGFloat = 55
    
    @IBOutlet weak var freePostLabel: UILabel!
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
        setAccesibilityIds()
        setupRx()
    }

    private func setupUI() {
        infoLabel.text = LGLocalizedString.productPostPriceLabel.uppercase
        priceViewContainer.layer.cornerRadius = 15.0
        postFreeViewContainer.backgroundColor = UIColor(white: 0.9, alpha: 0.3)
        freePostSwitch.isUserInteractionEnabled = false
        priceFieldContainer.backgroundColor = UIColor(white: 0.9, alpha: 0.3)
        freePostLabel.text = LGLocalizedString.sellPostFreeLabel
        freePostLabel.textColor = UIColor.white
        priceTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.productNegotiablePrice,
                                                                  attributes: [NSForegroundColorAttributeName: UIColor.white])
        doneButton.setTitle(LGLocalizedString.productPostDone, for: UIControlState())
        currencyLabel.text = viewModel.currencySymbol
        currencyLabel.textColor = UIColor.white
        doneButton.setStyle(.primary(fontSize: .big))
        showFreeOption(viewModel.freeOptionAvailable)

        let tap = UITapGestureRecognizer(target: self, action: #selector(freeCellPressed))
        postFreeViewContainer.addGestureRecognizer(tap)
    }

    private func setupRx() {
        priceTextField.rx_text.bindTo(viewModel.price).addDisposableTo(disposeBag)
        viewModel.isFree.asObservable().bindTo(freePostSwitch.rx_valueAnimated).addDisposableTo(disposeBag)
        viewModel.isFree.asObservable().bindNext{[weak self] active in
            self?.showPriceTextContainer(!active)
            }.addDisposableTo(disposeBag)
        doneButton.rx_tap.bindNext { [weak self] in
            self?.priceTextField.resignFirstResponder()
            self?.viewModel.doneButtonPressed()
        }.addDisposableTo(disposeBag)
    }
    
    private func showFreeOption(_ show: Bool) {
        if show {
            giveAwayContainerHeightConstraint.constant = PostProductDetailPriceView.containerHeight
            separatorContainerDistanceConstraint.constant = PostProductDetailPriceView.separatorContainerDistance
        } else {
            giveAwayContainerHeightConstraint.constant = 0
            separatorContainerDistanceConstraint.constant = 0
        }
    }
    private func showPriceTextContainer(_ show: Bool) {
        if show {
            priceContainerHeightConstraint.constant = PostProductDetailPriceView.containerHeight
            separatorContainerDistanceConstraint.constant = PostProductDetailPriceView.separatorContainerDistance
        } else {
            priceContainerHeightConstraint.constant = 0
            separatorContainerDistanceConstraint.constant = 0
            priceTextField.resignFirstResponder()
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        } )
    }

    dynamic private func freeCellPressed() {
        viewModel.freeCellPressed()
    }
}


// MARK: - UITextFieldDelegate

extension PostProductDetailPriceView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard textField == priceTextField else { return true }
        return textField.shouldChangePriceInRange(range, replacementString: string, acceptsSeparator: true)
    }
}


// MARK: - Accesibility

extension PostProductDetailPriceView {
    func setAccesibilityIds() {
        doneButton.accessibilityId = .PostingDoneButton
        currencyLabel.accessibilityId = .PostingCurrencyLabel
        priceTextField.accessibilityId = .PostingPriceField
    }
}
