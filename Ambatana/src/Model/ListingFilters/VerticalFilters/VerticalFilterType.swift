
protocol VerticalFilterType {
    var hasAnyAttributesSet: Bool { get }
    func createTrackingParams() -> [(EventParameterName, Any?)]
    static func create() -> Self
}

extension VerticalFilterType {
    
    func checkIfAnyAttributesAreSet(forAttributes attributes: [Any?],
                                    initialValue: Bool = false) -> Bool {
        return attributes.compactMap({ $0 }).reduce(initialValue, { (res, next) -> Bool in
            guard let nextArray = next as? [Any] else { return true }
            return !nextArray.isEmpty ? true : res
        })
    }
}
