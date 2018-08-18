import RxSwift

extension ObservableType {
  public func asCompletable() -> Completable {
    return ignoreElements()
  }
}

extension PrimitiveSequence where Trait == SingleTrait {
  public func asCompletable() -> Completable {
    return asObservable().asCompletable()
  }
}

extension PrimitiveSequence where Trait == MaybeTrait {
  public func asCompletable() -> Completable {
    return asObservable().asCompletable()
  }
}
