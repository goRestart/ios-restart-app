import RxSwift
import RxCocoa

extension Reactive where Base: FullWidthButton {
  public var isLoading: Binder<Bool> {
    return Binder(self.base) { button, isLoading in
      button.isLoading = isLoading
    }
  }
}
