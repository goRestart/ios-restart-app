import UIKit
import LGCoreKit

final class ServerEnvironmentPicker: UITableViewController {
    
    private let environments: [EnvironmentType] = [.production, .staging, .escrow, .canary]
    private let selectedEnvironment: EnvironmentType
    private let onNewEnvironment: (EnvironmentType) -> (Void)
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(selectedEnvironment: EnvironmentType, onNewEnvironment: @escaping (EnvironmentType) -> (Void)) {
        self.selectedEnvironment = selectedEnvironment
        self.onNewEnvironment = onNewEnvironment
        super.init(style: .plain)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Environment"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return environments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let environment = environments[indexPath.row]
        cell.textLabel?.text = environment.rawValue.capitalizedFirstLetterOnly
        cell.isSelected = environment == selectedEnvironment
        cell.accessoryType = cell.isSelected ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let environment = environments[indexPath.row]
        if environment != selectedEnvironment {
            navigationController?.popViewController(animated: true)
            onNewEnvironment(environment)
        }
    }
}
