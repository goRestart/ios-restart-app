import UIKit
import LGComponents

final class ListingAttributeTableViewController: BaseViewController {
    
    private struct Layout {
        static let closeButtonWidth: CGFloat = 18.0
        static let closeButtonHeight: CGFloat = 18.0
        static let rowHeight: CGFloat = 72.0
        static let separatorInset: CGFloat = 16.5
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .graySeparator
        tableView.separatorInset = UIEdgeInsetsMake(0, Layout.separatorInset,
                                                    0, Layout.separatorInset)
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(R.Asset.IconsButtons.icClose.image,
                        for: .normal)
        return button
    }()

    private let viewModel: ListingAttributeTableViewModel
    
    init(withViewModel viewModel: ListingAttributeTableViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel,
                   nibName: nil)
        registerCells()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}


// MARK: - Setup methods

extension ListingAttributeTableViewController {

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    private func setupUI() {
        view.backgroundColor = .jetBlack
        setupTableView()
        setupConstraints()
        setupCloseButton()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    private func setupConstraints() {
        view.addSubviewsForAutoLayout([closeButton, tableView])
        
        closeButton.layout()
            .width(Layout.closeButtonWidth)
            .height(Layout.closeButtonHeight)
        
        closeButton.layout(with: view).left(by: Metrics.bigMargin)
        
        closeButton.topAnchor.constraint(equalTo: safeTopAnchor,
                                         constant: Metrics.bigMargin).isActive = true
        
        tableView.layout(with: view)
            .fillHorizontal()
            .bottom()
        
        tableView.layout(with: closeButton)
            .top(to: .bottom,
                 by: Metrics.margin)
    }
    
    private func setupCloseButton() {
        closeButton.addTarget(self,
                              action: #selector(closeButtonTapped),
                              for: .touchUpInside)
    }
    
    @objc private func closeButtonTapped() {
        viewModel.closeButtonTapped()
    }
    
    private func registerCells() {
        tableView.register(type: ListingAttributeTableViewCell.self)
    }
}


// MARK: - UITableViewDataSource Implementation

extension ListingAttributeTableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = viewModel.item(atIndex: indexPath.row),
            let cell = tableView.dequeue(type: ListingAttributeTableViewCell.self, for: indexPath) else { return UITableViewCell() }
        cell.setup(withItem: item)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
}


// MARK: - UITableViewDelegate Implementation

extension ListingAttributeTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Layout.rowHeight
    }
}
