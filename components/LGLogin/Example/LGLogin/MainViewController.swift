import UIKit
import LGComponents

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private static let cellIdentifier = "UITableViewCellIdentifier"

    private let viewModel: MainViewModel
    private let tableView: UITableView


    // MARK: - Lifecycle

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        self.tableView = UITableView()
        super.init(nibName: nil, bundle: nil)
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
        setupTableView()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        let constraints: [NSLayoutConstraint]
        if #available(iOS 11, *) {
            constraints = [tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                           tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                           tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                           tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)]
        } else {
            constraints = [tableView.topAnchor.constraint(equalTo: view.topAnchor),
                           tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                           tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                           tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)]
        }
        constraints.forEach { $0.isActive = true }

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
