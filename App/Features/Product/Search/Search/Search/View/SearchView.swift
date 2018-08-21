import UI
import SnapKit
import RxSwift
import RxCocoa
import IGListKit
import Domain

public final class SearchView: View {

  private var listAdapterDataSource: GameSuggestionListAdapter?
  private let updater = ListAdapterUpdater()
  private var listAdapter: ListAdapter!
  public typealias GameSelectionBlock = (Identifier<Game>) -> Void
  private var onGameSelection: GameSelectionBlock?

  private let collectionView: UICollectionView = {
    let collectionViewLayout = ListCollectionViewLayout(stickyHeaders: false, topContentInset: 0, stretchToEdge: false)
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    collectionView.backgroundColor = .clear
    return collectionView
  }()
  
  private let bag = DisposeBag()
  private var viewModel: SearchViewModelType!

  init(viewModel: SearchViewModelType) {
    self.viewModel = viewModel
    super.init()
  }
  
  public override func setupView() {
    addSubview(collectionView)

    listAdapterDataSource = GameSuggestionListAdapter()
    listAdapterDataSource?.delegate = self

    listAdapter = ListAdapter(updater: updater, viewController: nil)
    listAdapter.collectionView = collectionView
    listAdapter.dataSource = listAdapterDataSource
  }
  
  public override func setupConstraints() {
    collectionView.snp.makeConstraints { make in
      make.left.equalTo(self)
      make.right.equalTo(self)
      make.top.equalTo(self)
      make.bottom.equalTo(self)
    }
  }
  
  public func bind(textField: UITextField, _ onGameSelection: @escaping GameSelectionBlock) {
    let textFieldObserver = textField.rx.value
      .orEmpty
      .distinctUntilChanged()
      .debounce(0.3, scheduler: MainScheduler.instance)
      .asObservable()

    viewModel.output.bind(to: textFieldObserver)
    
    viewModel.output.results
      .asObservable()
      .map(mapToView)
      .subscribe(onNext: { [weak self] suggestions in
        self?.listAdapterDataSource?.suggestions = suggestions
        self?.listAdapter.performUpdates(animated: true)
      }).disposed(by: bag)

    self.onGameSelection = onGameSelection
  }

  private func mapToView(_ elements: [GameSearchSuggestion]) -> [GameSuggestionViewRender] {
    return elements.map { GameSuggestionViewRender(suggestion: $0) }
  }
}

// MARK: - GameSuggestionListAdapterDelegate

extension SearchView: GameSuggestionListAdapterDelegate {
  func didSelectGameSuggestion(with id: Identifier<Game>) {
    onGameSelection?(id)
  }
}
