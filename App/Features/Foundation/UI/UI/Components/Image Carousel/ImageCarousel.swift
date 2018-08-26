import UIKit
import IGListKit

public final class ImageCarousel: View {
  private var listAdapterDataSource: ImageCarouselListAdapter?
  private let updater = ListAdapterUpdater()
  private var listAdapter: ListAdapter?

  private let collectionView: UICollectionView = {
    let collectionViewLayout = ListCollectionViewLayout(
      stickyHeaders: false,
      scrollDirection: .horizontal,
      topContentInset: 0, stretchToEdge: false
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
    pageControl.numberOfPages = 5
    pageControl.currentPage = 2
    return pageControl
  }()
  
  public override func setupView() {
    listAdapterDataSource = ImageCarouselListAdapter()
    listAdapter = ListAdapter(
      updater: updater,
      viewController: nil,
      workingRangeSize: 3
    )
    listAdapter?.collectionView = collectionView
    listAdapter?.dataSource = listAdapterDataSource
    
    addSubview(collectionView)
    addSubview(pageControl)
    
    backgroundColor = .clear
    
    listAdapterDataSource?.set([
      Image(url: URL(string: "https://cdn.wallapop.com/images/10420/34/w9/__/c10420p189622489/i424166429.jpg?pictureSize=W320")),
      Image(url: URL(string: "https://cdn.wallapop.com/images/10420/1o/c0/__/c10420p101337571/i220817887.jpg?pictureSize=W320")),
      Image(url: URL(string: "https://cdn.wallapop.com/images/10420/40/1z/__/c10420p241957023/i553163186.jpg?pictureSize=W320"))
      ])
    listAdapter?.performUpdates(animated: true)
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
}
