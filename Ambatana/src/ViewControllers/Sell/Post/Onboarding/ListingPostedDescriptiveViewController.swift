import RxSwift
import LGComponents

class ListingPostedDescriptiveViewController: KeyboardViewController, UITextViewDelegate {

    private struct PostingDescriptionMetrics {
        static let genericMargin: CGFloat = 30
        static let bigMargin: CGFloat = 50
        static let saveButtonHeight: CGFloat = 60
        static let discardButtonHeight: CGFloat = 50
        static let imageHeight: CGFloat = 250
        static let imageWidth: CGFloat = 175
        static let nameTextFieldHeight: CGFloat = 65
        static let categoryButtonHeight: CGFloat = 65
        static let descriptionTextViewHeight: CGFloat = 100
    }

    private lazy var noTitleContainerView = UIView()
    private lazy var listingImageView = UIImageView()

    private lazy var titleContainerView = UIView()
    private lazy var listingInfoTitleLabel = UILabel()
    private lazy var nameTextField = UITextField()
    private lazy var categoryButton = UIButton()
    private lazy var categoryLabel = UILabel()
    private lazy var rightChevronImageView = UIImageView()
    private lazy var descriptionTextView = UITextView()

    private lazy var doneLabel = UILabel()
    private lazy var saveButton = LetgoButton(type: .custom)
    private lazy var discardButton = UIButton()

    private var containerToKeyboardConstraint = NSLayoutConstraint()
    private var discardButtonToBottomConstraint = NSLayoutConstraint()
    private var containerToTopConstraint = NSLayoutConstraint()

    private var keyboardHelper: KeyboardHelper

    private let viewModel: ListingPostedDescriptiveViewModel

    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    init(viewModel: ListingPostedDescriptiveViewModel) {
        self.viewModel = viewModel
        self.keyboardHelper = KeyboardHelper()
        super.init(viewModel: viewModel, nibName: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupRx()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        nameTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        saveButton.setStyle(.primary(fontSize: .big))

        listingImageView.layer.cornerRadius = LGUIKitConstants.bigCornerRadius
    }

    
    // MARK: - Status Bar
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - UI
    
    private func setupUI() {

        view.backgroundColor = UIColor.white

        doneLabel.font = UIFont.postingFlowHeadline
        doneLabel.textColor = UIColor.blackText
        doneLabel.text = viewModel.doneText
        doneLabel.numberOfLines = 0
        doneLabel.minimumScaleFactor = 0.3

        switch viewModel.descriptionType {
        case .noTitle:
            setupNoTitleUI()
        case .withTitle:
            setupTitleUI()
        }

        saveButton.setTitle(viewModel.saveButtonText, for: .normal)

        discardButton.setTitle(viewModel.discardButtonText, for: .normal)
        discardButton.titleLabel?.font = UIFont.bigButtonFont
        discardButton.setTitleColor(UIColor.grayText, for: .normal)
    }

    private func setupNoTitleUI() {
        listingImageView.image = viewModel.listingImage
        listingImageView.contentMode = .scaleAspectFill
        listingImageView.clipsToBounds = true
        doneLabel.textAlignment = .center
    }

    private func setupTitleUI() {

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(containerTapped))
        view.addGestureRecognizer(tapRecognizer)

        doneLabel.textAlignment = .left

        listingInfoTitleLabel.text = viewModel.listingInfoTitleText
        listingInfoTitleLabel.font = UIFont.smallBodyFont
        listingInfoTitleLabel.textColor = UIColor.grayText

        nameTextField.placeholder = viewModel.namePlaceholder
        nameTextField.font = UIFont.systemBoldFont(size: 21)
        nameTextField.tintColor = UIColor.primaryColor

        categoryLabel.font = UIFont.veryBigButtonFont
        categoryLabel.textAlignment = .left
        rightChevronImageView.contentMode = .scaleAspectFit
        rightChevronImageView.image = viewModel.categoryButtonImage
        rightChevronImageView.tintColor = UIColor.grayText

        descriptionTextView.text = viewModel.descriptionPlaceholder
        descriptionTextView.font = UIFont.systemBoldFont(size: 21)
        descriptionTextView.tintColor = UIColor.primaryColor
        descriptionTextView.delegate = self
    }

