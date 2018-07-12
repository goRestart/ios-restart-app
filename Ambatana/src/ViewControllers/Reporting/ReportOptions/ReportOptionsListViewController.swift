import Foundation
import LGComponents

final class ReportOptionsListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    private enum Layout {
        static let buttonAreaHeight: CGFloat = 80
        static let additionalNotesAreaHeight: CGFloat = 118
        static let buttonHeight: CGFloat = 50
        static let estimatedRowHeight: CGFloat = 60
        static let borderWidth: CGFloat = 1
    }

    private let viewModel: ReportOptionsListViewModel

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(type: ReportOptionCell.self)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = Layout.estimatedRowHeight
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Layout.buttonAreaHeight, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: Layout.buttonAreaHeight, right: 0)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        return tableView
    }()

    private let additionalNotesTextView: UITextView = {
        let textView = UITextView()
        textView.addTopViewBorderWith(width: Layout.borderWidth,
                                      color: .grayLight,
                                      leftMargin: Metrics.margin,
                                      rightMargin: Metrics.margin)
        textView.font = .bigBodyFont
        textView.textColor = .placeholder
        textView.text = "Write here any additional notes that might help us to resolve this issue" // FIXME: localize
        return textView
    }()

    private let reportButton: LetgoButton = {
        let button = LetgoButton(withStyle: ButtonStyle.primary(fontSize: ButtonFontSize.medium))
        button.setTitle("Report", for: .normal) // FIXME: Localize
        button.isEnabled = false
        return button
    }()

    private let bottomContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.9)
        return view
    }()

    private var selectedOption: ReportOption?
    private var mutableConstraints: [NSLayoutConstraint] = []

    private var tableBottomInset: CGFloat {
        didSet{
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tableBottomInset, right: 0)
            tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: tableBottomInset, right: 0)
        }
    }

    init(viewModel: ReportOptionsListViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        setupUI()
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
        bottomContainer.addSubviewsForAutoLayout([additionalNotesTextView, reportButton])
        view.addSubviewsForAutoLayout([tableView, bottomContainer])
        view.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        additionalNotesTextView.delegate = self
        reportButton.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
        setupConstraints()
    }

    private func setupConstraints() {
        let constraints: [NSLayoutConstraint] = [
            tableView.topAnchor.constraint(equalTo: safeTopAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            bottomContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            reportButton.leftAnchor.constraint(equalTo: bottomContainer.leftAnchor, constant: Metrics.margin),
            reportButton.rightAnchor.constraint(equalTo: bottomContainer.rightAnchor, constant: -Metrics.margin),
            reportButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight)
        ]

        mutableConstraints = constraintsForAdditionalNotes(visible: false)

        NSLayoutConstraint.activate(constraints + mutableConstraints)
    }

    private func constraintsForAdditionalNotes(visible: Bool) -> [NSLayoutConstraint] {
        if visible {
            return [
                bottomContainer.topAnchor.constraint(equalTo: safeBottomAnchor, constant: -Layout.buttonAreaHeight + Layout.additionalNotesAreaHeight),
                reportButton.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: Metrics.margin),
            ]
        } else {
            return [
                bottomContainer.topAnchor.constraint(equalTo: safeBottomAnchor, constant: -Layout.buttonAreaHeight),
                reportButton.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: Metrics.margin),
            ]
        }
    }

    @objc private func reportButtonTapped() {
        guard let option = selectedOption else { return }
        viewModel.didTapReport(with: option)
    }

    @objc private func didTapClose() {
        viewModel.didTapClose()
    }

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
        reportButton.isEnabled = option.childOptions == nil
        selectedOption = option
    }

    func showAdditionalNotes() {

    }
}

extension ReportOptionsListViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholder {
            textView.text = nil
            textView.textColor = .blackText
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write here any additional notes that might help us to resolve this issue" // FIXME: localize
            textView.textColor = .placeholder
        }
    }
}
