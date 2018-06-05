import Foundation
import LGComponents

class MostSearchedItemsListViewController: BaseViewController, UITableViewDelegate,
    UITableViewDataSource, MostSearchedItemsListCellDelegate {
    
    let closeButton = UIBarButtonItem()
    let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    
    let viewModel: MostSearchedItemsListViewModel
    
    
    // MARK: - Lifecycle
    
    init(viewModel: MostSearchedItemsListViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil, navBarBackgroundStyle: .transparent(substyle: .light))
        
        tableView.register(MostSearchedItemsListCell.self, forCellReuseIdentifier: MostSearchedItemsListCell.reusableID)
        tableView.register(MostSearchedItemsListHeader.self, forHeaderFooterViewReuseIdentifier: MostSearchedItemsListHeader.reusableID)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        closeButton.image = R.Asset.IconsButtons.navbarClose.image
        closeButton.style = .plain
        closeButton.target = self
        closeButton.action = #selector(MostSearchedItemsListViewController.closeButtonPressed)
        navigationItem.leftBarButtonItem = closeButton
        
        view.backgroundColor = .white
        
        edgesForExtendedLayout = []
        tableView.estimatedRowHeight = MostSearchedItemsListCell.cellHeight
        tableView.sectionHeaderHeight = MostSearchedItemsListHeader.viewHeight
        tableView.bounces = false
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        tableView.layout(with: view).fillHorizontal()
        tableView.layout(with: topLayoutGuide).below()
        tableView.layout(with: bottomLayoutGuide).above()
    }

    
    // MARK: - UI Actions
    
    @objc private func closeButtonPressed() {
        viewModel.closeButtonPressed()
    }
    
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.mostSearchedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MostSearchedItemsListCell.reusableID,
                                                        for: indexPath) as? MostSearchedItemsListCell else { return UITableViewCell() }
        let item = viewModel.itemAtIndex(indexPath.row)
        cell.delegate = self
        cell.updateWith(item: item, showSearchButton: !viewModel.isSearchEnabled)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header: MostSearchedItemsListHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier:
            MostSearchedItemsListHeader.reusableID) as? MostSearchedItemsListHeader else { return nil }
        header.updateTitleTo(viewModel.titleString)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return MostSearchedItemsListHeader.viewHeight
    }
    
    
    // MARK: - MostSearchedItemsCellDelegate
    
    func didPostAction(item: LocalMostSearchedItem) {
        viewModel.postButtonAction(item: item)
    }
    
    func didSearchAction(listingTitle: String) {
        viewModel.searchButtonAction(listingTitle: listingTitle)
    }
    
}
