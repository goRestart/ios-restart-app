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
        tableView.register(ReportOptionCell.self, forCellReuseIdentifier: ReportOptionCell.reusableID)
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
        return button
    }()

    private let buttonContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0.9
        return view
    }()

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
        setNavBarTitle("Test Title")
    }

    private func setupUI() {
        view.addSubviewsForAutoLayout([tableView, buttonContainer, reportButton])
        view.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
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

    // MARK: TableView Delegate & DataSource

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReportOptionCell.reusableID, for: indexPath)
            as? ReportOptionCell else { return UITableViewCell() }
        cell.configure(with: "It shouldn't be on letgo", icon: R.Asset.Reporting.inappropriatePhoto.image)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
}
