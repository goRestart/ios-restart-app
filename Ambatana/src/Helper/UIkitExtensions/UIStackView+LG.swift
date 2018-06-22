import Foundation

extension UIStackView {
    static func horizontal() -> UIStackView {
        return .horizontal([])
    }

    static func horizontal(_ subviews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: subviews)
        stackView.axis = .horizontal
        return stackView
    }

    static func vertical() -> UIStackView {
        return .vertical([])
    }

    static func vertical(_ subviews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: subviews)
        stackView.axis = .vertical
        return stackView
    }

    func addArrangedSubviews(_ subviews: [UIView]) {
        subviews.forEach { addArrangedSubview($0) }
    }
}
