protocol FeedRenderable: class {
    func updateFeed()
}

protocol WaterFallScrollable: class {
    func didScroll(_ scrollView: UIScrollView)
}

protocol FeedViewModelDelegate: class {
    func vmDidUpdateState(_ vm: FeedViewModel, state: ViewState)
}
