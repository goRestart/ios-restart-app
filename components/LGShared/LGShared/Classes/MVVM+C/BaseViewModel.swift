open class BaseViewModel {

    private var activeFirstTime = true
    open var active: Bool = false {
        didSet {
            if oldValue != active {
                didSetActive(active)
                if active {
                    didBecomeActive(activeFirstTime)
                    activeFirstTime = false
                } else {
                    didBecomeInactive()
                }
            }
        }
    }
    
    public init() {}
    
    // MARK: - Internal methods
    
    open func didSetActive(_ active: Bool) {
        
    }

    open func didBecomeActive(_ firstTime: Bool) {

    }

    open func didBecomeInactive() {

    }

    /*
     Called on standard back button press. Return false for native behavior or true if handled back internally
     Defaults to false
     */
    open func backButtonPressed() -> Bool {
        return false
    }
}
