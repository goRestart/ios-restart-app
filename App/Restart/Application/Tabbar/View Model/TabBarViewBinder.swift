import RxSwift
import RxCocoa
import UI

struct TabBarViewBinder {
  func bind(view: TabBarController, to viewModel: TabBarViewModelType, using bag: DisposeBag) {

    view.rx.didSelect
      .debounce(0.1, scheduler: MainScheduler.instance)
      .map { $0.tabBarItem }
      .subscribe(onNext: { item in
        switch item?.tag {
        case MenuItem.publish.rawValue:
          viewModel.input.didTapAddProduct()
        default: break
        }
    }).disposed(by: bag)
  }
}
