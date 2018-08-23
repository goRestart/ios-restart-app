import Foundation
import LGComponents
import RxSwift

final class ListingCarouselChatContainerView: UIView {

    private var viewModel: ListingCarouselViewModel?
    private let disposeBag: DisposeBag = DisposeBag()

    private let footerLabel: UILabel = {
        let label = UILabel()
        label.text = R.Strings.listingInterestedFooter
        label.font = UIFont.subtitleFont
        label.textColor = .white
        label.numberOfLines = 0
        label.applyShadow(withOpacity: 0.2, radius: 0, color: UIColor.black.cgColor)
        label.layer.shadowOffset = CGSize(width: 0, height: 2)
        label.textAlignment = .center
        return label
    }()

    private let chatButton: LetgoButton = {
        let button = LetgoButton(withStyle: .transparent(fontSize: .medium, sidePadding: 15))
        button.setTitle(R.Strings.listingChatButton, for: .normal)
        return button
    }()

    private let interestedButton: LetgoButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .big))
        return button
    }()

    private let chatTextView: ChatTextView = {
        let chatTextView = ChatTextView()
        chatTextView.setInitialText(R.Strings.chatExpressTextFieldText)
        return chatTextView
    }()

    private let directAnswersView: DirectAnswersHorizontalView = {
        let directAnswersView = DirectAnswersHorizontalView(answers: [], sideMargin: CarouselUI.itemsMargin)
        return directAnswersView
    }()

    private var interestedButtonConstraints: [NSLayoutConstraint] = []
    private var chatButtonConstraints: [NSLayoutConstraint] = []
    private var footerLabelConstraints: [NSLayoutConstraint] = []
    private var directAnswersViewConstraints: [NSLayoutConstraint] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setup(with viewModel: ListingCarouselViewModel) {
        self.viewModel = viewModel
        setupUI()
        setupConstraints()
        setupRx()
        setupAccessibilityIds()
    }

    func setupUI() {
        setupDirectAnswersView()
        setupInterestedButton()
    }

    func setupDirectAnswersView() {
        directAnswersView.delegate = self
        directAnswersView.style = .light
    }

    func setupInterestedButton() {
        guard let featureFlags = viewModel?.featureFlags else { return }
        featureFlags.simplifiedChatButton.setupInterestButton(button: interestedButton)
    }

    func setupConstraints() {
        guard let featureFlags = viewModel?.featureFlags else { return }

        switch featureFlags.simplifiedChatButton {
        case .variantA, .variantB, .variantC:
            addSubviewsForAutoLayout([interestedButton, chatButton])
            interestedButton.layout().height(CarouselUI.buttonHeight)
            interestedButton.layout(with: self).fillVertical()
                .fillHorizontal(by: CarouselUI.itemsMargin)
            chatButton.layout().height(CarouselUI.buttonHeight)
            chatButton.layout(with: self).fillVertical()
                .fillHorizontal(by: CarouselUI.itemsMargin)
        case .variantD:
            addSubviewsForAutoLayout([interestedButton, footerLabel, chatButton])
            interestedButton.layout().height(CarouselUI.buttonHeight)
            interestedButton.layout(with: self).top()
                .fillHorizontal(by: CarouselUI.itemsMargin)
            footerLabel.layout(with: interestedButton).below(by: CarouselUI.chatFooterTopMargin)
            footerLabel.layout(with: self).fillHorizontal(by: CarouselUI.itemsMargin)
                .bottom()
            chatButton.layout().height(CarouselUI.buttonHeight)
            chatButton.layout(with: self).fillVertical()
                .fillHorizontal(by: CarouselUI.itemsMargin)
        case .variantE:
            addSubviewsForAutoLayout([directAnswersView, chatButton])
            directAnswersView.layout(with: self).fill()
            chatButton.layout().height(CarouselUI.buttonHeight)
            chatButton.layout(with: self).fillVertical()
                .fillHorizontal(by: CarouselUI.itemsMargin)
        case .variantF:
            addSubviewForAutoLayout(chatTextView)
            chatTextView.layout(with: self).fillVertical()
                .fillHorizontal(by: CarouselUI.itemsMargin)
        case .baseline, .control:
            addSubviewsForAutoLayout([directAnswersView, chatTextView])
            directAnswersView.layout(with: self).top().fillHorizontal()
            chatTextView.layout(with: directAnswersView).below(by: CarouselUI.itemsMargin)
            chatTextView.layout(with: self).fillHorizontal(by: CarouselUI.itemsMargin)
                .bottom()
        }

        interestedButtonConstraints = interestedButton.constraints
        footerLabelConstraints = footerLabel.constraints
        chatButtonConstraints = chatButton.constraints
        directAnswersViewConstraints = directAnswersView.constraints
    }

    func setupRx() {
        guard let viewModel = viewModel else { return }
        viewModel.quickAnswers.asObservable().bind { [weak self] quickAnswers in
            self?.directAnswersView.update(answers: quickAnswers)
        }.disposed(by: disposeBag)
        viewModel.directChatPlaceholder.asObservable().bind { [weak self] placeholder in
            self?.chatTextView.placeholder = placeholder
        }.disposed(by: disposeBag)
        viewModel.isInterested.asObservable().bind { [weak self] isInterested in
            guard let strongSelf = self else { return }
            switch viewModel.featureFlags.simplifiedChatButton {
            case .baseline, .control, .variantF:
                break;
            case .variantA, .variantB, .variantC:
                if isInterested {
                    NSLayoutConstraint.deactivate(strongSelf.interestedButtonConstraints)
                    NSLayoutConstraint.activate(strongSelf.chatButtonConstraints)
                    strongSelf.interestedButton.isHidden = true
                    strongSelf.chatButton.isHidden = false
                } else {
                    NSLayoutConstraint.activate(strongSelf.interestedButtonConstraints)
                    NSLayoutConstraint.deactivate(strongSelf.chatButtonConstraints)
                    strongSelf.interestedButton.isHidden = false
                    strongSelf.chatButton.isHidden = true
                }
            case .variantD:
                if isInterested {
                    NSLayoutConstraint.deactivate(strongSelf.interestedButtonConstraints)
                    NSLayoutConstraint.deactivate(strongSelf.footerLabelConstraints)
                    NSLayoutConstraint.activate(strongSelf.chatButtonConstraints)
                    strongSelf.interestedButton.isHidden = true
                    strongSelf.footerLabel.isHidden = true
                    strongSelf.chatButton.isHidden = false
                } else {
                    NSLayoutConstraint.activate(strongSelf.interestedButtonConstraints)
                    NSLayoutConstraint.activate(strongSelf.footerLabelConstraints)
                    NSLayoutConstraint.deactivate(strongSelf.chatButtonConstraints)
                    strongSelf.interestedButton.isHidden = false
                    strongSelf.footerLabel.isHidden = false
                    strongSelf.chatButton.isHidden = true
                }
            case .variantE:
                if isInterested {
                    NSLayoutConstraint.deactivate(strongSelf.directAnswersViewConstraints)
                    NSLayoutConstraint.activate(strongSelf.chatButtonConstraints)
                    strongSelf.directAnswersView.isHidden = true
                    strongSelf.chatButton.isHidden = false
                } else {
                    NSLayoutConstraint.activate(strongSelf.directAnswersViewConstraints)
                    NSLayoutConstraint.deactivate(strongSelf.chatButtonConstraints)
                    strongSelf.directAnswersView.isHidden = false
                    strongSelf.chatButton.isHidden = true
                }
            }
        }.disposed(by: disposeBag)
        chatTextView.rx.send.bind { [weak self] textToSend in
            guard let strongSelf = self, let viewModel = self?.viewModel  else { return }
            viewModel.send(directMessage: textToSend, isDefaultText: strongSelf.chatTextView.isInitialText)
            strongSelf.chatTextView.clear()
        }.disposed(by: disposeBag)
        chatButton.rx.tap.bind { [weak self] in
            self?.viewModel?.chatButtonTapped()
        }.disposed(by: disposeBag)
        interestedButton.rx.tap.bind { [weak self] in
            self?.viewModel?.interestedButtonTapped()
        }.disposed(by: disposeBag)
    }

    func setupAccessibilityIds() {
        footerLabel.set(accessibilityId: .listingCarouselChatFooterLabel)
        chatTextView.set(accessibilityId: .listingCarouselChatTextView)
        chatButton.set(accessibilityId: .listingCarouselChatButton)
        interestedButton.set(accessibilityId: .listingCarouselInterestedButton)
    }
}

