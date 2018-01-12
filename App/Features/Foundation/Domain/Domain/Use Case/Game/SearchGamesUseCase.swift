import RxSwift

public protocol SearchGamesUseCase {
  func execute(with query: String) -> Single<[Game]>
}
