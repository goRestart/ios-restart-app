protocol FeedRenderable: class {
    func updateFeed(forceLayoutCalculation: Bool)
    func reloadFeed()
    func convertViewRectInFeed(from originalFrame: CGRect) -> CGRect
}

protocol WaterFallScrollable: class {
    func didScroll(_ scrollView: UIScrollView)
    func willScroll(toSection section: Int)
}

protocol FeedViewModelDelegate: class {
    func vmDidUpdateState(_ vm: FeedViewModel, state: ViewState)
    func searchCompleted()
}
