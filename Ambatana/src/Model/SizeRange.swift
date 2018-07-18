
struct SizeRange: Equatable {
    let min: Int?
    let max: Int?
}

func ==(lhs: SizeRange, rhs: SizeRange) -> Bool {
    return lhs.min == rhs.min && lhs.max == rhs.max
}
