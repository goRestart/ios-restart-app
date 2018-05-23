import Foundation

protocol ReputationTooltipManager: class {
    func shouldShowTooltip() -> Bool
    func didShowTooltip()
}