// MARK: - Lifecycle

extension ListingCarouselChatContainerView {

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return chatTextView.becomeFirstResponder()
    }

    override var isFirstResponder: Bool {
        return chatTextView.isFirstResponder
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        return chatTextView.resignFirstResponder()
    }
}

// MARK: > Direct messages and stickers

extension ListingCarouselChatContainerView: DirectAnswersHorizontalViewDelegate {

    func directAnswersHorizontalViewDidSelect(answer: QuickAnswer) {
        guard let viewModel = viewModel else { return }
        viewModel.send(quickAnswer: answer)
    }
}

private extension SimplifiedChatButton {
    func setupInterestButton(button: LetgoButton) {
        switch self {
        case .variantA:
            button.setTitle(R.Strings.listingInterestedButtonA, for: .normal)
        case .variantB:
            button.setTitle(R.Strings.listingInterestedButtonB, for: .normal)
            button.setImage(R.Asset.IconsButtons.IAmInterested.icIamiSend.image, for: .normal)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: Metrics.bigMargin, bottom: 0, right: 0)
        case .variantC:
            button.setTitle(R.Strings.listingInterestedButtonC, for: .normal)
        case .variantD:
            button.setTitle(R.Strings.listingInterestedButtonD, for: .normal)
        default:
            break
        }
    }
}
