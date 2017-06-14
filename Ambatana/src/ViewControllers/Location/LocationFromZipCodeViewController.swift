//
//  LocationFromZipCodeViewController.swift
//  LetGo
//
//  Created by Dídac on 23/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class LocationFromZipCodeViewController: KeyboardViewController, LocationFromZipCodeViewModelDelegate {

    static let fullAddressIconSize: CGFloat = 18

    fileprivate let closeButton: UIButton = UIButton()
    fileprivate let titleLabel: UILabel = UILabel()

    fileprivate let scrollView: UIScrollView = UIScrollView()

    fileprivate let infoSelectionContainer: UIView = UIView()
    fileprivate let currentLocationButton: UIButton = UIButton()
    fileprivate let leftLineView: UIView = UIView()
    fileprivate let orLabel: UILabel = UILabel()
    fileprivate let rightLineView: UIView = UIView()
    fileprivate let zipCodeTextField: UITextField = UITextField()
    fileprivate let minDigitsLabel: UILabel = UILabel()

    fileprivate let fullAddressContainer: UIView = UIView()
    fileprivate let pointerImageView: UIImageView = UIImageView()
    fileprivate let addressLabel: UILabel = UILabel()
    fileprivate let addressActivityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    fileprivate let setLocationButton: UIButton = UIButton()

    fileprivate let viewModel: LocationFromZipCodeViewModel

    fileprivate let disposeBag = DisposeBag()

    init(viewModel: LocationFromZipCodeViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        self.viewModel.delegate = self
        setupUI()
        setupLayout()
        setupRx()
        setupAccessibilityIds()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}


