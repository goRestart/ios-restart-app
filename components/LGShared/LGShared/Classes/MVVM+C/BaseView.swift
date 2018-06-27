import UIKit

open class BaseView: UIView {

    private var viewModel: BaseViewModel

    public var active: Bool = false {
        didSet {
            if oldValue != active {
                viewModel.active = active

                if active {
                    didBecomeActive(activeFirstTime)
                    activeFirstTime = false
                } else {
                    didBecomeInactive()
                }
            }
        }
    }
    private var activeFirstTime = true

    public var isSafeAreaAvailable: Bool {
        if #available(iOS 11.0, *) {
            return true
        }
        return false
    }
    
    // MARK: - Lifecycle
    
    public init(viewModel: BaseViewModel, frame: CGRect) {
        self.viewModel = viewModel
        super.init(frame: frame)
    }

    public init?(viewModel: BaseViewModel, coder aDecoder: NSCoder) {
        self.viewModel = viewModel
        super.init(coder: aDecoder)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func switchViewModel(_ viewModel: BaseViewModel) {
        self.viewModel.active = false
        self.viewModel = viewModel
        self.viewModel.active = self.active
    }

    // MARK: - Internal methods
    
    open func didBecomeActive(_ firstTime: Bool) {
        
    }

    open func didBecomeInactive() {

    }


    // MARK: - Helper methods

    public func loadNibNamed(_ nibName: String, contentView: () -> UIView?) {
        Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        guard let view = contentView() else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(view)
    }
}
