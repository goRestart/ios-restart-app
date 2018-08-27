protocol BumpUpNavigator: class {
    func bumpUpDidCancel()
    func bumpUpDidFinish(completion: (() -> Void)?)
}
