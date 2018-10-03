extension UIAlertController {
    func add(_ actions: [UIAlertAction]) {
        actions.forEach { addAction($0) }
    }
}
