import Foundation
import LGComponents
import RxSwift

final class TrendingSearchesViewController: BaseViewController {

    private let trendingSearchView = TrendingSearchView()
    private let keyboardHelper = KeyboardHelper()

    let viewModel: TrendingSearchesViewModel

    private let disposeBag = DisposeBag()

    required init(viewModel: TrendingSearchesViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    convenience init() {
        self.init(viewModel: TrendingSearchesViewModel())
    }

    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    override func loadView() {
        self.view = trendingSearchView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        trendingSearchView.updateTrendingSearchTableView(hidden: false)
        setupSuggestionsTable()
        setupKeyboard()
    }

    private func setupKeyboard() {
        keyboardHelper
            .rx_keyboardHeight
            .asDriver()
            .skip(1) // Ignore the first call with height == 0
            .drive(onNext: { [weak self] height in
                self?.trendingSearchView.updateBottomTableView(contentInset: height)
                UIView.animate(withDuration: 0.3, animations: {
                    self?.trendingSearchView.layoutIfNeeded()
                })
            }).disposed(by: disposeBag)
    }

    func setupSuggestionsTable() {
        trendingSearchView.delegate = self

        Observable.combineLatest(viewModel.trendingSearches.asObservable(),
                                 viewModel.suggestiveSearchInfo.asObservable(),
                                 viewModel.lastSearches.asObservable()) { trendings, suggestiveSearches, lastSearches in
                                    return trendings.count + suggestiveSearches.count + lastSearches.count
            }.bind { [weak self] totalCount in
                self?.trendingSearchView.reloadTrendingSearchTableView()
                self?.trendingSearchView.updateTrendingSearchTableView(hidden: totalCount == 0)
            }.disposed(by: disposeBag)

    }
}

extension TrendingSearchesViewController: TrendingSearchViewDelegate {

    func trendingSearchBackgroundTapped(_ view: TrendingSearchView) {
        viewModel.endEditing()
    }

    func trendingSearchCleanButtonPressed(_ view: TrendingSearchView) {
        viewModel.cleanUpLastSearches()
    }

    func trendingSearch(_ view: TrendingSearchView, numberOfRowsIn section: Int) -> Int {
        guard let sectionType = SearchSuggestionType.sectionType(index: section) else { return 0 }
        return viewModel.numberOfItems(type: sectionType)
    }

    func trendingSearch(_ view: TrendingSearchView, cellSelectedAt indexPath: IndexPath) {
        guard let sectionType = SearchSuggestionType.sectionType(index: indexPath.section) else { return }
        viewModel.selected(type: sectionType, row: indexPath.row)
    }

    func trendingSearch(_ view: TrendingSearchView,
                        cellContentAt  indexPath: IndexPath) -> SuggestionSearchCellContent? {
        guard let sectionType = SearchSuggestionType.sectionType(index: indexPath.section) else { return nil }
        switch sectionType {
        case .suggestive:
            guard let (suggestiveSearch, sourceText) = viewModel.suggestiveSearchAtIndex(indexPath.row) else { return nil }
            return SuggestionSearchCellContent(title: suggestiveSearch.title,
                                               titleSkipHighlight: sourceText,
                                               subtitle: suggestiveSearch.subtitle,
                                               icon: suggestiveSearch.icon) { [weak self] in
                                                // TODO: go to filtered screen
            }
        case .lastSearch:
            guard let lastSearch = viewModel.lastSearchAtIndex(indexPath.row) else { return nil }
            return SuggestionSearchCellContent(title: lastSearch.title, subtitle: lastSearch.subtitle, icon: lastSearch.icon)
        case .trending:
            guard let trendingSearch = viewModel.trendingSearchAtIndex(indexPath.row) else { return nil }
            return SuggestionSearchCellContent(title: trendingSearch)
        }
    }
}
