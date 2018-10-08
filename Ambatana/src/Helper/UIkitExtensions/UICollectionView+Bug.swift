extension UICollectionView {
    static func isIOSBuggyVersion() -> Bool {
        /* This referece https://stackoverflow.com/questions/39867325/ios-10-bug-uicollectionview-received-layout-attributes-for-a-cell-with-an-index says that it's a iOS 10 UIKit related bug, we are having this issue from version 10.0.0 to 10.3.3 so this is a check for only those versions

         Fabric link: https://www.fabric.io/ambatana/ios/apps/com.letgo.ios/issues/5b3519386007d59fcd17c8c4
         */

        return ProcessInfo().isIOSVersionInRange(
            from: OperatingSystemVersion(majorVersion: 10, minorVersion: 0, patchVersion: 0),
            to: OperatingSystemVersion(majorVersion: 10, minorVersion: 3, patchVersion: 4)
        )
    }
}
