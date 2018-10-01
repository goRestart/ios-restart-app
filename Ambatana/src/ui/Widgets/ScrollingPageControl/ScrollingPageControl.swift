
import CoreGraphics

final class ScrollingPageControl: UIView {
    
    private struct Layout {
        static let scrollViewWidth: CGFloat = 14.0
        static let itemSize: CGSize = CGSize(width: 14.0, height: 14.0)
        static let interItemSpacing: CGFloat = 3.0
    }
    
    enum Direction {
        case up, down
    }
    
    private(set) var numberOfPages = 0
    private var currentPage = 0
    private let adjacentIndexThreshold = 2
    
    private var itemColor: UIColor
    private let deselectedItemColor: UIColor

    private var dotViews: [PageItemDotView] = []
    
    var displayCurrentPage: Int {
        return currentPage + 1
    }
    
    private var previouslySelectedPage = 0
    private var directionChangeSourcePage = 0
    
    private var currentScrollDirection: ScrollingPageControl.Direction {
        if currentPage >= previouslySelectedPage {
            return .down
        } else {
           return .up
        }
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.isUserInteractionEnabled = false
        scrollView.isDirectionalLockEnabled = true
        scrollView.bounces = false
        return scrollView
    }()
    
    required init(itemColor: UIColor,
                  deselectedItemColor: UIColor) {
        self.itemColor = itemColor
        self.deselectedItemColor = deselectedItemColor
        super.init(frame: .zero)
        performInitialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetContentOffset() {
        scrollView.setContentOffset(.zero, animated: false)
    }
    
    func updateItemColor(to color: UIColor?) {
        guard let color = color else { return }
        itemColor = color
    }
    
    func updateNumberOfPages(to numberOfPages: Int) {
        self.numberOfPages = numberOfPages
        setupScrollView()
    }
    
    func updateCurrentPage(to nextPage: Int, animated: Bool = true) {
        let previousScrollDirection = currentScrollDirection
        previouslySelectedPage = currentPage
        self.currentPage = nextPage
        
        if previousScrollDirection != currentScrollDirection {
            directionChangeSourcePage = previouslySelectedPage
        }
        
        updateItemsState(forSelectedIndex: currentPage, animated: animated)

        scrollToItem(atIndex: currentPage)
    }
    
    private func performInitialSetup() {
        clipsToBounds = false
        scrollView.clipsToBounds = false
        addSubviewForAutoLayout(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.centerXAnchor.constraint(equalTo: centerXAnchor),
            scrollView.widthAnchor.constraint(equalToConstant: Layout.scrollViewWidth)
            ])
    }
    
    private func setupScrollView() {
        resetScrollView()
        
        for i in 0...numberOfPages-1 {
            let itemRect = frameForItem(atIndex: i)
            let itemView = PageItemDotView(withColor: itemColor,
                                           deselectedColor: deselectedItemColor,
                                           frame: itemRect)
            scrollView.addSubview(itemView)
            dotViews.append(itemView)
        }
        
        let lastItemFrame = frameForItem(atIndex: numberOfPages-1)
        let scrollContentSize = CGSize(width: lastItemFrame.width, height: lastItemFrame.maxY)
        scrollView.contentSize = scrollContentSize
    }
    
    private func frameForItem(atIndex index: Int) -> CGRect {
        let yOrigin = dotItemYOrigin(forOffset: index)
        return CGRect(x: 0,
               y: yOrigin,
               width: Layout.itemSize.width,
               height: Layout.itemSize.height)
    }
    
    private func dotItemYOrigin(forOffset offset: Int) -> CGFloat {
        guard offset != 0 else {
            return 0
        }
        
        let heightOfPreviousItems: CGFloat = CGFloat(offset)*Layout.itemSize.height
        let heightOfPreviousInterItemOffsets: CGFloat = CGFloat(offset)*Layout.interItemSpacing
        
        return heightOfPreviousItems+heightOfPreviousInterItemOffsets
    }
    
    private func resetScrollView() {
        scrollView.subviews.forEach({ $0.removeFromSuperview() })
        dotViews = []
    }
    
