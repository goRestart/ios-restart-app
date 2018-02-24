import RxSwift
import Domain

struct ProductPriceViewModel: ProductPriceViewModelType, ProductPriceViewModelInput, ProductPriceViewModelOutput {

  var input: ProductPriceViewModelInput { return self }
  var output: ProductPriceViewModelOutput { return self }

  // MARK: - Output

  var description = BehaviorSubject<String>(value: "")
  var nextStepEnabled: Observable<Bool> {
    return description
      .map { $0.trimmed }
      .map { !$0.isEmpty && $0.isFloatable }
  }

  // MARK: - Input

  func onNextStepPressed() {
    print("Publish product next step")
  }
}
