import Foundation
import RxSwift
import LGComponents

final class EditUserBioViewController: BaseViewController {

    private let viewModel: EditUserBioViewModel
    private let textView = UITextView()
    private let placeholderLabel = UILabel()
    private let charCounterLabel = UILabel()
    private let saveButton = LetgoButton(withStyle: .primary(fontSize: .big))
    private let disposeBag = DisposeBag()
    private let keyboardHelper = KeyboardHelper()
    private var saveButtonBottomConstraint: NSLayoutConstraint?
    private let characterLimit = 150

    struct Layout {
        static let bigMargin: CGFloat = Metrics.bigMargin
        static let veryShortMargin: CGFloat = Metrics.veryShortMargin
        static let placeholderTopMargin: CGFloat = 8
        static let placeholderSideMargin: CGFloat = 5
        static let saveButtonHeight: CGFloat = 50
        static let saveButtonBottomMargin: CGFloat = 15
    }

    init(viewModel: EditUserBioViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRx()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        setNavBarBackgroundStyle(.white)
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubviewsForAutoLayout([textView, saveButton, placeholderLabel, charCounterLabel])
        title = R.Strings.changeBioTitle
        automaticallyAdjustsScrollViewInsets = false

        textView.textContainerInset = .zero
        textView.tintColor = UIColor.primaryColor
        textView.font = UIFont.bigBodyFont
        textView.delegate = self
        textView.text = viewModel.userBio

        placeholderLabel.text = R.Strings.changeBioPlaceholder
        placeholderLabel.numberOfLines = 0
        placeholderLabel.font = UIFont.bigBodyFont
        placeholderLabel.textColor = UIColor.placeholder

        charCounterLabel.text = "\(characterLimit)"
        charCounterLabel.font = .smallBodyFont
        charCounterLabel.textColor = .darkGrayText

        saveButton.setTitle(R.Strings.changeBioSaveButton, for: .normal)
        saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        setupConstraints()
    }

    private func setupConstraints() {
        var constraints = [
            textView.topAnchor.constraint(equalTo: safeTopAnchor, constant: Layout.bigMargin),
            textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Layout.bigMargin),
            textView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Layout.bigMargin),
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor),
            placeholderLabel.leftAnchor.constraint(equalTo: textView.leftAnchor, constant: Layout.placeholderSideMargin),
            placeholderLabel.rightAnchor.constraint(equalTo: textView.rightAnchor, constant: -Layout.placeholderSideMargin),

            charCounterLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: Layout.veryShortMargin),
            charCounterLabel.rightAnchor.constraint(equalTo: textView.rightAnchor),
            charCounterLabel.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -Layout.veryShortMargin),

            saveButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Layout.bigMargin),
            saveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Layout.bigMargin),
            saveButton.heightAnchor.constraint(equalToConstant: Layout.saveButtonHeight)
        ]
        let save = saveButton.bottomAnchor.constraint(equalTo: safeBottomAnchor, constant: -Layout.saveButtonBottomMargin)
        constraints.append(save)
        NSLayoutConstraint.activate(constraints)
        saveButtonBottomConstraint = save

        charCounterLabel.setContentHuggingPriority(.required, for: .vertical)
    }

    private func setupRx() {
        textView
            .rx
            .text
            .map { $0?.isEmpty ?? true }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isEmpty in
                self?.placeholderLabel.isHidden = !isEmpty
            })
            .disposed(by: disposeBag)

        keyboardHelper
            .rx_keyboardHeight
            .asDriver()
            .skip(1) // Ignore the first call with height == 0
            .drive(onNext: { [weak self] height in
                var buttonBottomMargin = -(height + Layout.saveButtonBottomMargin)
                if #available(iOS 11.0, *) {
                    buttonBottomMargin += self?.view.safeAreaInsets.bottom ?? 0
                }
                self?.saveButtonBottomConstraint?.constant = buttonBottomMargin
                UIView.animate(withDuration: 0.2, animations: {
                    self?.view.layoutIfNeeded()
                })
            }).disposed(by: disposeBag)
    }

    @objc private func didTapSave() {
        viewModel.saveBio(text: textView.text)
    }
}

extension EditUserBioViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: text)
        updateCharCounterWith(count: updatedText.count)

        if updatedText.count > characterLimit {
            textView.text = String(updatedText.prefix(characterLimit))
        }

        return updatedText.count <= characterLimit
    }

    private func updateCharCounterWith(count: Int) {
        let counter = characterLimit-count < 0 ? 0 : characterLimit-count
        charCounterLabel.text = "\(counter)"
        charCounterLabel.textColor = count <= 0 ? .darkGrayText : .blackText
    }
}
