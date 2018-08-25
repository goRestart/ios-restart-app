import UI
import SnapKit
import RxSwift
import RxCocoa
import IGListKit
import Domain

public enum GameSuggestionEvent {
  case gameSelected(Identifier<Game>)
}

public final class SearchView: View {
  
  fileprivate var state = PublishSubject<GameSuggestionEvent>()
  
  private var listAdapterDataSource: GameSuggestionListAdapter?
  private let updater = ListAdapterUpdater()
  private var listAdapter: ListAdapter!

  private let collectionView: UICollectionView = {
    let collectionViewLayout = ListCollectionViewLayout(stickyHeaders: false, topContentInset: 0, stretchToEdge: false)
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    collectionView.backgroundColor = .clear
    return collectionView
  }()
  
  private let bag = DisposeBag()
  fileprivate var viewModel: SearchViewModelType!

  init(viewModel: SearchViewModelType) {
    self.viewModel = viewModel
    super.init()
  }
  
  public override func setupView() {
    addSubview(collectionView)

    listAdapterDataSource = GameSuggestionListAdapter(state: state)
    
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
  
  public func bind(_ query: Observable<String>) {
    viewModel.output.bind(to: query)
    viewModel.output.results
      .map(toUIModel)
      .subscribe(onNext: { [weak self] suggestions in
        self?.listAdapterDataSource?.suggestions = suggestions
        self?.listAdapter.performUpdates(animated: true)
      }).disposed(by: bag)
  }

  private func toUIModel(_ elements: [GameSearchSuggestion]) -> [GameSuggestionUIModel] {
    return elements.map { GameSuggestionUIModel(suggestion: $0) }
  }
}

// MARK: - View bindings

extension Reactive where Base: SearchView {
  public var state: PublishSubject<GameSuggestionEvent> {
    return base.state
  }
}