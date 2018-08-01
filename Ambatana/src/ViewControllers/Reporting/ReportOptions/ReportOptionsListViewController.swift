import Foundation
import LGComponents
import RxSwift

final class ReportOptionsListViewController: BaseViewController {

    private enum Layout {
        static let buttonAreaHeight: CGFloat = 80
        static let additionalNotesAreaHeight: CGFloat = 100
        static let buttonHeight: CGFloat = 50
        static let estimatedRowHeight: CGFloat = 60
        static let borderWidth: CGFloat = 1
    }

    private let viewModel: ReportOptionsListViewModel
    private let keyboardHelper = KeyboardHelper()
    private let disposeBag = DisposeBag()
    private var bottomContainerTopConstraint: NSLayoutConstraint?

    private var tableBottomInset: CGFloat = 0 {
        didSet {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tableBottomInset, right: 0)
            tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: tableBottomInset, right: 0)
        }
    }

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(type: ReportOptionCell.self)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = Layout.estimatedRowHeight
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Layout.buttonAreaHeight, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: Layout.buttonAreaHeight, right: 0)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()

    private let additionalNotesTextView: UITextView = {
        let textView = UITextView()
        textView.font = .bigBodyFont
        textView.textColor = .blackText
        textView.backgroundColor = .clear
        return textView
    }()

    private let additionalNotesPlacehoderTextView: UITextView = {
        let textView = UITextView()
        textView.font = .bigBodyFont
        textView.textColor = .placeholder
        textView.text = R.Strings.reportingAdditionalNotesPlaceholder
        textView.isUserInteractionEnabled = false
        textView.backgroundColor = .clear
        return textView
    }()

    private let reportButton: LetgoButton = {
        let button = LetgoButton(withStyle: ButtonStyle.primary(fontSize: ButtonFontSize.medium))
        button.setTitle(R.Strings.reportingSendReportButton, for: .normal)
        button.isEnabled = false
        return button
    }()

    private let bottomContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.9)
        return view
    }()

    private var bottomContainerTopBorder: UIView?

    init(viewModel: ReportOptionsListViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRx()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        setNavBarBackgroundStyle(.white)
        setNavBarTitle(viewModel.title)
        setNavBarCloseButton(#selector(didTapClose))
    }

    private func setupUI() {
        disableAutomaticAdjustScrollViewInsets(in: tableView)
        bottomContainer.addSubviewForAutoLayout(reportButton)
        view.addSubviewsForAutoLayout([tableView, bottomContainer])
        view.backgroundColor = .white

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = setupTableFooter()
        tableView.tableFooterView?.alpha = 0
        additionalNotesTextView.delegate = self

        reportButton.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)

        setupConstraints()
    }

    private func setupConstraints() {
        let bottomContainerTopConstraint = bottomContainer.topAnchor.constraint(equalTo: safeBottomAnchor,
                                                                                constant: -Layout.buttonAreaHeight)
        let constraints: [NSLayoutConstraint] = [
            tableView.topAnchor.constraint(equalTo: safeTopAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            bottomContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            reportButton.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: Metrics.margin),
            reportButton.leftAnchor.constraint(equalTo: bottomContainer.leftAnchor, constant: Metrics.margin),
            reportButton.rightAnchor.constraint(equalTo: bottomContainer.rightAnchor, constant: -Metrics.margin),
            reportButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),
            bottomContainerTopConstraint
        ]

        self.bottomContainerTopConstraint = bottomContainerTopConstraint
        NSLayoutConstraint.activate(constraints)
    }

    private func setupTableFooter() -> UIView {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Layout.additionalNotesAreaHeight))

        footer.addSubviewsForAutoLayout([additionalNotesTextView, additionalNotesPlacehoderTextView])
        footer.addTopViewBorderWith(width: Layout.borderWidth,
                                    color: .grayLight,
                                    leftMargin: Metrics.margin,
                                    rightMargin: Metrics.margin)

        let constraints = [
            additionalNotesTextView.topAnchor.constraint(equalTo: footer.topAnchor, constant: Metrics.margin),
            additionalNotesTextView.leftAnchor.constraint(equalTo: footer.leftAnchor, constant: Metrics.margin),
            additionalNotesTextView.rightAnchor.constraint(equalTo: footer.rightAnchor, constant: -Metrics.margin),
            additionalNotesTextView.bottomAnchor.constraint(equalTo: footer.bottomAnchor, constant: -Metrics.margin),
            additionalNotesPlacehoderTextView.leftAnchor.constraint(equalTo: additionalNotesTextView.leftAnchor),
            additionalNotesPlacehoderTextView.rightAnchor.constraint(equalTo: additionalNotesTextView.rightAnchor),
            additionalNotesPlacehoderTextView.heightAnchor.constraint(equalTo: additionalNotesTextView.heightAnchor),
            additionalNotesTextView.heightAnchor.constraint(equalToConstant: Layout.additionalNotesAreaHeight),
            additionalNotesPlacehoderTextView.topAnchor.constraint(equalTo: additionalNotesTextView.topAnchor)
        ]

        NSLayoutConstraint.activate(constraints)

        return footer
    }

    private func setupRx() {
        viewModel
            .showAdditionalNotes
            .asDriver()
            .drive(onNext: { [weak self] showAdditionalNotes in
                self?.makeAdditionalNotes(visible: showAdditionalNotes)
            })
            .disposed(by: disposeBag)

        viewModel
            .showReportButtonActive
            .asDriver()
            .drive(onNext: { [weak self] showButtonActive in
                self?.reportButton.isEnabled = showButtonActive
            })
            .disposed(by: disposeBag)

        keyboardHelper
            .rx_keyboardOrigin
            .asDriver()
            .skip(1) // Ignore the first call with height == 0
            .drive(onNext: { [weak self] origin in
                var bottomContainerOffset: CGFloat

                if origin < UIScreen.main.bounds.height {
                    let height = UIScreen.main.bounds.height - origin
                    bottomContainerOffset = height + Layout.buttonAreaHeight
                    if #available(iOS 11.0, *) {
                        bottomContainerOffset -= self?.view.safeAreaInsets.bottom ?? 0
                    }
                } else {
                    bottomContainerOffset = Layout.buttonAreaHeight
                }

                self?.bottomContainerTopConstraint?.constant = -bottomContainerOffset
                self?.tableBottomInset = bottomContainerOffset

                UIView.animate(withDuration: 0.2, animations: {
                    self?.view.layoutIfNeeded()
                })

                if let tableView = self?.tableView,
                    let footerView = tableView.tableFooterView {
                    let rect = tableView.convert(footerView.bounds, from: footerView)
                    self?.tableView.scrollRectToVisible(rect, animated: true)
                }
            })
            .disposed(by: disposeBag)
    }

    @objc private func reportButtonTapped() {
        viewModel.didTapReport(with: additionalNotesTextView.text)
    }

    @objc private func didTapClose() {
        viewModel.didTapClose()
    }

    func makeAdditionalNotes(visible: Bool) {
        guard tableView.tableFooterView?.alpha != (visible ? 1 : 0) else { return }

        let animationOffset: CGFloat = 80

        if visible {
            tableView.tableFooterView?.frame.origin.y += animationOffset
        }

        UIView.animate(withDuration: 0.6,
                       delay: visible ? 0 : 0.1,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.6,
                       options: .curveLinear,
                       animations: { [weak self] in
                        self?.tableView.tableFooterView?.frame.origin.y -= visible ? animationOffset : -animationOffset },
                       completion: { [weak self] _ in
                        if !visible {
                            self?.tableView.tableFooterView?.frame.origin.y -= animationOffset
                        }})

        UIView.animate(withDuration: 0.4,
                       delay: visible ? 0.2 : 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.6,
                       options: .curveLinear,
                       animations: { [weak self] in
                        self?.tableView.tableFooterView?.alpha = visible ? 1 : 0 },
                       completion: nil)
    }
}

extension ReportOptionsListViewController: UITableViewDelegate, UITableViewDataSource {

    // MARK: TableView Delegate & DataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.optionGroup.options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeue(type: ReportOptionCell.self, for: indexPath) else { return UITableViewCell() }
        let option = viewModel.optionGroup.options[indexPath.row]
        cell.configure(with: option)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = viewModel.optionGroup.options[indexPath.row]
        viewModel.didSelect(option: option)
    }
}

extension ReportOptionsListViewController: UITextViewDelegate {

    // MARK: UITextView Delegate (Additional Notes)

    func textViewDidChange(_ textView: UITextView) {
        additionalNotesPlacehoderTextView.isHidden = !additionalNotesTextView.text.isEmpty
    }
}
