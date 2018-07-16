import Foundation
import RxSwift
import UIKit
import LGComponents

@IBDesignable class AutocompleteField: LGTextField {
    @IBInspectable var completionColor : UIColor = UIColor(white: 0, alpha: 0.22)
    var suggestion : String? {
        didSet {
            updateLabel()
        }
    }
    // Move the suggestion label up or down. Sometimes there's a small difference, and this can be used to fix it.
    var pixelCorrection : CGFloat = 0

    fileprivate var label = UILabel()
    fileprivate let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
        setupRx()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLabel()
        setupRx()
    }

    // ovverride to set frame of the suggestion label whenever the textfield frame changes.
    override func layoutSubviews() {
        label.frame = CGRect(x: insetX, y: insetY + pixelCorrection,
                             width: frame.width - 2 * insetX - clearButtonSide / 2,
                             height: frame.height - 2 * insetY)
        super.layoutSubviews()
    }
}


// MARK: - Private methods

fileprivate extension AutocompleteField {
    /**
     Sets up the suggestion label with the same font styling and alignment as the textfield.
     */
    func setupLabel() {
        setLabel(text: nil)
        label.lineBreakMode = .byClipping
        label.allowsDefaultTighteningForTruncation = false
        addSubview(label)
    }

    /**
     Sets up the reactive bindings.
    */
    func setupRx() {
        rx.text.bind { [weak self] text in
            self?.updateLabel()
        }.disposed(by: disposeBag)
    }

    /**
     Updates the content of the suggestion label.
     */
    func updateLabel() {
        setLabel(text: suggestion)
    }

    /**
     Set content of the suggestion label.
     - parameter text: Suggestion text
     */
    func setLabel(text: String?) {
        guard let text = text, !text.isEmpty else {
            label.attributedText = nil
            return
        }

        // create an attributed string instead of the regular one.
        // In this way we can hide the letters in the suggestion that the user has already written.
        let attributedString = NSMutableAttributedString(
            string: text,
            attributes: [NSAttributedStringKey.font: font ?? UIFont.systemFont(size: 17),
                         NSAttributedStringKey.foregroundColor: completionColor])

        // Hide the letters that are under the fields text.
        // If the suggestion is abcdefgh and the user has written abcd
        // we want to hide those letters from the suggestion.
        if let inputText = self.text, attributedString.length >= inputText.count {
            attributedString.addAttribute(NSAttributedStringKey.foregroundColor,
                                          value: UIColor.clear,
                                          range: NSRange(location: 0,
                                                         length: inputText.count)
            )
        }

        label.attributedText = attributedString
        label.textAlignment = textAlignment
    }
}
