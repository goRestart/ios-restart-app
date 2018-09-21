import LGComponents
import LGCoreKit
import RxCocoa
import RxSwift
import UIKit

final class AffiliationProgressView: UIView {
    private enum Layout {
        static let paddingTop: CGFloat = 18
        static let paddingBottom: CGFloat = 38
        static let progressHeight: CGFloat = 8
        static let stepSide: CGFloat = progressHeight/2
        static let milestoneLabelVSpacing: CGFloat = 12
        static let milestoneCompletedIconShadowOffset: CGFloat = 1
        static let milestoneCompletedIconEdgePadding: CGFloat = Layout.milestoneCompletedIconSide / 2 - 1
        static let milestoneCompletedIconSide: CGFloat = 22
    }
    private enum Color {
        static let green = UIColor(rgb: 0xa3ce71)
        static let alphaGray = UIColor.black.withAlphaComponent(0.15)
    }

    private let progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.cornerRadius = Layout.progressHeight/2
        progressView.progressTintColor = Color.green
        progressView.trackTintColor = UIColor.veryLightGray
        return progressView
    }()
    private var stepIndicators: [UIView] = []
    private var milestoneIndicators: [UIView] = []


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

        addStepIndicators(stepsCount: data.stepsCount)
        addMilestoneIndicators(milestones: data.milestones,
                               stepsCount: data.stepsCount,
                               currentStep: data.currentStep)
    }

    private func addStepIndicators(stepsCount: Int) {
        stepIndicators.forEach { $0.removeFromSuperview() }
        stepIndicators.removeAll()
        guard stepsCount > 1 else { return }

        for index in 1..<stepsCount {
            guard let stepIndicator = makeStepIndicator(index: index,
                                                        stepsCount: stepsCount) else { continue }
            stepIndicators.append(stepIndicator)
        }
    }

    private func makeStepIndicator(index: Int,
                                   stepsCount: Int) -> UIView? {
        guard 1..<stepsCount ~= index else { return nil }

        let stepIndicatorView = UIView()
        stepIndicatorView.backgroundColor = Color.alphaGray
        stepIndicatorView.cornerRadius = Layout.stepSide/2

        addSubviewForAutoLayout(stepIndicatorView)
        let multiplier = CGFloat(index) / CGFloat(stepsCount)
        let constraints = [NSLayoutConstraint(item: stepIndicatorView,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: progressView,
                                              attribute: .trailing,
                                              multiplier: multiplier,
                                              constant: 0),
                           stepIndicatorView.centerYAnchor.constraint(equalTo: progressView.centerYAnchor),
                           stepIndicatorView.heightAnchor.constraint(equalToConstant: Layout.stepSide),
                           stepIndicatorView.widthAnchor.constraint(equalToConstant: Layout.stepSide)]
        constraints.activate()
        return stepIndicatorView
    }

    private func addMilestoneIndicators(milestones: [ChallengeMilestone],
                                        stepsCount: Int,
                                        currentStep: Int) {
        milestoneIndicators.forEach { $0.removeFromSuperview() }
        milestoneIndicators.removeAll()
        for milestone in milestones {
            let views = addMilestoneIndicator(milestone: milestone,
                                              stepsCount: stepsCount,
                                              currentStep: currentStep)
            milestoneIndicators.append(contentsOf: views)
        }
    }

    private func addMilestoneIndicator(milestone: ChallengeMilestone,
                                       stepsCount: Int,
                                       currentStep: Int) -> [UIView] {
        let stepIndex = milestone.stepIndex
        let isNoStep = stepIndex == 0
        let isLastStep = stepIndex == stepsCount
        let isStepCompleted = currentStep >= milestone.stepIndex
        let stepIndicator = stepIndicators[safeAt: stepIndex - 1]

        var views = [UIView]()
        let label = UILabel()
        let completedIcon = UIImageView()
        let labelXConstraint: NSLayoutConstraint?
        let iconCenterXConstraint: NSLayoutConstraint?

        if isNoStep {
            labelXConstraint = label.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor)
            iconCenterXConstraint = completedIcon.centerXAnchor.constraint(equalTo: progressView.leadingAnchor,
                                                                           constant: Layout.milestoneCompletedIconEdgePadding)
        } else if isLastStep {
            labelXConstraint = label.trailingAnchor.constraint(greaterThanOrEqualTo: trailingAnchor)
            iconCenterXConstraint = completedIcon.centerXAnchor.constraint(equalTo: progressView.trailingAnchor,
                                                                           constant: -Layout.milestoneCompletedIconEdgePadding)
        } else if let stepIndicator = stepIndicator {
            labelXConstraint = label.centerXAnchor.constraint(equalTo: stepIndicator.centerXAnchor)
            iconCenterXConstraint = completedIcon.centerXAnchor.constraint(equalTo: stepIndicator.centerXAnchor)
        } else {
            labelXConstraint = nil
            iconCenterXConstraint = nil
        }

        if let labelXConstraint = labelXConstraint {
            label.font = UIFont.systemBoldFont(size: 14)
            label.textColor = UIColor.grayRegular
            label.text = R.Strings.affiliationChallengesInviteFriendsMilestone("\(milestone.pointsReward)")
            addSubviewForAutoLayout(label)

            let labelXConstraint = [labelXConstraint,
                                    label.topAnchor.constraint(equalTo: progressView.bottomAnchor,
                                                               constant: Layout.milestoneLabelVSpacing)]
            labelXConstraint.activate()
            views.append(label)
        }
        if let iconCenterXConstraint = iconCenterXConstraint, isStepCompleted {
            completedIcon.cornerRadius = Layout.milestoneCompletedIconSide/2
            completedIcon.image = R.Asset.Affiliation.iconCheck.image
            addSubviewForAutoLayout(completedIcon)
            let constraints = [iconCenterXConstraint,
                               completedIcon.centerYAnchor.constraint(equalTo: progressView.centerYAnchor,
                                                                      constant: Layout.milestoneCompletedIconShadowOffset),
                               completedIcon.widthAnchor.constraint(equalToConstant: Layout.milestoneCompletedIconSide),
                               completedIcon.heightAnchor.constraint(equalToConstant: Layout.milestoneCompletedIconSide)]
            constraints.activate()
            views.append(completedIcon)
        }
        return views
    }
}
