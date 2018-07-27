
protocol FeedPresenter {
    static var feedClass: AnyClass { get }
    static var reuseIdentifier: String { get }
    var height: CGFloat { get }
}

extension FeedPresenter {
    static var reuseIdentifier: String {
        return String(describing: feedClass.self)
    }
}

