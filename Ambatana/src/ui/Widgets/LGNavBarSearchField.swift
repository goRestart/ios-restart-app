//
//  LGNavBarSearchField.swift
//  LetGo
//
//  Created by Dídac on 11/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

final class LGNavBarSearchField: UIView {
    
    private var stackCenterConstraint: NSLayoutConstraint?
    private var stackLeftConstraint: NSLayoutConstraint?
    private var initialSearchValue = ""
    
    //  MARK: - Subviews
    
    private let containerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = LGNavBarMetrics.Container.backgroundColor
        view.layer.cornerRadius =  LGNavBarMetrics.Container.height/2
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .top
        return stackView
    }()
    
    private let magnifierIcon: UIImageView = {
        let logo = UIImageView(image: #imageLiteral(resourceName: "list_search"))
        logo.contentMode = .scaleAspectFit
        return logo
    }()
    
    private let logoIcon: UIImageView = {
        let logo = UIImageView(image: #imageLiteral(resourceName: "navbar_logo"))
        logo.contentMode = .scaleAspectFit
        return logo
    }()
    
    let searchTextField: LGTextField = {
        let searchTextField = LGTextField()
        searchTextField.clipsToBounds = true
        searchTextField.font = LGNavBarMetrics.Searchfield.font
        searchTextField.textColor = LGNavBarMetrics.Searchfield.textColor
        searchTextField.clearButtonMode = .always
        searchTextField.clearButtonOffset = LGNavBarMetrics.Searchfield.clearButtonOffset
        searchTextField.insetX = LGNavBarMetrics.Searchfield.insetX
        return searchTextField
    }()
    
    init(_ text: String?) {
        super.init(frame: .zero)
        setupTextFieldWithText(text)
        setupViews()
        setupConstraints()
        endEdit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubviewForAutoLayout(containerView)
        stackView.addArrangedSubview(magnifierIcon)
        stackView.addArrangedSubview(logoIcon)
        containerView.addSubviewsForAutoLayout([searchTextField, stackView])
    }
    
    private func setupConstraints() {
        containerView.layout(with: self).fillHorizontal().centerY()
        containerView.layout().height(LGNavBarMetrics.Container.height)
        
        searchTextField.layout(with: containerView).fill()
        magnifierIcon.layout()
            .width(LGNavBarMetrics.Magnifier.width)
            .height(LGNavBarMetrics.Magnifier.height)

        logoIcon.layout().height(LGNavBarMetrics.Logo.height)
        
        stackView.layout(with: containerView).centerY(by: LGNavBarMetrics.StackView.verticalDiference)
        stackCenterConstraint = stackView.centerXAnchor.constraint(equalTo: searchTextField.centerXAnchor)
        stackLeftConstraint = stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.shortMargin)
    }

    // MARK: - Public Methods
    
    func beginEdit() {
        setupTextFieldEditMode()
    }
    
    func endEdit() {
        searchTextField.text = initialSearchValue
        
        if let text = searchTextField.text, !text.isEmpty {
            setupTextFieldEditMode()
        } else {
            setupTextFieldCleanMode()
        }
        searchTextField.resignFirstResponder()
    }
    
    // MARK: - Private Methods
    
    private func setupTextFieldWithText(_ text: String?) {
        if let actualText = text {
            initialSearchValue = actualText
        }
        searchTextField.text = initialSearchValue
    }
    
    private func setupTextFieldEditMode() {
        logosLeft()
        logoIcon.alphaAnimated(0) { [weak self] finished in
            if finished {
                self?.searchTextField.showCursor = true
            }
        }
    }
    
    private func setupTextFieldCleanMode() {
        logosCentered()
        logoIcon.alphaAnimated(1) { [weak self] finished in
            if finished {
                self?.searchTextField.showCursor = false
            }
        }
    }
    
    private func logosCentered() {
        stackCenterConstraint?.isActive = true
        stackLeftConstraint? .isActive = false
    }
    
    private func logosLeft() {
        stackCenterConstraint?.isActive = false
        stackLeftConstraint? .isActive = true
    }
    
    override var intrinsicContentSize: CGSize { return UILayoutFittingExpandedSize }

}
