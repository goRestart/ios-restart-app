import Foundation
import LGComponents

final class ActivityIndicatorView: UIView {

    private let activity: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activity.color = .primaryColor
        return activity
    }()

    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    private func setupUI() {
        backgroundColor = .viewControllerBackground
        layer.cornerRadius = Metrics.margin
        
        addSubviewForAutoLayout(activity)
        NSLayoutConstraint.activate([
            activity.topAnchor.constraint(equalTo: topAnchor, constant: Metrics.margin),
            activity.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.margin),
            activity.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Metrics.margin),
            activity.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.margin)
        ])
    }
    
    func startAnimating() {
        activity.startAnimating()
    }

    func stopAnimating() {
        activity.stopAnimating()
    }
}
