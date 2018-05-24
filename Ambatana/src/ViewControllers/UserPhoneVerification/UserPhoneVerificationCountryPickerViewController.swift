import Foundation
import RxSwift
import RxCocoa
import LGComponents

final class UserPhoneVerificationCountryPickerViewController: BaseViewController {

    private let viewModel: UserPhoneVerificationCountryPickerViewModel
    private let disposeBag = DisposeBag()

    private let tableView = UITableView()
    private let tableHeaderView = UIView()
    private let tableViewCellId = "countryCellId"
    private let searchBar = UISearchBar()

    struct Layout {
        static let searchBarHeight: CGFloat = 44
    }

    init(viewModel: UserPhoneVerificationCountryPickerViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRx()
        setupAccessibilityIds()
        viewModel.loadCountriesList()
    }

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        setNavBarBackgroundStyle(.white)
    }

    private func setupUI() {
        title = R.Strings.phoneVerificationCountryPickerViewTitle
        view.backgroundColor = .white
        view.addSubviewForAutoLayout(tableView)

        setupTableView()
        setupSearchBar()
        setupConstraints()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: tableViewCellId)

        tableHeaderView.frame.size.height = Layout.searchBarHeight
        tableHeaderView.addSubviewForAutoLayout(searchBar)
        tableView.tableHeaderView = tableHeaderView
    }

    private func setupSearchBar() {
        searchBar.autocapitalizationType = .words
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = R.Strings.phoneVerificationCountryPickerViewSearchPlaceholder
    }

    private func setupConstraints() {
        let constraints = [
            tableView.topAnchor.constraint(equalTo: safeTopAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: Layout.searchBarHeight),
            searchBar.topAnchor.constraint(equalTo: tableHeaderView.topAnchor),
            searchBar.leftAnchor.constraint(equalTo: tableHeaderView.leftAnchor),
            searchBar.rightAnchor.constraint(equalTo: tableHeaderView.rightAnchor),
            searchBar.bottomAnchor.constraint(equalTo: tableHeaderView.bottomAnchor),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func setupRx() {
        viewModel
            .filteredCountries
            .asDriver()
            .drive(onNext: { [weak self] filteredCountries in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        searchBar
            .rx.text
            .orEmpty
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] query in
                self?.viewModel.filterCountries(by: query)
            })
            .disposed(by: disposeBag)
    }

    private func setupAccessibilityIds() {
        tableView.set(accessibilityId: .phoneVerificationCountryPickerTable)
        searchBar.set(accessibilityId: .phoneVerificationCountryPickerSearchBar)
    }
}

extension UserPhoneVerificationCountryPickerViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredCountries.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let country = viewModel.filteredCountries.value[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellId, for: indexPath)
        cell.textLabel?.font = .smsVerificationCountryListCellText
        cell.textLabel?.textColor = .blackText
        cell.textLabel?.text = "\(country.name) (+\(country.callingCode))"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country = viewModel.filteredCountries.value[indexPath.row]
        viewModel.didSelect(country: country)
    }
}
