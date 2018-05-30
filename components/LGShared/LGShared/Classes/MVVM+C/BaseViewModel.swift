public class BaseViewModel {

    private var activeFirstTime = true
    var active: Bool = false {
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

    public init() {
    }
    
    func didSetActive(_ active: Bool) {
        
    }

    func didBecomeActive(_ firstTime: Bool) {

    }

    func didBecomeInactive() {

    }

    /*
     Called on standard back button press. Return false for native behavior or true if handled back internally
     Defaults to false
     */
    func backButtonPressed() -> Bool {
        return false
    }
}