    private func updateItemsState(forSelectedIndex selectedIndex: Int, animated: Bool) {
        for (index, item) in dotViews.enumerated() {
            let selectionState = calculateState(forItemAtIndex: index,
                                                selectedIndex: selectedIndex)
            item.updateSelectionState(to: selectionState, animated: animated)
        }
    }
    
    private func scrollToItem(atIndex index: Int) {
        switch currentScrollDirection {
        case .down:
            let headingOffset = 1
            let headingIndex = index+headingOffset
            if headingIndex < numberOfPages && index > headingOffset {
                let rect = frameForItem(atIndex: headingIndex)
                scrollView.scrollRectToVisible(rect, animated: true)
            }
        case .up:
            let headingOffset = 1
            let headingIndex = index-headingOffset
            let rect = frameForItem(atIndex: headingIndex)
            scrollView.scrollRectToVisible(rect, animated: true)
        }

    }
    
    private func calculateState(forItemAtIndex index: Int,
                                selectedIndex: Int) -> PageItemDotView.SelectionState {
        guard index != selectedIndex else {
            return .selected
        }
        
        let indexCalculator = ScrollingPageControlIndexCalculator(smallIndexOffset: 1,
                                                                  tinyIndexOffset: 2,
                                                                  selectedIndex: selectedIndex,
                                                                  currentScrollDirection: currentScrollDirection,
                                                                  directionChangeSourcePage: directionChangeSourcePage,
                                                                  adjacentIndexThreshold: adjacentIndexThreshold)
        
        if indexCalculator.adjacentIndexes.contains(index) {
            return .adjacent
        } else if indexCalculator.smallIndexes.contains(index) {
            return .small
        } else if indexCalculator.tinyIndexes.contains(index) {
            return .tiny
        }

        return .hidden
    }
    
}

private final class PageItemDotView: UIView {
    
    enum SelectionState {
        case selected, adjacent, small, tiny, hidden
    }
    
    private enum Layout {
        static let shadowBlurSize: CGFloat = 2.0
    }
    
    private let animationDuration: Double = 0.13
    
    private var selectionState: SelectionState
    private let deselectedColor: UIColor
    
    private var fillColor: UIColor {
        switch selectionState {
        case .selected:
            return tintColor
        case .adjacent, .small, .tiny, .hidden:
            return deselectedColor
        }
    }
    
    private var stateAlpha: CGFloat {
        switch selectionState {
        case .adjacent, .selected, .small, .tiny:
            return 1
        case .hidden:
            return 0
        }
    }
    
    private var stateTransform: CATransform3D {
        switch selectionState {
        case .adjacent, .selected:
            return CATransform3DIdentity
        case .small:
            return CATransform3DScale(CATransform3DIdentity, 0.8, 0.8, 1.0)
        case .tiny:
            return CATransform3DScale(CATransform3DIdentity, 0.4, 0.4, 1.0)
        case .hidden:
            return CATransform3DScale(CATransform3DIdentity, 0.4, 0.4, 1.0)
        }
    }
    
    init(withColor color: UIColor,
         deselectedColor: UIColor,
         frame: CGRect) {
        self.deselectedColor = deselectedColor
        selectionState = .adjacent
        super.init(frame: frame)
        self.tintColor = color
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        
        drawDot(in: rect.insetBy(dx: Layout.shadowBlurSize,
                                 dy: Layout.shadowBlurSize),
                withContext: ctx)
    }
    
    private func drawDot(in rect: CGRect,
                         withContext ctx: CGContext) {
        let path = UIBezierPath(ovalIn: rect)
        ctx.addPath(path.cgPath)
        ctx.setFillColor(fillColor.cgColor)
        ctx.setShadow(offset: CGSize.zero,
                      blur: Layout.shadowBlurSize,
                      color: UIColor.black.withAlphaComponent(0.5).cgColor)
        ctx.fillPath()
    }
    
    func updateSelectionState(to state: PageItemDotView.SelectionState,
                              animated: Bool) {
        selectionState = state

        UIView.animate(withDuration: animated ? animationDuration : 0) {
            self.alpha = self.stateAlpha
            self.updateTransform()
            self.setNeedsDisplay()
        }
    }
    
    private func updateTransform() {
        layer.transform = stateTransform
    }
}
