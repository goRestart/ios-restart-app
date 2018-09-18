import LGComponents

final class AffiliationVouchersView: UIView {
    private let tableView = UITableView()

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    func setDataSource(_ dataSource: UITableViewDataSource) {
        tableView.dataSource = dataSource
    }

    func reloadData() {
        tableView.reloadData()
    }

    private func setupUI() {
        backgroundColor = .white

        addSubviewsForAutoLayout([tableView])
        tableView.constraintsToEdges(in: self).activate()

        tableView.register(type: AffiliationVoucherCell.self)
        tableView.rowHeight = 74
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
    }
}
