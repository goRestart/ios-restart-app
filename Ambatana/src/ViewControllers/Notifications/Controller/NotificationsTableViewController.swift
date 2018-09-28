import UIKit

final class NotificationsTableViewController: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    private let viewModel: NotificationsViewModel
    
    init(viewModel: NotificationsViewModel) {
        self.viewModel = viewModel
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NotificationCenterHeader.Layout.totalHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = NotificationCenterHeader()
        let title = viewModel.sections[section].sectionDate.title
        header.setup(withTitle: title)
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataCount(atSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellData = viewModel.data(atSection: indexPath.section, atIndex: indexPath.row)
            else { return UITableViewCell() }
        guard let cell = tableView.dequeue(type: NotificationCenterModularCell.self, for: indexPath)
            else { return UITableViewCell() }
        cell.addModularData(with: cellData.modules, isRead: cellData.isRead, notificationCampaign: cellData.campaignType, date: cellData.date)
        cell.delegate = viewModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.selectedItemAtIndexPath(indexPath)
    }
}
