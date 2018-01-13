import UI
import SnapKit
import RxSwift

public final class SearchView: View {
 
  private let collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
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
  }
  
  public override func setupConstraints() {
    collectionView.snp.makeConstraints { make in
      make.edges.equalTo(self)
    }
  }
  
  public func bind(textField: UITextField) {
    let textFieldObserver = textField.rx.value
      .orEmpty
      .filter { $0.count >= 1 }
      .debounce(0.5, scheduler: MainScheduler.instance)
      .asObservable()
    
    viewModel.output.bind(to: textFieldObserver)
    
    viewModel.output.results
      .asObservable()
      .subscribe(onNext: { games in
        print("Games = \(games)")
      }, onError: { error in
        print("Error = \(error)")
      }).disposed(by: bag)
  }
}
