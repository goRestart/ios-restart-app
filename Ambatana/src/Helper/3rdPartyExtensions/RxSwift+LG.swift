import RxSwift

extension Array where Element: Disposable {
    func dispose(by bag: DisposeBag) {
        forEach { $0.disposed(by: bag) }
    }
}
