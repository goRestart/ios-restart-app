import Foundation
import LGComponents
import RxSwift

final class LPMessageViewModel: BaseViewModel {

    weak var navigator: LPMessageNavigator?

    let type: LPMessageType
    let action: UIAction
    
    let headline: Variable<String>
    let subHeadline: Variable<String>
    let image: Variable<UIImage>
    let actionString: Variable<String>

    let shouldDismissTappingBackground: Bool

    init(type: LPMessageType, action: UIAction, headline: String, subHeadline: String, image: UIImage) {
        self.type = type
        self.action = action
        self.headline = Variable<String>(headline)
        self.subHeadline = Variable<String>(subHeadline)
        self.image = Variable<UIImage>(image)
        self.actionString = Variable<String>(action.text ?? "")

        self.shouldDismissTappingBackground = (type == .centerPopup)
    }

    @objc func close() {
        navigator?.closeLPMessage()
    }

}
