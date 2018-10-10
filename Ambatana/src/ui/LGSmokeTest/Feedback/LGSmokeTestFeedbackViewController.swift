import LGComponents
import RxCocoa
import RxSwift

final class LGSmokeTestFeedbackViewController: BaseViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel: LGSmokeTestFeedbackViewModel
    private let keyboardHelper: KeyboardHelper
    
    private var selectedTitle: String?
    
    private lazy var sendButtonBottomConstraint: NSLayoutConstraint = {
        return sendButton.bottomAnchor.constraint(equalTo: safeBottomAnchor, constant: -Metrics.margin)
    }()
    
    // MARK: - Subviews
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.Asset.IconsButtons.icCloseGray.image, for: .normal)
        return button
    }()
    
    private let rootScrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    
    private let rootStackView: UIStackView = {
        let stackView = UIStackView.vertical([])
        stackView.spacing = Metrics.margin
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.backgroundColor = .white
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Layout.titleFontSize,
                                 weight: UIFont.Weight.bold)
        label.text = R.Strings.smoketestFeedbackTitle
        label.numberOfLines = 0
        label.textColor = .lgBlack
        label.textAlignment = .left
        label.minimumScaleFactor = 0.6
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = .grayDark
        label.font = .systemRegularFont(size: 14)
        return label
    }()
    
    private let tellUsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .lgBlack
        label.text = R.Strings.smoketestFeedbackTellUs
        label.font = .systemFont(ofSize: Layout.tellUsFontSize,
                                 weight: UIFont.Weight.bold)
        return label
    }()
    
    private let tellUsTextView: UITextView = {
        let textView = UITextView()
        textView.cornerRadius = 12
        textView.backgroundColor = .grayBackground
        textView.textAlignment = .left
        textView.font = .systemRegularFont(size: 14)
        textView.textColor = .grayRegular
        textView.text = R.Strings.smoketestFeedbackTellUsPlaceholder
        return textView
    }()
    
    private let sendButton: UIButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .big))
        button.setTitle(R.Strings.smoketestFeedbackSend, for: .normal)
        return button
    }()
    
    private var selectionList: LGSingleSelectionList
    
    // MARK: - Lifecycle
    
    init(viewModel: LGSmokeTestFeedbackViewModel, keyboardHelper: KeyboardHelper) {
        self.viewModel = viewModel
        self.keyboardHelper = keyboardHelper
        self.selectionList = LGSingleSelectionList(titles: viewModel.feedbackOptions)
        super.init(viewModel: viewModel, nibName: nil)
        tellUsTextView.delegate = self
        setupUI()
        setupRx()
        setupActions()
        populate(viewModel)
    }
    
    convenience init(viewModel: LGSmokeTestFeedbackViewModel) {
        self.init(viewModel: viewModel, keyboardHelper: KeyboardHelper())
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    //  MARK: - Private
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeDetail), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(sendFeedback), for: .touchUpInside)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        addSubViews()
        addConstraints()
    }
    
    private func setupRx() {
        let selectionBinders = [tellUsLabel.rx.isEnabled,
                                sendButton.rx.isEnabled,
                                tellUsTextView.rx.isUserInteractionEnabled]
        selectionBinders.forEach { selectionList.rx.selected.bind(to: $0).disposed(by: disposeBag) }
        
        selectionList.rx.selectedTitle.subscribeNext { [weak self] title in
            self?.selectedTitle = title
        }.disposed(by: disposeBag)
        
        tellUsTextView.rx.didBeginEditing.asObservable().subscribe(onNext: { [weak self] _ in
            self?.clearTextViewPlaceholder()
        }).disposed(by: disposeBag)
        
        keyboardHelper.rx_keyboardOrigin
            .asObservable()
            .skip(1)
            .distinctUntilChanged()
            .bind { [weak self] origin in
                guard let keyboardHeight = self?.keyboardHelper.keyboardHeight, let selectionListBottom = self?.selectionList.frame.bottom else { return }
                let keyboardVisible: Bool = origin < UIScreen.main.bounds.height
                let bottomInset = keyboardVisible ? keyboardHeight-Metrics.margin : 0
                self?.rootScrollView.contentInset.bottom = bottomInset
                let scrollPoint = keyboardVisible ? selectionListBottom-Layout.scrollingBottomMarging : 0
                self?.rootScrollView.setContentOffset(CGPoint(x: 0, y: scrollPoint), animated: true)
                self?.animateSendButton(keyboardVisible, keyboardHeight)
            }.disposed(by: disposeBag)
    }
    
    private func clearTextViewPlaceholder() {
        guard tellUsTextView.text == R.Strings.smoketestFeedbackTellUsPlaceholder  else { return }
        tellUsTextView.text = nil
        tellUsTextView.textColor = .lgBlack
    }
    
    private func animateSendButton(_ keyboardVisible: Bool, _ keyboardHeight: CGFloat) {
        sendButtonBottomConstraint.constant = keyboardVisible ? -(keyboardHeight + Metrics.veryShortMargin) : -Metrics.margin
        UIView.animate(withDuration: 1.0, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    private func addSubViews() {
        rootScrollView.addSubviewsForAutoLayout([rootStackView])
        view.addSubviewsForAutoLayout([rootScrollView, closeButton, sendButton])
        rootStackView.addArrangedSubviews([titleLabel, subtitleLabel, selectionList, tellUsLabel, tellUsTextView])
    }
    
    private func addConstraints() {
        
        let constraints = [
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Metrics.shortMargin),
            closeButton.topAnchor.constraint(equalTo: safeTopAnchor, constant: Metrics.shortMargin),
            
            rootScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Metrics.margin),
            rootScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Metrics.margin),
            rootScrollView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: Metrics.margin),
            rootScrollView.bottomAnchor.constraint(equalTo: sendButton.topAnchor, constant: -Metrics.margin),
            
            sendButtonBottomConstraint,
            sendButton.heightAnchor.constraint(equalToConstant: Layout.sendButtonHeight),
            sendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Metrics.veryBigMargin),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Metrics.veryBigMargin),
            
            rootStackView.leadingAnchor.constraint(equalTo: rootScrollView.leadingAnchor),
            rootStackView.topAnchor.constraint(equalTo: rootScrollView.topAnchor),
            rootStackView.bottomAnchor.constraint(equalTo: rootScrollView.bottomAnchor, constant: -Metrics.bigMargin),
            rootStackView.widthAnchor.constraint(equalTo: rootScrollView.widthAnchor),
            
            selectionList.widthAnchor.constraint(equalTo: rootStackView.widthAnchor),
            
            tellUsTextView.leadingAnchor.constraint(equalTo: rootStackView.leadingAnchor),
            tellUsTextView.trailingAnchor.constraint(equalTo: rootStackView.trailingAnchor),
            tellUsTextView.heightAnchor.constraint(equalToConstant: Layout.tellUsTextViewHeight)
        ]
        constraints.activate()
    }
    
    //  MARK: - Actions
    
    @objc private func closeDetail() {
        viewModel.didTapCloseFeedback()
    }
    
    @objc private func sendFeedback() {
        guard let selectedTitle = selectedTitle else { return }
        viewModel.didTapSendFeedback(feedback: selectedTitle, feedbackDescription: tellUsTextView.text)
    }
    
}

extension LGSmokeTestFeedbackViewController {
    func populate(_ viewModel: LGSmokeTestFeedbackViewModel) {
        subtitleLabel.text = viewModel.subtitle
    }
}

extension LGSmokeTestFeedbackViewController: UITextViewDelegate {
    
    static let characterCountLimit = 1024
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let textViewText = textView.text else { return true }
        let newLength = text.count + textViewText.count - range.length
        return newLength <= LGSmokeTestFeedbackViewController.characterCountLimit
    }
}

private enum Layout {
    static let titleFontSize: CGFloat = 28
    static let subtitleFontSize = 17
    static let tellUsFontSize: CGFloat = 20
    static let tellUsTextViewHeight: CGFloat = 110
    static let sendButtonHeight: CGFloat = 55
    static let scrollingBottomMarging: CGFloat = DeviceFamily.current.isWiderOrEqualThan(.iPhone5) ? 50 : -20
}
