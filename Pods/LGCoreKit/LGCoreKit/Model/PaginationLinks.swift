
public protocol PaginationLinks {
    var this: URL { get }
    var previous: URL? { get }
    var next: URL? { get }
}
