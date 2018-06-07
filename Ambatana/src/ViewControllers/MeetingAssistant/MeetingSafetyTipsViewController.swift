import Foundation
import LGComponents

class MeetingSafetyTipsViewController: BaseViewController {

    static let tipsImageViewMargin: CGFloat = 50

    private var closeButton: UIButton = UIButton()
    private var tipsImageView: UIImageView = UIImageView()
    private var tipsTitle: UILabel = UILabel()
    private var tipsSubtitle: UILabel = UILabel()

    private var sendMeetingButton: LetgoButton = LetgoButton()
    private var secondaryCloseButton: LetgoButton = LetgoButton()

    private var viewModel: MeetingSafetyTipsViewModel


    // MARK: - Lifecycle

    init(viewModel: MeetingSafetyTipsViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setAccesibilityIds()
    }

    // Private methods

    private func setupUI() {
        view.backgroundColor = UIColor.white
        closeButton.setImage(R.Asset.CongratsScreenImages.icCloseRed.image, for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)

        tipsImageView.contentMode = .scaleAspectFit
        tipsImageView.image = R.Asset.ChatNorris.imageMeetingSafetyTips.image

        tipsTitle.text = viewModel.titleText
        tipsTitle.font = UIFont.boldSystemFont(ofSize: 23)
        tipsTitle.textColor = UIColor.blackText
        tipsTitle.numberOfLines = 0
        tipsTitle.minimumScaleFactor = 0.5
        tipsTitle.adjustsFontSizeToFitWidth = true

        tipsSubtitle.text = viewModel.subtitleText
        tipsSubtitle.font = UIFont.systemRegularFont(size: 15)
        tipsSubtitle.textColor = UIColor.grayText
        tipsSubtitle.numberOfLines = 0
        tipsSubtitle.minimumScaleFactor = 0.5
        tipsSubtitle.adjustsFontSizeToFitWidth = true

        sendMeetingButton.setStyle(.primary(fontSize: .big))
        sendMeetingButton.setTitle(viewModel.sendMeetingButtonTitle, for: .normal)
        sendMeetingButton.isHidden = viewModel.sendMeetingButtonIsHidden
        sendMeetingButton.addTarget(self, action: #selector(sendMeetingButtonPressed), for: .touchUpInside)

        secondaryCloseButton.setStyle(viewModel.secondaryCloseButtonStyle)
        secondaryCloseButton.setTitle(viewModel.secondaryCloseButtonTitle, for: .normal)
        secondaryCloseButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
    }

    private func setupConstraints(){
        let subviews: [UIView] = [closeButton, tipsImageView, tipsTitle, tipsSubtitle, sendMeetingButton,
                                  secondaryCloseButton]
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        view.addSubviews(subviews)

        closeButton.layout().height(Metrics.closeButtonHeight).width(Metrics.closeButtonWidth)

        if #available(iOS 11, *) {
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            secondaryCloseButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                         constant: -Metrics.bigMargin).isActive = true
        } else {
            closeButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            secondaryCloseButton.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                         constant: -Metrics.bigMargin).isActive = true
        }

        closeButton.layout(with: view).left()
        closeButton.layout(with: tipsImageView)
            .above(by: Metrics.margin)

        tipsImageView.layout().widthProportionalToHeight()
        tipsImageView.layout(with: view).fillHorizontal(by: MeetingSafetyTipsViewController.tipsImageViewMargin)

        tipsImageView.layout(with: tipsTitle)
            .above(by: -Metrics.veryBigMargin)

        tipsTitle.layout(with: view).fillHorizontal(by: Metrics.bigMargin)

        tipsTitle.layout(with: tipsSubtitle)
            .above(by: -Metrics.shortMargin)

        tipsSubtitle.layout(with: view).fillHorizontal(by: Metrics.bigMargin)

        tipsSubtitle.layout(with: sendMeetingButton)
            .above(by: -Metrics.margin, relatedBy: .lessThanOrEqual)

        sendMeetingButton.layout().height(viewModel.sendMeetingButtonIsHidden ? 0 : Metrics.buttonHeight)
        sendMeetingButton.layout(with: view).fillHorizontal(by: Metrics.bigMargin)

        sendMeetingButton.layout(with: secondaryCloseButton)
            .above(by: viewModel.sendMeetingButtonIsHidden ? 0 : -Metrics.shortMargin)

        secondaryCloseButton.layout().height(Metrics.buttonHeight)
        secondaryCloseButton.layout(with: view).fillHorizontal(by: Metrics.bigMargin)
    }

    private func setAccesibilityIds() {
        view.set(accessibilityId: .meetingCreationTipsView)
        closeButton.set(accessibilityId: .meetingCreationTipsCloseButton)
        tipsImageView.set(accessibilityId: .meetingCreationTipsImageView)
        tipsTitle.set(accessibilityId: .meetingCreationTipsTitleLabel)
        tipsSubtitle.set(accessibilityId: .meetingCreationTipsSubtitleLabel)
        sendMeetingButton.set(accessibilityId: .meetingCreationTipsSendMeetingButton)
        secondaryCloseButton.set(accessibilityId: .meetingCreationTipsSecondaryCloseButton)
    }

    @objc private func closeButtonPressed() {
        viewModel.closeTips()
    }

    @objc private func sendMeetingButtonPressed() {
        viewModel.closeTipsAndSendMeeting()
    }
}
