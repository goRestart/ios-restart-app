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
    return pageControl
  }()
  
  private let bag = DisposeBag()
  
  public override func setupView() {
    listAdapter.collectionView = collectionView
    listAdapter.dataSource = listAdapterDataSource
    listAdapter.scrollViewDelegate = self
    
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
    pageControl.numberOfPages = images.count
    
    listAdapterDataSource.set(images)
    listAdapter.performUpdates(animated: true)
  }
}

// MARK: - UICollectionViewDelegate

extension ImageCarousel: UIScrollViewDelegate {
  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    guard let currentPage = collectionView.indexPathsForVisibleItems.first?.section else { return }
    pageControl.currentPage = currentPage
  }
}
