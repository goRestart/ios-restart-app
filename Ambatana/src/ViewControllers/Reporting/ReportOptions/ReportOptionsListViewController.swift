import Foundation
import LGComponents

final class ReportOptionsListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    private enum Layout {
        static let buttonContainerHeight: CGFloat = 80
        static let buttonHeight: CGFloat = 50
        static let estimatedRowHeight: CGFloat = 60
    }

    private let viewModel: ReportOptionsListViewModel

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(type: ReportOptionCell.self)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = Layout.estimatedRowHeight
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Layout.buttonContainerHeight, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: Layout.buttonContainerHeight, right: 0)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        return tableView
    }()
    
    private let reportButton: LetgoButton = {
        let button = LetgoButton(withStyle: ButtonStyle.primary(fontSize: ButtonFontSize.medium))
        button.setTitle("Report", for: .normal) // FIXME: Localize
        button.isEnabled = false
        return button
    }()

    private let buttonContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0.9
        return view
    }()

    private var selectedOption: ReportOption?

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
        view.addSubviewsForAutoLayout([tableView, buttonContainer, reportButton])
        view.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        reportButton.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
        setupConstraints()
    }

    private func setupConstraints() {
        let constraints: [NSLayoutConstraint] = [
            tableView.topAnchor.constraint(equalTo: safeTopAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            buttonContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            buttonContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
            buttonContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            buttonContainer.topAnchor.constraint(equalTo: safeBottomAnchor, constant: -Layout.buttonContainerHeight),
            reportButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor, constant: Metrics.margin),
            reportButton.leftAnchor.constraint(equalTo: buttonContainer.leftAnchor, constant: Metrics.margin),
            reportButton.rightAnchor.constraint(equalTo: buttonContainer.rightAnchor, constant: -Metrics.margin),
            reportButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    @objc private func reportButtonTapped() {
        guard let option = selectedOption else { return }
        viewModel.didTapReport(with: option)
    }

    @objc private func didTapClose() {
        viewModel.didTapClose()
    }

    // MARK: TableView Delegate & DataSource

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeue(type: ReportOptionCell.self, for: indexPath) else { return UITableViewCell() }
        let option = viewModel.optionGroup.options[indexPath.row]
        cell.configure(with: option)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.optionGroup.options.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = viewModel.optionGroup.options[indexPath.row]
        viewModel.didSelect(option: option)
        reportButton.isEnabled = option.childOptions == nil
        selectedOption = option
    }
}
