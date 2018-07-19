import LGComponents
import RxSwift
import RxDataSources
import RxCocoa

final class DropdownViewController: KeyboardViewController {
    
    private let disposeBag = DisposeBag()
    
    private let viewModel : DropdownViewModel
    private let keyboardHelper: KeyboardHelper
    
    //  MARK: - Subviews
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.tintColor = .white
        tableView.indicatorStyle = .white
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Metrics.bigMargin*2, right: 0)
        return tableView
    }()
    
    private let searchBar = LGPickerSearchBar(withStyle: .darkContent)
    
    private let gradient: GradientView = {
        let gradient = GradientView(colors: [.clear, .lgBlack], locations: [0.75, 1.0])
        gradient.isUserInteractionEnabled = false
        return gradient
    }()
    
    //  MARK: - Lifecycle
    
    convenience init(withViewModel viewModel: DropdownViewModel) {
        self.init(viewModel: viewModel, keyboardHelper: KeyboardHelper())
    }
    
    private init(viewModel: DropdownViewModel, keyboardHelper: KeyboardHelper) {
        self.keyboardHelper = keyboardHelper
        self.viewModel = viewModel
        super.init(viewModel: nil, nibName: nil)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        addSubViews()
        addConstraints()
    }
    
    private func addSubViews() {
        view.addSubviewsForAutoLayout([searchBar, tableView, gradient])
    }
    
    private func addConstraints() {
        
        let searchConstraints = [searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Metrics.margin),
                                 searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Metrics.margin),
                                 searchBar.topAnchor.constraint(equalTo: safeTopAnchor, constant: Metrics.margin),
                                 searchBar.heightAnchor.constraint(equalToConstant: Layout.Search.height)]
        
        let tableContraints = [tableView.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor),
                               tableView.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor),
                               tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: Metrics.margin),
                               tableView.bottomAnchor.constraint(equalTo: safeBottomAnchor)]

        let gradientConstraints = [gradient.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
                                   gradient.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
                                   gradient.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
                                   gradient.heightAnchor.constraint(equalToConstant: Layout.Gradient.height)]
        
        NSLayoutConstraint.activate(searchConstraints + tableContraints + gradientConstraints)
    }

    private func setupRx() {

    }
    
}

private struct Layout {
    struct Search {
        static let height: CGFloat = 44
    }
    struct Gradient {
        static let height: CGFloat = 500
    }
}
