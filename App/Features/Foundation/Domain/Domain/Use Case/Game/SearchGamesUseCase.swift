import RxSwift

public protocol SearchGamesConsolesUseCase {
  func execute() -> Single<[Game]>
}
