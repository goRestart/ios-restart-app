import Foundation
import LGComponents
import RxSwift
import RxCocoa

final class SearchViewController: BaseViewController {

    private let navbarSearch = LGNavBarSearchField(nil)
    private let viewModel: SearchViewModel
    private var trendingViewModel: TrendingSearchesViewModel?

    private let disposeBag = DisposeBag()

    required init(vm: SearchViewModel) {
        self.viewModel = vm
        super.init(viewModel: viewModel, nibName: nil)

        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    private func loadTrendingView() {
        let trending = TrendingSearchesViewController()
        trendingViewModel = trending.viewModel
        trendingViewModel?.navigator = viewModel.navigator
        add(childViewController: trending)
        view.addSubviewForAutoLayout(trending.view)
        NSLayoutConstraint.activate([
            trending.view.topAnchor.constraint(equalTo: safeTopAnchor),
            trending.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trending.view.bottomAnchor.constraint(equalTo: safeBottomAnchor),
            trending.view.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        trending.view.frame = view.frame
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTrendingView()

        setupView()
        setupRx()
        navbarSearch.searchTextField.becomeFirstResponder()
    }
    private func setupNavBar() {
        setNavBarTitleStyle(.custom(navbarSearch))
        navbarSearch.searchTextField.delegate = self

        let spacing = makeSpacingButton(withFixedWidth: Metrics.navBarDefaultSpacing)
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel , target: self,
                                     action: #selector(endEdit))
        navigationItem.setRightBarButtonItems([cancel, spacing], animated: false)
    }

    private func setupView() {
        setupNavBar()
    }

    private func setupRx() {
        guard let trendingViewModel = trendingViewModel else { return }
        navbarSearch
            .searchTextField
            .rx
            .text
            .throttle(0.2, scheduler: MainScheduler.instance) // to avoid searching too much
            .bind(to: trendingViewModel.searchText)
            .disposed(by: disposeBag)
    }
}

// MARK: UITextFieldDelegate
extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if viewModel.clearTextOnSearch {
            textField.text = viewModel.searchString
            return false
        }
        return true
    }

    dynamic func textFieldDidBeginEditing(_ textField: UITextField) {
        if viewModel.clearTextOnSearch {
            textField.text = nil
        }
        beginEdit()
    }

    dynamic func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text else { return true }
        viewModel.search(query)
        return true
    }
}

extension SearchViewController {
    func beginEdit() {
        navbarSearch.beginEdit()
        trendingViewModel?.retrieveLastUserSearch()
    }

    @objc func endEdit() {
        navbarSearch.cancelEdit()
        viewModel.cancel()
    }
}
