import LGComponents
import LGCoreKit
import RxSwift
import RxCocoa
import Result

struct VoucherCellData {
    let showResend: Bool
    let title: String
    let points: String
    let date: String
    let partnerIcon: UIImage
}

final class AffiliationVouchersViewModel: BaseViewModel {
    private let rewardsRepository: RewardRepository
    private let numberFormatter: NumberFormatter = {
        let ordinalFormatter = NumberFormatter()
        ordinalFormatter.numberStyle = .ordinal
        return ordinalFormatter
    }()

    private(set) var vouchers: [VoucherCellData] = []
    fileprivate let viewState = PublishRelay<ViewState>()

    convenience override init() {
        self.init(rewardsRepository: Core.rewardRepository)
    }

    init(rewardsRepository: RewardRepository) {
        self.rewardsRepository = rewardsRepository
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        if firstTime {
            retrieveVouchers()
        }
    }

    private func retrieveVouchers() {
        viewState.accept(.loading)
        rewardsRepository.indexVouchers { [weak self] (result) in
            self?.update(with: result)
        }
    }

    private func update(with result: Result<[Voucher], RepositoryError>) {
        if let error = result.error {
            viewState.accept(.error(makeEmpty()))
        } else if let vouchers = result.value, vouchers.count > 0 {
            let formatter = DateFormatter()
            self.vouchers = vouchers.map {
                return toVoucherCellData(voucher: $0, formatter: formatter)
            }
            viewState.accept(.data)
        }
    }

    fileprivate func makeEmpty() -> LGEmptyViewModel {
        return LGEmptyViewModel(icon: R.Asset.Affiliation.Error.errorOops.image,
                                title: R.Strings.affiliationStoreUnknownErrorMessage,
                                body: nil,
                                buttonTitle: R.Strings.commonErrorListRetryButton,
                                action: { [weak self] in self?.retrieveVouchers() },
                                secondaryButtonTitle: nil,
                                secondaryAction: nil,
                                emptyReason: nil,
                                errorCode: nil,
                                errorDescription: nil)
    }

    func toVoucherCellData(voucher: Voucher, formatter: DateFormatter) -> VoucherCellData {
        let day = Calendar.current.component(.day, from: voucher.createdAt)
        let dayOrdinal = numberFormatter.string(from: NSNumber(value: day))!
        formatter.dateFormat = "MMM '\(dayOrdinal)'"
        return VoucherCellData(
            showResend: !voucher.isLessThaOneDayOld,
            title: voucher.type.cardTitle,
            points: R.Strings.affiliationStorePoints("\(voucher.points)"),
            date: formatter.string(from: voucher.createdAt),
            partnerIcon: R.Asset.Affiliation.Partners.amazon.image
        )
    }
}

private extension Voucher  {
    var isLessThaOneDayOld: Bool { return createdAt.isFromLast24h() }
}

extension AffiliationVouchersViewModel: ReactiveCompatible {}
extension Reactive where Base: AffiliationVouchersViewModel {
    var state: Driver<ViewState> {
        return base.viewState.asObservable().asDriver(onErrorJustReturn: ViewState.error(base.makeEmpty()))
    }
}
