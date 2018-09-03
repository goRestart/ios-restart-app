protocol TourLoginNavigator: class {
    func tourLoginFinish()
}

protocol TourNotificationsNavigator {
    func tourNotificationsFinish()
    func showTourLocation()
    func closeTour()
}

protocol TourLocationNavigator: class {
    func tourLocationFinish()
}

protocol TourPostingNavigator: class {
    func tourPostingClose()
    func tourPostingPost(fromCamera: Bool)
}
