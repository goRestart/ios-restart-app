//
//  UserPhoneVerificationCodeInputTextField.swift
//  LetGo
//
//  Created by Sergi Gracia on 16/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

protocol VerificationCodeTextFieldDelegate: class {
    func didEndEditingWith(code: String)
}

final class VerificationCodeTextField: UIView {

    weak var delegate: VerificationCodeTextFieldDelegate?

    private let numberOfDigits: Int
    private let containerView = UIView()
    private var textFields: [UITextField] = []
    private var lines: [UIView] = []

    private var currentCode: String {
        return textFields
            .compactMap { $0.text }
            .reduce("", +)
    }

    private struct Layout {
        static let elementWidth: CGFloat = 26
        static let marginBetweenElements: CGFloat = 5
        static let textFieldHeight: CGFloat = 48
        static let lineHeight: CGFloat = 3
        static let inactiveLineColor: UIColor = .grayLighter
        static let activeLineColor: UIColor = .primaryColor
    }

    init(digits: Int) {
        self.numberOfDigits = digits
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        setupTextfieldsUI()
        setupLinesUI()

        addSubviewForAutoLayout(containerView)
        containerView.addSubviewsForAutoLayout(textFields + lines)

        setupConstraints()
    }

    private func setupTextfieldsUI() {
        for _ in 0..<numberOfDigits {
            let textField = CodeTextField(frame: .zero)
            textField.tintColor = .clear
            textField.keyboardType = .numberPad
            textField.font = .smsVerificationCodeInputTextfieldText
            textField.textColor = .blackText
            textField.delegate = self
            textField.codeTextFieldDelegate = self
            textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
            textFields.append(textField)
        }
    }

    private func setupLinesUI() {
        for _ in 0..<numberOfDigits {
            let line = UIView()
            line.backgroundColor = Layout.inactiveLineColor
            lines.append(line)
        }
    }

    private func setupConstraints() {
        var constraints: [NSLayoutConstraint] = []

        constraints += [
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ]

        for (textField, line) in zip(textFields, lines) {
            guard let index = textFields.index(of: textField) else { continue }

            // Horizontal positioning
            if index == 0 {
                constraints += [
                    textField.leftAnchor.constraint(equalTo: containerView.leftAnchor),
                ]
            } else {
                constraints += [
                    textField.leftAnchor.constraint(equalTo: textFields[index - 1].rightAnchor,
                                                    constant: Layout.marginBetweenElements)
                ]

                if index == numberOfDigits - 1 {
                    constraints += [
                        textField.rightAnchor.constraint(equalTo: containerView.rightAnchor)
                    ]
                }
            }

            constraints += [
                line.leftAnchor.constraint(equalTo: textField.leftAnchor),
                line.rightAnchor.constraint(equalTo: textField.rightAnchor)
            ]

            // Vertical positioning
            constraints += [
                textField.topAnchor.constraint(equalTo: containerView.topAnchor),
                line.topAnchor.constraint(equalTo: textField.bottomAnchor),
                line.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ]

            // Dimensions
            constraints += [
                textField.widthAnchor.constraint(equalToConstant: Layout.elementWidth),
                line.widthAnchor.constraint(equalToConstant: Layout.elementWidth),
                line.heightAnchor.constraint(equalToConstant: Layout.lineHeight),
            ]
        }

        NSLayoutConstraint.activate(constraints)
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        if let textField = textFields.find(where: {
            ($0.text?.isEmpty ?? true) || textFields.last == $0
        }) {
            focusOnDigit(atIndex: textFields.index(of: textField) ?? 0)
        }
        return true
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            guard let textFields = self?.textFields,
                let lines = self?.lines else { return }
            for (textField, line) in zip(textFields, lines) {
                textField.resignFirstResponder()
                line.backgroundColor = Layout.inactiveLineColor
            }
        })
        return true
    }

    func clearText() {
        textFields.forEach { $0.text = nil }
    }

    private func focusOnDigit(atIndex index: Int) {
        guard index < textFields.count else { return }

        textFields[index].becomeFirstResponder()

        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.lines
                .filter { $0 != self?.lines[index] }
                .forEach { $0.backgroundColor = Layout.inactiveLineColor }
            self?.lines[index].backgroundColor = Layout.activeLineColor
        })
    }
}

// MARK: - TextField Delegate

extension VerificationCodeTextField: UITextFieldDelegate, CodeTextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let aSet = NSCharacterSet.decimalDigits.inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let currentIndex = textFields.index(of: textField),
            let text = textField.text, !text.isEmpty else { return }

        if currentIndex == numberOfDigits-1 {
            resignFirstResponder()
            delegate?.didEndEditingWith(code: currentCode)
        } else {
            focusOnDigit(atIndex: currentIndex + 1)
        }
    }

    func textFieldDidDelete(_ textField: UITextField) {
        guard let currentIndex = textFields.index(of: textField),
            textField.text?.count == 0,
            currentIndex > 0 else { return }
        textFields[currentIndex - 1].text = ""
        focusOnDigit(atIndex: currentIndex - 1)
    }
}

// MARK: - CodeTextField Component

private protocol CodeTextFieldDelegate {
    func textFieldDidDelete(_ textField: UITextField)
}

private class CodeTextField: UITextField {
    var codeTextFieldDelegate: CodeTextFieldDelegate?

    override func deleteBackward() {
        super.deleteBackward()
        codeTextFieldDelegate?.textFieldDidDelete(self)
    }
}
