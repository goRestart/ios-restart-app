typealias TourPostingAction = (TourPosting) -> ()
struct TourPosting {
    let posting: Bool
    let source: PostingSource?
}

final class TourPostingWireframe: TourPostingNavigator {
    private weak var nc: UINavigationController?
    private let action: TourPostingAction

    init(nc: UINavigationController, action: @escaping TourPostingAction) {
        self.nc = nc
        self.action = action
    }

    func tourPostingClose() {
        action(TourPosting(posting: false, source: nil))
    }

    func tourPostingPost(fromCamera: Bool) {
        action(TourPosting(posting: true, source: fromCamera ? .onboardingCamera : .onboardingButton))
    }
}
