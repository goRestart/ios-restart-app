import LGComponents
import RxSwift
import RxCocoa

struct AffiliationModalData {
    let icon: UIImage
    let headline: String
    let subheadline: String
    let primary: UIAction
    let secondary: UIAction?
}

final class AffiliationModalViewModel: BaseViewModel {

    fileprivate let data: AffiliationModalData

    init(data: AffiliationModalData) {
        self.data = data
        super.init()
    }

}

extension AffiliationModalViewModel: ReactiveCompatible {}
extension Reactive where Base: AffiliationModalViewModel {
    var data: Observable<AffiliationModalData> { return .just(base.data) }
}
