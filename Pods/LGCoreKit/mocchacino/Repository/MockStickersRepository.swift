import Result
import RxSwift

open class MockStickersRepository: StickersRepository {
    public var stickersVar = Variable<[Sticker]>([])
    public var showResult: StickersResult!


    // MARK: - Lifecycle

    required public init() {
    
    }


    // MARK: - StickersRepository {

    public var stickers: Observable<[Sticker]> {
        return stickersVar.asObservable()
    }

    public func show(_ completion: StickersCompletion?) {
        delay(result: showResult, completion: completion)
    }

    public func show(typeFilter filter: StickerType?, completion: StickersCompletion?) {
        delay(result: showResult, completion: completion)
    }

    public func sticker(_ id: String) -> Sticker? {
        return stickersVar.value.filter { id == $0.name }.first
    }
}
