import RxSwift
import RxCocoa

final class AffiliationVouchersDataSource: NSObject, UITableViewDataSource {
    let resendRelay = PublishRelay<Int>()
    private let disposeBag = DisposeBag()

    var vouchers: [VoucherCellData] = []

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vouchers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeue(type: AffiliationVoucherCell.self,
                                           for: indexPath) else { return UITableViewCell() }
        guard let data = vouchers[safeAt: indexPath.row] else { return UITableViewCell() }
        cell.populate(with: data)
        cell.tag = indexPath.row
        cell.rx.resendTap
            .bind { [weak self] in self?.resendRelay.accept(cell.tag) }
            .disposed(by: cell.disposeBag)
        return cell
    }
}
