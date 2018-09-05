import Foundation
import LGComponents
import LGCoreKit
import RxSwift
import RxCocoa

private enum SuggestiveSearches {
    static let minimumSearchesSavedToShowCollection = 3
    static let lastSearchesSavedMaximum = 10
    static let lastSearchesShowMaximum = 3
}

final class TrendingSearchesViewModel: BaseViewModel {

    weak var navigator: TrendingSearchesNavigator?

    private let keyValueStorage: KeyValueStorageable
    private let locationManager: LocationManager
    private let searchRepository: SearchRepository

    private let disposeBag = DisposeBag()

    let trendingSearches = Variable<[String]>([])
    let lastSearches = Variable<[LocalSuggestiveSearch]>([])
    let suggestiveSearchInfo = Variable<SuggestiveSearchInfo>(.empty())

    let searchText = Variable<String?>(nil)
    
    var wireframe: TrendingSearchesNavigator?

    private var onUserSearchCallback: ((SearchType) -> ())?

    convenience override init() {
        self.init(keyValueStorage: KeyValueStorage.sharedInstance,
                  locationManager: Core.locationManager,
                  searchRepository: Core.searchRepository,
                  onUserSearchCallback: nil)
    }
    
    convenience init(onUserSearchCallback: ((SearchType) -> ())?) {
        self.init(keyValueStorage: KeyValueStorage.sharedInstance,
                  locationManager: Core.locationManager,
                  searchRepository: Core.searchRepository,
                  onUserSearchCallback: onUserSearchCallback)
    }

    private init(keyValueStorage: KeyValueStorageable,
                 locationManager: LocationManager,
                 searchRepository: SearchRepository,
                 onUserSearchCallback: ((SearchType) -> ())?) {
        self.keyValueStorage = keyValueStorage
        self.locationManager = locationManager
        self.searchRepository = searchRepository
        self.onUserSearchCallback = onUserSearchCallback
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)

        if firstTime {
            if locationManager.currentLocation != nil {
                updateSearches()
            }
            setupRx()
        }
    }

    private func setupRx() {
        locationManager
            .locationEvents
            .skip(1) // first time is already processed
            .filter { $0 == .locationUpdate }
            .bind { [weak self] _ in
                self?.locationDidChange()
            }.disposed(by: disposeBag)

        searchText
            .asDriver()
            .drive(onNext: { [weak self] (text) in
            guard let text = text else { return }
            self?.updateSearches(search: text)
        }).disposed(by: disposeBag)
    }

    func endEditing() { wireframe?.cancelSearch() }

    func cleanUpLastSearches() {
        keyValueStorage[.lastSuggestiveSearches] = []
        lastSearches.value = keyValueStorage[.lastSuggestiveSearches]
    }
}

extension TrendingSearchesViewModel {
    private func updateSearches(search text: String) {
        let charactersCount = text.count
        if charactersCount > 0 {
            retrieveSuggestiveSearches(term: text)
        } else {
            cleanUpSuggestiveSearches()
        }
    }

    private func retrieveSuggestiveSearches(term: String) {
        guard let languageCode = Locale.current.languageCode else { return }

        searchRepository.retrieveSuggestiveSearches(language: languageCode,
                                                    limit: SharedConstants.listingsSearchSuggestionsMaxResults,
                                                    term: term) { [weak self] result in
                                                        // prevent showing results when deleting the search text
                                                        guard let sourceText = self?.searchText.value else { return }
                                                        self?.suggestiveSearchInfo.value = SuggestiveSearchInfo(suggestiveSearches: result.value ?? [],
                                                                                                                sourceText: sourceText)
        }
    }

    private func cleanUpSuggestiveSearches() {
        suggestiveSearchInfo.value = SuggestiveSearchInfo.empty()
    }
}

extension TrendingSearchesViewModel {
    func updateSearches() {
        retrieveLastUserSearch()
        retrieveTrendingSearches()
    }
    private func locationDidChange() {
        updateSearches()
    }

    func retrieveLastUserSearch() {
        // We saved up to lastSearchesSavedMaximum(10) but we show only lastSearchesShowMaximum(3)
        var searchesToShow = [LocalSuggestiveSearch]()
        let allSearchesSaved = keyValueStorage[.lastSuggestiveSearches]
        if allSearchesSaved.count > SuggestiveSearches.lastSearchesShowMaximum {
            searchesToShow = Array(allSearchesSaved.suffix(SuggestiveSearches.lastSearchesShowMaximum))
        } else {
            searchesToShow = keyValueStorage[.lastSuggestiveSearches]
        }
        lastSearches.value = searchesToShow.reversed()
    }

    func retrieveTrendingSearches() {
        guard let currentCountryCode = locationManager.currentLocation?.countryCode else { return }

        searchRepository.index(countryCode: currentCountryCode) { [weak self] result in
            self?.trendingSearches.value = result.value ?? []
        }
    }
}

extension TrendingSearchesViewModel {
    func numberOfItems(type: SearchSuggestionType) -> Int {
        switch type {
        case .suggestive:
            return suggestiveSearchInfo.value.count
        case .lastSearch:
            return lastSearches.value.count
        case .trending:
            return trendingSearches.value.count
        }
    }

    func selected(type: SearchSuggestionType, row: Int) {
        switch type {
        case .suggestive:
            selectedSuggestiveSearchAtIndex(row)
        case .lastSearch:
            selectedLastSearchAtIndex(row)
        case .trending:
            selectedTrendingSearchAtIndex(row)
        }
    }

    private func selectedTrendingSearchAtIndex(_ index: Int) {
        guard let trendingSearch = trendingSearchAtIndex(index), !trendingSearch.isEmpty else { return }
        onUserSearchCallback?(.trending(query: trendingSearch))
        wireframe?.cancelSearch()
    }

    private func selectedSuggestiveSearchAtIndex(_ index: Int) {
        guard let (suggestiveSearch, _) = suggestiveSearchAtIndex(index) else { return }
        onUserSearchCallback?(.suggestive(search: suggestiveSearch, indexSelected: index))
        wireframe?.cancelSearch()
    }

    private func selectedLastSearchAtIndex(_ index: Int) {
        guard let lastSearch = lastSearchAtIndex(index), let name = lastSearch.name, !name.isEmpty else { return }
        onUserSearchCallback?(.lastSearch(search: lastSearch))
        wireframe?.cancelSearch()
    }

    func trendingSearchAtIndex(_ index: Int) -> String? {
        return trendingSearches.value[safeAt: index]
    }

    func suggestiveSearchAtIndex(_ index: Int) -> (suggestiveSearch: SuggestiveSearch, sourceText: String)? {
        guard let search = suggestiveSearchInfo.value.suggestiveSearches[safeAt: index] else { return nil }
        return (search, suggestiveSearchInfo.value.sourceText)
    }

    func lastSearchAtIndex(_ index: Int) -> SuggestiveSearch? {
        return lastSearches.value[safeAt: index]?.suggestiveSearch
    }
}
