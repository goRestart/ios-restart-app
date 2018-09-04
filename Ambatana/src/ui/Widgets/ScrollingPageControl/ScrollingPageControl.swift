
import CoreGraphics

final class ScrollingPageControl: UIView {
    
    private struct Layout {
        static let scrollViewWidth: CGFloat = 10.0
        static let itemSize: CGSize = CGSize(width: 10.0, height: 10.0)
        static let interItemSpacing: CGFloat = 7.0
    }
    
    private enum Direction {
        case up, down
    }
    
    private(set) var numberOfPages: Int = 0
    private var currentPage: Int = 0
    private let adjacentIndexThreshold: Int = 2
    
    private var itemColor: UIColor
    
    private var dotViews: [PageItemDotView] = []
    
    var displayCurrentPage: Int {
        return currentPage + 1
    }
    
    private var previouslySelectedPage: Int = 0
    
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
    
    required init(itemColor: UIColor) {
        self.itemColor = itemColor

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
    
    func updateCurrentPage(to nextPage: Int) {
        previouslySelectedPage = currentPage
        self.currentPage = nextPage
        updateItemsState(forSelectedIndex: currentPage)

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
                                           frame: itemRect)
            scrollView.addSubview(itemView)
            dotViews.append(itemView)
        }
        
        updateItemsState(forSelectedIndex: currentPage)
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
    
    private func updateItemsState(forSelectedIndex selectedIndex: Int) {
        for (index, item) in dotViews.enumerated() {
            let selectionState = calculateState(forItemAtIndex: index,
                                                selectedIndex: selectedIndex)
            item.updateSelectionState(to: selectionState)
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
            let headingOffset = 2
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
        
        switch currentScrollDirection {
        case .down:
            if (index >= selectedIndex-adjacentIndexThreshold && index < selectedIndex) ||
                (selectedIndex <= adjacentIndexThreshold && index <= adjacentIndexThreshold) {
                return .adjacent
            } else if (index == selectedIndex-(adjacentIndexThreshold+1))
                || (index == selectedIndex+1)
                || (selectedIndex <= adjacentIndexThreshold && index == (adjacentIndexThreshold+1)) {
                return .small
            } else if (index == selectedIndex-(adjacentIndexThreshold+2))
                || (index == selectedIndex+2)
                || (selectedIndex <= adjacentIndexThreshold && index == (adjacentIndexThreshold+2)) {
                return .tiny
            }
        case .up:
            let adjacentEndThreshold = (numberOfPages-1)-(adjacentIndexThreshold)
            if (index <= selectedIndex+adjacentIndexThreshold && index > selectedIndex) ||
                (selectedIndex >= adjacentEndThreshold && index >= adjacentEndThreshold) {
                return .adjacent
            } else if (index == selectedIndex+(adjacentIndexThreshold+1))
                || (index == selectedIndex-1)
                || (selectedIndex >= adjacentEndThreshold && index == (adjacentEndThreshold-1)) {
                return .small
            } else if (index == selectedIndex+(adjacentIndexThreshold+2))
                || (index == selectedIndex-2)
                || (selectedIndex >= adjacentEndThreshold
                    && index == (adjacentEndThreshold-2)) {
                return .tiny
            }
        }

        return .hidden
    }
    
}

private final class PageItemDotView: UIView {
    
    enum SelectionState {
        case selected, adjacent, small, tiny, hidden
    }
    
    private struct Layout {
        static let smallSelectionInset: CGFloat = 2
        static let tinySelectionInset: CGFloat = 4
    }
    
    private var selectionState: SelectionState
    
    private var fillColor: UIColor {
        switch selectionState {
        case .selected:
            return tintColor
        case .adjacent, .small, .tiny:
            return tintColor.withAlphaComponent(0.5)
        case .hidden:
            return .clear
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
            return CATransform3DScale(CATransform3DIdentity, 0.0, 0.0, 1.0)
        }
    }
    
    init(withColor color: UIColor,
         frame: CGRect) {
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
        
        drawDot(in: rect, withContext: ctx)
    }
    
    private func drawDot(in rect: CGRect,
                         withContext ctx: CGContext) {
        let path = UIBezierPath(ovalIn: rect)
        ctx.addPath(path.cgPath)
        ctx.setFillColor(fillColor.cgColor)
        ctx.fillPath()
    }
    
    func updateSelectionState(to state: PageItemDotView.SelectionState) {
        selectionState = state
        
        UIView.animate(withDuration: 0.13) {
            self.updateTransform()
            self.setNeedsDisplay()
        }
    }
    
    private func updateTransform() {
        layer.transform = stateTransform
    }
}
