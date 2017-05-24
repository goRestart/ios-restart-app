//
//  LocationFromZipCodeViewController.swift
//  LetGo
//
//  Created by Dídac on 23/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import UIKit

class LocationFromZipCodeViewController: KeyboardViewController {


    let closeButton: UIButton = UIButton()
    let titleLabel: UILabel = UILabel()

    let scrollView: UIScrollView = UIScrollView()

    let infoSelectionContainer: UIView = UIView()
    let currentLocationButton: UIButton = UIButton()
    let leftLineView: UIView = UIView()
    let orLabel: UILabel = UILabel()
    let rightLineView: UIView = UIView()
    let zipCodeTextField: UITextField = UITextField()
    let minDigitsLabel: UILabel = UILabel()

    let fullAddressContainer: UIView = UIView()
    let pointerImageView: UIImageView = UIImageView()
    let addressLabel: UILabel = UILabel()

    let setLocationButton: UIButton = UIButton()

    var viewModel: LocationFromZipCodeViewModel

    init(viewModel: LocationFromZipCodeViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        setupUI()
        setupLayout()
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
        closeButton.setImage(UIImage(named: "ic_close_red"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)


        titleLabel.font = UIFont.pageTitleFont
        titleLabel.textColor = UIColor.blackText
        titleLabel.text = "_ Set location"
        titleLabel.textAlignment = .center

        currentLocationButton.setTitle("_Current location", for: .normal)
        currentLocationButton.setTitleColor(UIColor.primaryColor, for: .normal)
        currentLocationButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)

        leftLineView.backgroundColor = UIColor.gray
        rightLineView.backgroundColor = UIColor.gray
        orLabel.font = UIFont.mediumBodyFont
        orLabel.textColor = UIColor.darkGrayText
        orLabel.text = LGLocalizedString.commonOr.uppercase
        orLabel.textAlignment = .center

        zipCodeTextField.font = UIFont.boldSystemFont(ofSize: 30)
        zipCodeTextField.textColor = UIColor.blackText
        zipCodeTextField.placeholder = "_Zipcode"
        zipCodeTextField.tintColor = UIColor.primaryColor
        zipCodeTextField.keyboardType = .numberPad

        minDigitsLabel.font = UIFont.systemMediumFont(size: 13)
        minDigitsLabel.textColor = UIColor.grayText
        minDigitsLabel.text = "_ Must be 5 digits"
        minDigitsLabel.textAlignment = .center

        addressLabel.font = UIFont.systemMediumFont(size: 13)
        addressLabel.textColor = UIColor.grayText
        addressLabel.text = "_Tromaville, XD 66669"
        addressLabel.textAlignment = .right
        pointerImageView.image = UIImage(named: "ic_location")
        pointerImageView.contentMode = .scaleAspectFit

        setLocationButton.setStyle(.primary(fontSize: .big))
        setLocationButton.setTitle("_ Set location", for: .normal)

        setLocationButton.addTarget(self, action: #selector(setLocationPressed), for: .touchUpInside)

    }

    func setupLayout() {

        let rootViews = [closeButton, titleLabel, infoSelectionContainer, fullAddressContainer]
        let infoSelectionSubviews = [currentLocationButton, leftLineView, orLabel, rightLineView, zipCodeTextField, minDigitsLabel]
        let fullAddressSubviews = [pointerImageView, addressLabel]

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        setLocationButton.translatesAutoresizingMaskIntoConstraints = false
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: rootViews)
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: infoSelectionSubviews)
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: fullAddressSubviews)
        view.addSubview(scrollView)
        view.addSubview(setLocationButton)
        scrollView.addSubviews(rootViews)
        infoSelectionContainer.addSubviews(infoSelectionSubviews)
        fullAddressContainer.addSubviews(fullAddressSubviews)

        scrollView.layout(with: view).top(by: Metrics.margin).left().right()
        scrollView.layout(with: keyboardView).bottom(to: .top)

        closeButton.layout().width(20).height(20)
        closeButton.layout(with: scrollView).top(by: Metrics.margin).left(by: Metrics.margin)

        titleLabel.layout().height(20)
        titleLabel.layout(with: scrollView).top(by: Metrics.margin).centerX()
        titleLabel.layout(with: closeButton).leading(to: .trailing, by: Metrics.margin)

        infoSelectionContainer.layout(with: scrollView).center()
        infoSelectionContainer.layout(with: scrollView).trailingMargin().leadingMargin()
        infoSelectionContainer.layout(with: titleLabel).top(to: .bottomMargin, by: Metrics.margin, relatedBy: .greaterThanOrEqual)

        currentLocationButton.layout(with: infoSelectionContainer).topMargin().centerX()
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


        fullAddressContainer.layout().height(18)
        fullAddressContainer.layout(with: infoSelectionContainer).below(by: Metrics.veryBigMargin)
        fullAddressContainer.layout(with: scrollView).centerX()
        fullAddressContainer.layout(with: scrollView).trailingMargin(by: Metrics.veryBigMargin, relatedBy: .greaterThanOrEqual)
                                                     .leadingMargin(by: Metrics.veryBigMargin, relatedBy: .greaterThanOrEqual)

        fullAddressContainer.layout(with: pointerImageView).left().top().bottom()
        fullAddressContainer.layout(with: addressLabel).right().top().bottom()
        addressLabel.layout(with: pointerImageView).toRight()

        setLocationButton.layout(with: view).centerX().bottom()

//        let zipCodeTextField: UITextField = UITextField()
//        let minDigitsLabel: UILabel = UILabel()

//        navigationMakeButton.layout(with: navigationModelButton)
//            .trailing(to: .leading, by: -Metrics.margin)


//        navigationMakeButton.layout(with: navigationView)
//            .leading(to: .leadingMargin, by: Metrics.margin, relatedBy: .greaterThanOrEqual)
//            .top(by: Metrics.shortMargin)

    }

    dynamic func closeButtonPressed() {
        dismiss(animated: true, completion: nil)
    }

    dynamic func setLocationPressed() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextField

extension LocationFromZipCodeViewController: UITextFieldDelegate {

}
