import RxSwift
import RxCocoa

final class PhotoMediaViewerView: UIView {
    fileprivate let collectionView: UICollectionView
    private let delegate = PhotoMediaViewerDelegate()
    private var disposeBag = DisposeBag()

    override init(frame: CGRect) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collection = UICollectionView(frame: frame, collectionViewLayout: flowLayout)

        collection.isPagingEnabled = true
        collection.contentInset = .zero
        collection.contentOffset = .zero
        collection.isScrollEnabled = false
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.allowsSelection = false
        collection.delegate = delegate
        if #available(iOS 11.0, *) {
            collection.contentInsetAdjustmentBehavior = .never
        }
        collectionView = collection

        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    func reset() {
        collectionView.setContentOffset(.zero, animated: false)
    }

    func reloadData() {
        collectionView.reloadData()
    }

    func set(viewModel: PhotoMediaViewerViewModel) {
        disposeBag = DisposeBag()
        collectionView.dataSource = viewModel.datasource
        reloadData()
        viewModel.rx.index.skip(1).distinctUntilChanged().delay(0.5).drive(rx.index).disposed(by: disposeBag)
    }

    private func setupUI() {
        addSubviewForAutoLayout(collectionView)
        [
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ].activate()

        collectionView.register(type: ListingCarouselImageCell.self)
        collectionView.register(type: ListingCarouselVideoCell.self)
    }
}

extension Reactive where Base: PhotoMediaViewerView {
    var index: Binder<Int> {
        return Binder(self.base) { view, index in
            guard view.collectionView.numberOfItems(inSection: 0) > 0 else { return }
            view.collectionView.scrollToItem(at: IndexPath(item: index, section: 0),
                                             at: .centeredHorizontally,
                                             animated: true)
        }
    }
}
