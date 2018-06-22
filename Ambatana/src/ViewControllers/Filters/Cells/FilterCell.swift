import Foundation
import LGComponents

protocol FilterCell: class {
    var topSeparator: UIView? { get set }
    var bottomSeparator: UIView? { get set }
    var rightSeparator: UIView? { get set }

    func addTopSeparator(toContainerView containerView: UIView)
}

extension FilterCell where Self: UICollectionReusableView {
    func addTopSeparator(toContainerView containerView: UIView) {
        let separator = makeHorizontalSeparator(insideContainerView: containerView)
        NSLayoutConstraint.activate([separator.topAnchor.constraint(equalTo: containerView.topAnchor)])
        self.topSeparator = separator
    }

    func addBottomSeparator(toContainerView containerView: UIView) {
        let separator = makeHorizontalSeparator(insideContainerView: containerView)
        NSLayoutConstraint.activate([separator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)])
        self.bottomSeparator = separator
    }

    func addRightSeparator(toContainerView containerView: UIView) {
        let separator = makeVerticalSeparator(insideContainerView: containerView)
        NSLayoutConstraint.activate([separator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)])
        self.rightSeparator = separator
    }

    private func makeSeparator() -> UIView {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = UIColor.lineGray
        return separator
    }

    private func makeVerticalSeparator(insideContainerView containerView: UIView) -> UIView {
        let separator = makeSeparator()
        containerView.addSubview(separator)
        let constraints = [
            separator.widthAnchor.constraint(equalToConstant: LGUIKitConstants.onePixelSize),
            separator.topAnchor.constraint(equalTo: containerView.topAnchor),
            separator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        return separator
    }

    private func makeHorizontalSeparator(insideContainerView containerView: UIView) -> UIView {
        let separator = makeSeparator()
        containerView.addSubview(separator)
        let constraints = [
            separator.heightAnchor.constraint(equalToConstant: LGUIKitConstants.onePixelSize),
            separator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        return separator
    }
}