    private func setupConstraints() {
        switch viewModel.descriptionType {
        case .noTitle:
            setupNoTitleConstraints()
        case .withTitle:
            setupTitleConstraints()
        }
    }

    private func setupNoTitleConstraints() {
        let noTitleSubviews: [UIView] = [listingImageView, doneLabel]
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: noTitleSubviews)
        noTitleContainerView.addSubviews(noTitleSubviews)

        listingImageView.layout()
            .height(PostingDescriptionMetrics.imageHeight)
            .width(PostingDescriptionMetrics.imageWidth)
        listingImageView.layout(with: noTitleContainerView)
            .centerX()
            .top()
        listingImageView.layout(with: doneLabel).above(by: -Metrics.bigMargin)

        doneLabel.layout(with: noTitleContainerView)
            .left(by: PostingDescriptionMetrics.genericMargin)
            .right(by: -PostingDescriptionMetrics.genericMargin)
            .bottom()

        view.addSubview(noTitleContainerView)
        noTitleContainerView.translatesAutoresizingMaskIntoConstraints = false

        setupCommonConstraintsWith(container: noTitleContainerView)
    }

    private func setupTitleConstraints() {
        let titleSubviews: [UIView] = [doneLabel, listingInfoTitleLabel, nameTextField, categoryLabel,
                                       rightChevronImageView, categoryButton, descriptionTextView]
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: titleSubviews)
        titleContainerView.addSubviews(titleSubviews)

        doneLabel.layout(with: titleContainerView)
            .centerX()
            .left(by: Metrics.bigMargin)
            .right(by: -Metrics.bigMargin)
            .top()
        doneLabel.layout(with: listingInfoTitleLabel).above(by: -PostingDescriptionMetrics.bigMargin)

        listingInfoTitleLabel.layout(with: titleContainerView)
            .centerX()
            .left(by: Metrics.bigMargin)
            .right(by: -Metrics.bigMargin)
        listingInfoTitleLabel.layout(with: nameTextField).above(by: -Metrics.margin)

        nameTextField.layout().height(PostingDescriptionMetrics.nameTextFieldHeight)
        nameTextField.layout(with: titleContainerView)
            .centerX()
            .left(by: Metrics.bigMargin)
            .right(by: -Metrics.bigMargin)
        nameTextField.layout(with: categoryButton).above()

        categoryButton.layout().height(PostingDescriptionMetrics.categoryButtonHeight)
        categoryButton.layout(with: titleContainerView)
            .left(by: Metrics.bigMargin)
            .right(by: -Metrics.bigMargin)
        categoryLabel.layout(with: categoryButton)
            .top()
            .bottom()
            .left()
        rightChevronImageView.layout(with: categoryButton)
            .right()
        categoryLabel.layout(with: rightChevronImageView)
            .centerY()
            .trailing(by: -Metrics.bigMargin, relatedBy: .lessThanOrEqual)
        categoryButton.layout(with: descriptionTextView).above(by: -Metrics.margin)

        descriptionTextView.layout()
            .height(PostingDescriptionMetrics.descriptionTextViewHeight, relatedBy: .greaterThanOrEqual)
        descriptionTextView.layout(with: titleContainerView)
            .centerX()
            .left(by: Metrics.bigMargin)
            .right(by: -Metrics.bigMargin)
            .bottom()

        view.addSubview(titleContainerView)
        titleContainerView.translatesAutoresizingMaskIntoConstraints = false

        titleContainerView.layout(with: keyboardView).above { [weak self] constraint in
            self?.containerToKeyboardConstraint = constraint
        }

        containerToKeyboardConstraint.isActive = false

        setupCommonConstraintsWith(container: titleContainerView)
    }

    private func setupCommonConstraintsWith(container: UIView) {
        let subviews = [saveButton, discardButton]
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        view.addSubviews(subviews)

        container.layout(with: view).top(by: PostingDescriptionMetrics.bigMargin, relatedBy: .lessThanOrEqual) { [weak self] constraint in
            self?.containerToTopConstraint = constraint
        }
        container.layout(with: view).left().right()

        container.layout(with: saveButton)
            .above(by: -PostingDescriptionMetrics.genericMargin,
                   relatedBy: .lessThanOrEqual)

        saveButton.layout().height(PostingDescriptionMetrics.saveButtonHeight)
        saveButton.layout(with: view)
            .centerX()
            .left(by: PostingDescriptionMetrics.genericMargin)
            .right(by: -PostingDescriptionMetrics.genericMargin)
        saveButton.layout(with: discardButton).above(by: -PostingDescriptionMetrics.genericMargin, relatedBy: .greaterThanOrEqual)
        saveButton.layout(with: discardButton).above(by: 0, relatedBy: .lessThanOrEqual)

        discardButton.layout().height(PostingDescriptionMetrics.discardButtonHeight)
        discardButton.layout(with: view)
            .centerX()
            .left(by: PostingDescriptionMetrics.genericMargin)
            .right(by: -PostingDescriptionMetrics.genericMargin)
        discardButton.layout(with: view)
            .bottom(by: -PostingDescriptionMetrics.genericMargin) { [weak self] constraint in
                self?.discardButtonToBottomConstraint = constraint
        }
    }

    private func enableKeyboardConstraint() {
        containerToKeyboardConstraint.isActive = true
        discardButtonToBottomConstraint.isActive = false
        containerToTopConstraint.isActive = false
    }

    private func disableKeyboardConstraint() {
        containerToKeyboardConstraint.isActive = false
        discardButtonToBottomConstraint.isActive = true
        containerToTopConstraint.isActive = true
    }

    private func setupRx() {
        viewModel.originalName.asObservable().bind(to: nameTextField.rx.text).disposed(by: disposeBag)
        nameTextField.rx.text.asObservable().bind { [weak self] textFieldText in
            self?.viewModel.updateListingNameWith(text: textFieldText)
        }.disposed(by: disposeBag)

        viewModel.listingCategory.asObservable().bind { [weak self] category in
            if let category = category, category != .unassigned {
                self?.categoryLabel.text = category.name
                self?.categoryLabel.textColor = UIColor.blackText
            } else {
                self?.categoryLabel.text = self?.viewModel.categoryButtonPlaceholder
                self?.categoryLabel.textColor = UIColor.grayText
            }
        }.disposed(by: disposeBag)

        descriptionTextView.rx.text.asObservable().bind { [weak self] text in
            guard let strongSelf = self else { return }
            guard let descriptionText = text,
                !descriptionText.isEmpty,
                descriptionText != strongSelf.viewModel.descriptionPlaceholder else {
                    strongSelf.viewModel.updateListingDescriptionWith(text: nil)
                    strongSelf.descriptionTextView.textColor = UIColor.grayText
                    return
            }
            strongSelf.viewModel.updateListingDescriptionWith(text: text)
            strongSelf.descriptionTextView.textColor = UIColor.blackText
        }.disposed(by: disposeBag)

        saveButton.rx.tap.bind { [weak self] in
            self?.closePosting()
        }.disposed(by: disposeBag)

        discardButton.rx.tap.bind { [weak self] in
            self?.discardPosting()
        }.disposed(by: disposeBag)

        categoryButton.rx.tap.bind { [weak self] in
            self?.openCategoriesPicker()
        }.disposed(by: disposeBag)
    }

    private func openCategoriesPicker() {
        viewModel.openCategoriesPicker()
    }

    private func closePosting() {
        viewModel.closePosting(discardingListing: false)
    }

    private func discardPosting() {
        viewModel.closePosting(discardingListing: true)
    }

    @objc private func containerTapped() {
        nameTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
    }
    
    // MARK: UITextViewDelegate

    func textViewDidBeginEditing(_ textView: UITextView) {
        enableKeyboardConstraint()
        if textView.text == viewModel.descriptionPlaceholder {
            textView.text = ""
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        disableKeyboardConstraint()
        if textView.text == "" {
            textView.text = viewModel.descriptionPlaceholder
        }
    }
}
