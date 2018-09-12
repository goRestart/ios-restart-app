import UIKit
import IGListKit
import RxSwift

public final class ImageCarousel: View {
  private let listAdapterDataSource = ImageCarouselListAdapter()
  private lazy var listAdapter: ListAdapter = {
    return ListAdapter(updater: ListAdapterUpdater(), viewController: nil, workingRangeSize: 2)
  }()

  private let collectionView: UICollectionView = {
    let collectionViewLayout = ListCollectionViewLayout(
      stickyHeaders: false,
      scrollDirection: .horizontal,
      topContentInset: 0,
      stretchToEdge: false
    )
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    collectionView.isPagingEnabled = true
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.backgroundColor = .clear
    return collectionView
  }()
  
  private let pageControl: UIPageControl = {
    let pageControl = UIPageControl()
    pageControl.currentPageIndicatorTintColor = .primary
    pageControl.pageIndicatorTintColor = .pinkishGrey
    pageControl.transform = CGAffineTransform(scaleX: 1.05, y: 1.05);
    pageControl.isUserInteractionEnabled = false
    pageControl.numberOfPages = 3
    pageControl.currentPage = 2
    return pageControl
  }()
  
  private let bag = DisposeBag()
  
  public override func setupView() {
    listAdapter.collectionView = collectionView
    listAdapter.dataSource = listAdapterDataSource
    
    addSubview(collectionView)
    addSubview(pageControl)
    
    backgroundColor = .clear
  }
  
  public override func setupConstraints() {
    snp.makeConstraints { make in
      make.height.equalTo(
        UIScreen.main.bounds.width - Margin.big
      )
    }
    collectionView.snp.makeConstraints { make in
      make.leading.equalTo(self)
      make.trailing.equalTo(self)
      make.top.equalTo(self)
      make.bottom.equalTo(pageControl.snp.top)
    }
    pageControl.snp.makeConstraints { make in
      make.centerX.equalTo(self)
      make.bottom.equalTo(self).offset(Margin.small)
    }
  }
  
  // MARK: - Public
  
  public func set(_ images: [CarouselImage]) {
    listAdapterDataSource.set(images)
    listAdapter.performUpdates(animated: true)
  }
}
