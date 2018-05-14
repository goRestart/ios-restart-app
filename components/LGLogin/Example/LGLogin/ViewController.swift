import UIKit
import LGComponents

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private static let cellIdentifier = "UITableViewCellIdentifier"

    private let tableView: UITableView = UITableView()


    override func viewDidLoad() {
        super.viewDidLoad()
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

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ViewController.cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: - UITableViewDataSource

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ViewControllerListItem.allValues.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ViewController.cellIdentifier) ?? UITableViewCell()
        let item = ViewControllerListItem.allValues[indexPath.row]
        cell.textLabel?.text = item.title
        return cell
    }


    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = ViewControllerListItem.allValues[indexPath.row]

        let config = LoginConfig(signUpEmailTermsAndConditionsAcceptRequired: false)
        let factory = LoginComponentFactory(config: config)
        let coordinator = factory.makeLoginCoordinator(source: .install,
                                                       style: .fullScreen,
                                                       loggedInAction: { print("action!") },
                                                       cancelAction: nil)
    }
}

struct LoginConfig: LoginComponentConfig {
    let signUpEmailTermsAndConditionsAcceptRequired: Bool
}

enum ViewControllerListItem {
    case fullScreen

    static var allValues: [ViewControllerListItem] = [.fullScreen]

    var title: String {
        switch self {
        case .fullScreen:
            return "Full Screen"
        }
    }
}
