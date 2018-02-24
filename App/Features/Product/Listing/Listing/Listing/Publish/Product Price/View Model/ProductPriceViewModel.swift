import RxSwift
import Domain

struct ProductPriceViewModel: ProductPriceViewModelType, ProductPriceViewModelInput, ProductPriceViewModelOutput {

  var input: ProductPriceViewModelInput { return self }
  var output: ProductPriceViewModelOutput { return self }

  // MARK: - Output

  var description: BehaviorSubject<String>
  var nextStepEnabled: Observable<Bool> {
    return description.map { !$0.trimmed.isEmpty }
  }

  // MARK: - Input

  func onNextStepPressed() {
    print("Publish product next step")
  }
}
