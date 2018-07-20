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
        tableView.register(type: DropdownHeaderCell.self)
        tableView.register(type: DropdownItemCell.self)
        
        return tableView
    }()
    
    private let searchBar = LGPickerSearchBar(withStyle: .darkContent)
    
    private let gradient: GradientView = {
        let gradient = GradientView(colors: [UIColor.white.withAlphaComponent(0.0),
                                             .white],
                                    locations: [0.75, 1.0])
        gradient.isUserInteractionEnabled = false
        return gradient
    }()
    
    private let doneButton: LetgoButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .big))
        button.alpha = 0
        button.setTitle(R.Strings.commonDone, for: .normal)
        return button
    }()
    
    private let resetButton: UIBarButtonItem = {
        let resetButton = UIBarButtonItem(title: R.Strings.filtersNavbarReset,
                                          style: UIBarButtonItemStyle.plain,
                                          target: self,
                                          action: #selector(resetButtonTapped))
        resetButton.tintColor = .primaryColor
        return resetButton
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
        setupTableView()
        setupRx()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        view.backgroundColor = .white
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        showDoneButton()
        showResetButton()
        addSubViews()
        addConstraints()
    }
    
    private func setupTableView() {
        tableView.delegate = self
    }
    
    private func addSubViews() {
        view.addSubviewsForAutoLayout([searchBar, tableView, gradient, doneButton])
    }
    
    private func addConstraints() {
        
        let searchConstraints = [searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Metrics.margin),
                                 searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Metrics.margin),
                                 searchBar.topAnchor.constraint(equalTo: safeTopAnchor, constant: Metrics.margin),
                                 searchBar.heightAnchor.constraint(equalToConstant: Layout.Search.height)]
        
        let tableContraints = [tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                               tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                               tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: Metrics.margin),
                               tableView.bottomAnchor.constraint(equalTo: safeBottomAnchor)]

        let gradientConstraints = [gradient.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
                                   gradient.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
                                   gradient.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
                                   gradient.heightAnchor.constraint(equalToConstant: Layout.Gradient.height)]
        
        let buttonConstraints = [doneButton.heightAnchor.constraint(equalToConstant: Layout.Done.height),
                                 doneButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Layout.Done.minimumWidth),
                                 doneButton.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: -Metrics.bigMargin),
                                 doneButton.bottomAnchor.constraint(equalTo: keyboardView.topAnchor, constant: -Metrics.veryBigMargin)]

        NSLayoutConstraint.activate([searchConstraints,
                                     tableContraints,
                                     gradientConstraints,
                                     buttonConstraints].flatMap { $0 })
    }

    private func setupRx() {

        viewModel.attributesDriver.asObservable().bind(to: tableView.rx.items) { (tableView, row, element) in
            let indexPath = IndexPath(row: row, section: 0)
            switch element.content.type {
            case .header:
                guard let cell = tableView.dequeue(type: DropdownHeaderCell.self,
                                                   for: indexPath) else {
                                                                return UITableViewCell()
                }
                
                cell.setup(withRepresentable: element)
                return cell
            case .item:
                guard let cell = tableView.dequeue(type: DropdownItemCell.self,
                                                   for: indexPath) else {
                                                                return UITableViewCell()
                }
                
                cell.setup(withRepresentable: element)
                return cell
            }
        }
        .disposed(by: disposeBag)
    }
    
    //  MARK: - Button Actions
    
    @objc private func doneButtonTapped() {
        let selections = (selectedHeaderId: "", selectedItemsIds: [""])
        viewModel.filter(selections)
    }
    
    @objc private func resetButtonTapped() {
        viewModel.resetFilters()
    }
}

private extension DropdownViewController {
    func showResetButton() {
        navigationItem.rightBarButtonItem = resetButton
    }
    
    func hideResetButton() {
        navigationItem.rightBarButtonItem = nil
    }
    
    func showDoneButton() {
        doneButton.animateTo(alpha: 1.0)
    }
    
    func hideDoneButton() {
        doneButton.animateTo(alpha: 0.0)
    }
}

extension DropdownViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.itemHeight(atIndex: indexPath.item)
    }
}

private struct Layout {
    struct Search {
        static let height: CGFloat = 44
    }
    struct Gradient {
        static let height: CGFloat = 500
    }
    struct Done {
        static let height: CGFloat = 44
        static let minimumWidth: CGFloat = 114
    }
}
