import Foundation
import UIKit

class ProgressView: UIView {
    
    private let progressView = UIView()
    private var progress: CGFloat = 0.0
    private var progressWidthConstraint: NSLayoutConstraint!
    public var animationDuration: TimeInterval = 0.3
    
    init(backgroundColor: UIColor, progressColor: UIColor) {
        super.init(frame: .zero)
        setupViews(backgroundColor: backgroundColor, progressColor: progressColor)
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(backgroundColor: UIColor, progressColor: UIColor) {
        self.backgroundColor = backgroundColor
        progressView.backgroundColor = progressColor
        addSubview(progressView)
    }
    
    private func setupConstraints() {
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressWidthConstraint = progressView.widthAnchor.constraint(equalTo: widthAnchor)
        let progressViewConstraints = [
            progressView.topAnchor.constraint(equalTo: topAnchor),
            progressView.bottomAnchor.constraint(equalTo:bottomAnchor),
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressWidthConstraint!
        ]
        NSLayoutConstraint.activate(progressViewConstraints)
    }
    
    func updateProgress(to newValue: CGFloat, animated: Bool) {
        progress = max(0.0, min(1.0, newValue))
        progressWidthConstraint.constant = -(frame.width * (1 - progress))
        UIView.animate(withDuration: animated ? animationDuration : 0) { [weak self] in
            self?.layoutIfNeeded()
        }
    }
}

