import RxSwift

extension Array where Element: Disposable {
    func disposed(by bag: DisposeBag) {
        forEach { $0.disposed(by: bag) }
    }
}
