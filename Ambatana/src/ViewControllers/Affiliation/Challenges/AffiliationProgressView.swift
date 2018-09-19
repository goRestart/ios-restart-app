import LGComponents
import RxCocoa
import RxSwift
import UIKit

final class AffiliationProgressView: UIView {
    private enum Layout {
        static let paddingTop: CGFloat = 10
        static let paddingBottom: CGFloat = 32
        static let progressHeight: CGFloat = 8
    }
    private enum Color {
        static let green = UIColor(rgb: 0xa3ce71)
    }

    private let progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.cornerRadius = Layout.progressHeight/2
        progressView.progressTintColor = Color.green
        progressView.trackTintColor = UIColor.veryLightGray
        return progressView
    }()


    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubviewForAutoLayout(progressView)
        let constraints = [progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
                           progressView.trailingAnchor.constraint(equalTo: trailingAnchor),
                           progressView.topAnchor.constraint(equalTo: topAnchor,
                                                             constant: Layout.paddingTop),
                           progressView.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                                constant: -Layout.paddingBottom),
                           progressView.heightAnchor.constraint(equalToConstant: Layout.progressHeight)]
        constraints.activate()
    }


    // MARK: - Setup

    func setup(data: ChallengeInviteFriendsData) {
        let current = Float(data.currentStep)
        let total = Float(data.stepsCount)
        progressView.progress = max(0, min(1, current / total))
    }
}