fileprivate extension LocationFromZipCodeViewController {
    func setupUI() {
        view.backgroundColor = UIColor.white
        closeButton.setImage(UIImage(named: "ic_close_red"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)

        titleLabel.font = UIFont.pageTitleFont
        titleLabel.textColor = UIColor.blackText
        titleLabel.text = LGLocalizedString.changeLocationApplyButton
        titleLabel.textAlignment = .center

        currentLocationButton.setTitle(LGLocalizedString.changeLocationZipCurrentLocationButton, for: .normal)
        currentLocationButton.setTitleColor(UIColor.primaryColor, for: .normal)
        currentLocationButton.setTitleColor(UIColor.primaryColorHighlighted, for: .highlighted)
        currentLocationButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        currentLocationButton.addTarget(self, action: #selector(currentLocationButtonPressed), for: .touchUpInside)

        leftLineView.backgroundColor = UIColor.gray
        rightLineView.backgroundColor = UIColor.gray
        orLabel.font = UIFont.smallBodyFont
        orLabel.textColor = UIColor.darkGrayText
        orLabel.text = LGLocalizedString.commonOr.uppercase
        orLabel.textAlignment = .center

        zipCodeTextField.font = UIFont.boldSystemFont(ofSize: 30)
        zipCodeTextField.textColor = UIColor.blackText
        zipCodeTextField.placeholder = LGLocalizedString.changeLocationZipPlaceholder
        zipCodeTextField.tintColor = UIColor.primaryColor
        zipCodeTextField.keyboardType = .numberPad
        zipCodeTextField.delegate = self
        zipCodeTextField.textAlignment = .center

        minDigitsLabel.font = UIFont.systemMediumFont(size: 13)
        minDigitsLabel.textColor = UIColor.grayText
        minDigitsLabel.text = LGLocalizedString.changeLocationZipMinDigitsLabel
        minDigitsLabel.textAlignment = .center

        addressLabel.font = UIFont.systemMediumFont(size: 13)
        addressLabel.textColor = UIColor.grayText
        addressLabel.text = ""
        addressLabel.textAlignment = .right
        pointerImageView.image = UIImage(named: "ic_location_light")
        pointerImageView.contentMode = .scaleAspectFit

        addressActivityIndicator.stopAnimating()
        addressActivityIndicator.hidesWhenStopped = true

        setLocationButton.frame = CGRect(x: 0, y: 0, width: 200, height: Metrics.buttonHeight)
        setLocationButton.setTitle(LGLocalizedString.changeLocationApplyButton, for: .normal)
        setLocationButton.setStyle(.primary(fontSize: .big))

        setLocationButton.addTarget(self, action: #selector(setLocationPressed), for: .touchUpInside)
    }

    func setupLayout() {

        let rootViews = [closeButton, titleLabel, infoSelectionContainer, fullAddressContainer, addressActivityIndicator]
        let infoSelectionSubviews = [currentLocationButton, leftLineView, orLabel, rightLineView, zipCodeTextField, minDigitsLabel]
        let fullAddressSubviews = [pointerImageView, addressLabel]

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        setLocationButton.translatesAutoresizingMaskIntoConstraints = false
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: rootViews)
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: infoSelectionSubviews)
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: fullAddressSubviews)

        view.addSubview(scrollView)
        scrollView.addSubviews(rootViews)
        infoSelectionContainer.addSubviews(infoSelectionSubviews)
        fullAddressContainer.addSubviews(fullAddressSubviews)
        view.addSubview(setLocationButton)

        scrollView.layout(with: view).top(by: Metrics.margin).left().right()
        scrollView.layout(with: setLocationButton).bottom(to: .top)

        closeButton.layout().width(Metrics.closeButtonHeight).height(Metrics.closeButtonHeight)
        closeButton.layout(with: scrollView).top(by: Metrics.veryShortMargin).left(by: Metrics.veryShortMargin)

        titleLabel.layout().height(20)
        titleLabel.layout(with: closeButton).centerY()
        titleLabel.layout(with: closeButton).leading(to: .trailing, by: Metrics.margin)
        titleLabel.layout(with: scrollView).centerX()

        infoSelectionContainer.layout(with: scrollView)
            .center()
            .trailingMargin(by: -Metrics.margin, relatedBy: .lessThanOrEqual)
            .leadingMargin(by: Metrics.margin, relatedBy: .greaterThanOrEqual)
        infoSelectionContainer.layout().width(50, relatedBy: .greaterThanOrEqual)
        infoSelectionContainer.layout(with: titleLabel).top(to: .bottomMargin, by: Metrics.margin, relatedBy: .greaterThanOrEqual)

        currentLocationButton.layout(with: infoSelectionContainer)
            .topMargin()
            .centerX()
            .trailingMargin(by: -Metrics.veryBigMargin, relatedBy: .lessThanOrEqual)
            .leadingMargin(by: Metrics.veryBigMargin, relatedBy: .greaterThanOrEqual)
        
        orLabel.layout(with: infoSelectionContainer).centerX()
        orLabel.layout(with: currentLocationButton).below(by: Metrics.veryBigMargin)
        orLabel.layout(with: leftLineView).leading(to: .trailing, by: Metrics.shortMargin).centerY()
        orLabel.layout(with: rightLineView).trailing(to: .leading, by: -Metrics.shortMargin).centerY()
        leftLineView.layout().height(LGUIKitConstants.onePixelSize)
        leftLineView.layout().width(50)
        rightLineView.layout().height(LGUIKitConstants.onePixelSize)
        rightLineView.layout().width(50)

        zipCodeTextField.layout(with: infoSelectionContainer).centerX()
        zipCodeTextField.layout(with: orLabel).below(by: Metrics.veryBigMargin)
        minDigitsLabel.layout(with: zipCodeTextField).below(by: Metrics.veryShortMargin)
        minDigitsLabel.layout(with: infoSelectionContainer).centerX().bottom()

        fullAddressContainer.layout(with: infoSelectionContainer).below(by: Metrics.veryBigMargin)
        fullAddressContainer.layout(with: scrollView).centerX()
        fullAddressContainer.layout(with: scrollView).trailingMargin(by: -Metrics.veryBigMargin, relatedBy: .lessThanOrEqual)
                                                    .leadingMargin(by: Metrics.veryBigMargin, relatedBy: .greaterThanOrEqual)

        addressActivityIndicator.layout(with: fullAddressContainer).center()
        pointerImageView.layout().height(LocationFromZipCodeViewController.fullAddressIconSize)
                                 .width(LocationFromZipCodeViewController.fullAddressIconSize)
        pointerImageView.layout(with: fullAddressContainer).left().top().bottom()
        addressLabel.layout(with: fullAddressContainer).right().top().bottom()
        addressLabel.layout(with: pointerImageView).left(to: .right)

        setLocationButton.layout().height(Metrics.buttonHeight)
        setLocationButton.layout(with: keyboardView).centerX().above(by: -Metrics.bigMargin)
        setLocationButton.layout(with: view).trailingMargin(by: Metrics.margin, relatedBy: .greaterThanOrEqual)
                                            .leadingMargin(by: Metrics.margin, relatedBy: .greaterThanOrEqual)
    }

    func setupRx() {
        viewModel.setLocationButtonVisible.asObservable().map{ !$0 }.bindTo(setLocationButton.rx.isHidden).addDisposableTo(disposeBag)
        viewModel.setLocationButtonEnabled.asObservable().bindTo(setLocationButton.rx.isEnabled).addDisposableTo(disposeBag)
        viewModel.fullAddressVisible.asObservable().map{ !$0 }.bindTo(fullAddressContainer.rx.isHidden).addDisposableTo(disposeBag)
        viewModel.setDigitsTipLabelVisible.asObservable().map{ !$0 }.bindTo(minDigitsLabel.rx.isHidden).addDisposableTo(disposeBag)
        viewModel.fullAddress.asObservable().bindTo(addressLabel.rx.text).addDisposableTo(disposeBag)
        viewModel.isResolvingAddress.asObservable().bindNext { [weak self] isResolving in
            if isResolving {
                self?.addressActivityIndicator.startAnimating()
                self?.zipCodeTextField.isEnabled = false
            } else {
                self?.addressActivityIndicator.stopAnimating()
                self?.zipCodeTextField.isEnabled = true
            }
        }.addDisposableTo(disposeBag)


        zipCodeTextField.rx.text.asObservable().distinctUntilChanged({ (s1, s2) -> Bool in
            s1 == s2
        }).bindTo(viewModel.zipCode).addDisposableTo(disposeBag)

        viewModel.zipCode.asObservable().bindTo(zipCodeTextField.rx.text).addDisposableTo(disposeBag)
    }

    dynamic func closeButtonPressed() {
        zipCodeTextField.resignFirstResponder()
        viewModel.close()
    }

    dynamic func currentLocationButtonPressed() {
        viewModel.updateAddressFromCurrentLocation()
    }

    dynamic func setLocationPressed() {
        zipCodeTextField.resignFirstResponder()
        viewModel.setNewLocation()
    }

    func setupAccessibilityIds() {
        closeButton.accessibilityId = AccessibilityId.editLocationFromZipCloseButton
        titleLabel.accessibilityId = AccessibilityId.editLocationFromZipTitleLabel
        currentLocationButton.accessibilityId = AccessibilityId.editLocationFromZipCurrentLocationButton
        zipCodeTextField.accessibilityId = AccessibilityId.editLocationFromZipTextField
        minDigitsLabel.accessibilityId = AccessibilityId.editLocationFromZipMinDigitsLabel
        addressLabel.accessibilityId = AccessibilityId.editLocationFromZipFullAddressLabel
        setLocationButton.accessibilityId = AccessibilityId.editLocationFromZipSetLocationButton
    }
}

// MARK: - UITextField

extension LocationFromZipCodeViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        viewModel.editingStart()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard !string.hasEmojis() else { return false }
        guard string.isOnlyDigits else { return false }
        let text = textField.textReplacingCharactersInRange(range, replacementString: string)
        guard text.characters.count <= viewModel.zipLenghtForCountry else { return false }
        return true
    }
}
