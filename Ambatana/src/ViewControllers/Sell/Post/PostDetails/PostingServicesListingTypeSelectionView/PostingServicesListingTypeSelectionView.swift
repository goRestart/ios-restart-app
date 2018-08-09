
import UIKit
import LGCoreKit

protocol PostingServicesListingTypeSelectionViewDelegate: class {
    func didSelectServicesListingType(type: ServiceListingType)
}

class PostingServicesListingTypeSelectionView: UIView, PostingViewConfigurable, UITableViewDelegate, UITableViewDataSource {
    
    private enum Layout {
        static let cellHeight: CGFloat = 76.0
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        tableView.register(type: PostingServicesListingTypeSelectionCell.self)
        return tableView
    }()
    
    private weak var delegate: PostingServicesListingTypeSelectionViewDelegate?
    private let items: [ServiceListingType]
    
    init(withDelegate delegate: PostingServicesListingTypeSelectionViewDelegate,
         items: [ServiceListingType]) {
        self.delegate = delegate
        self.items = items
        super.init(frame: .zero)
        setupTableView()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupLayout() {
        addSubviewForAutoLayout(tableView)
        tableView.layout(with: self).fill()
    }
    
    
    // MARK: UITableViewDelegate Implementation
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Layout.cellHeight
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        guard let item = items[safeAt: indexPath.row] else { return }
        delegate?.didSelectServicesListingType(type: item)
    }
    
    
    // MARK: UITableViewDataSource Implementation
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = items[safeAt: indexPath.row],
            let cell = tableView.dequeue(type: PostingServicesListingTypeSelectionCell.self,
                                           for: indexPath) else { return UITableViewCell() }
        cell.setup(withPrefixText: item.displayPrefix,
                   nameText: item.displayName)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    
    // MARK: PostingViewConfigurable Implementation
    
    func setupContainerView(view: UIView) {
        view.addSubviewForAutoLayout(self)
        layout(with: view).fill()
    }
    
    func setupView(viewModel: PostingDetailsViewModel) { }
    
}
