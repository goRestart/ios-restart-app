import LGComponents
import UIKit
import RxSwift

final class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private static let cellIdentifier = "UITableViewCellIdentifier"

    private let viewModel: MainViewModel
    private var logoutButton = UIBarButtonItem()
    private let tableView = UITableView()
    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil,
                   bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "LGLogin Example"
        setupUI()
    }

    private func setupUI() {
        setupLogoutButton()
        setupTableView()
    }

    private func setupLogoutButton() {
        logoutButton = UIBarButtonItem(title: "Logout",
                                       style: .plain,
                                       target: self,
                                       action: #selector(MainViewController.logoutButtonPressed))
        navigationItem.leftBarButtonItem = logoutButton
        viewModel.logOutButtonIsEnabled
            .bind(to: logoutButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }

    @objc private func logoutButtonPressed() {
        viewModel.logoutButtonPressed()
    }

    private func setupTableView() {
        view.addSubviewForAutoLayout(tableView)
        NSLayoutConstraint.activate([tableView.topAnchor.constraint(equalTo: safeTopAnchor),
                                     tableView.bottomAnchor.constraint(equalTo: safeBottomAnchor),
                                     tableView.leadingAnchor.constraint(equalTo: safeLeadingAnchor),
                                     tableView.trailingAnchor.constraint(equalTo: safeTrailingAnchor)])

        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: MainViewController.cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
    }


    // MARK: - UITableViewDataSource

    public func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }

    public func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainViewController.cellIdentifier) ?? UITableViewCell()
        let index = indexPath.row
        cell.textLabel?.text = viewModel.titleForItemAt(index: index)
        return cell
    }


    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        viewModel.selectItemAt(index: index)

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
