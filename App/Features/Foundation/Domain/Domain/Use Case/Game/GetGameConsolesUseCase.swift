import RxSwift

public protocol GetGameConsolesUseCase {
  func execute() -> Single<[GameConsole]>
}
