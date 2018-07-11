public extension Array where Element == String {
    public var stringCommaSeparated: String? {
        guard !isEmpty else { return nil }
        return joined(separator: ",")
    }
}

public extension Array where Element == Int {
    public var stringCommaSeparated: String? {
        guard !isEmpty else { return nil }
        return compactMap { String($0) }.joined(separator: ",")
    }
}
