import RxSwift
import RxCocoa

extension Reactive where Base: UIButton {
  public var buttonWasTapped: Observable<Void> {
    return base.rx
      .controlEvent(.touchUpInside)
      .debounce(0.1, scheduler: MainScheduler.instance)
  }
}
