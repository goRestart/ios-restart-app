import IGListKit

protocol PushPermissionsPresenterDelegate: class {
    func showPushPermissionsAlert(withPositiveAction positiveAction: @escaping (() -> Void), negativeAction: @escaping (() -> Void))
}

final class PushMessageSectionController: ListSectionController {
    
    private let pushPermissionTracker: PushPermissionsTracker
    weak var delegate: PushPermissionsPresenterDelegate?
    
    init(pushPermissionTracker: PushPermissionsTracker) {
        self.pushPermissionTracker = pushPermissionTracker
        super.init()
        inset = .zero
    }
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let height = PushPermissionsCollectionCell.viewHeight
        let width = collectionContext?.containerSize.width ?? 0
        return CGSize(width: width, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: PushPermissionsCollectionCell.self,
                                                                for: self,
                                                                at: index) as? PushPermissionsCollectionCell
            else { fatalError("Cannot dequeue PushPermissionsCollectionCell in PushMessageSectionController") }
        return cell
    }
    
    override func didSelectItem(at index: Int) {
        pushPermissionHeaderPressed()
    }
    
    private func pushPermissionHeaderPressed() {
        pushPermissionTracker.trackPushPermissionStart()
        delegate?.showPushPermissionsAlert(withPositiveAction: { [weak self] in
            self?.pushPermissionTracker.trackPushPermissionComplete()
            }, negativeAction: { [weak self] in
                self?.pushPermissionTracker.trackPushPermissionCancel()
        })
    }
}

