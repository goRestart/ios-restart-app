import LGComponents

extension DeviceFamily {
    func shouldShow3Columns() -> Bool {
        return isWiderOrEqualThan(.iPhone6Plus)
    }
}
