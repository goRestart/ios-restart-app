final class AffiliationVouchersDataSource: NSObject, UITableViewDataSource {
    var vouchers: [VoucherCellData] = []

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vouchers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeue(type: AffiliationVoucherCell.self,
                                           for: indexPath) else { return UITableViewCell() }
        guard let data = vouchers[safeAt: indexPath.row] else { return UITableViewCell() }

        cell.populate(with: data)
        return cell
    }
}
