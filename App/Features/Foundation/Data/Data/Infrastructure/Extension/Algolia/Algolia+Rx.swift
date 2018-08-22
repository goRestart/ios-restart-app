import InstantSearchClient
import RxSwift

extension Reactive where Base: InstantSearchClient.Index  {
  func search<T>(with query: InstantSearchClient.Query) -> Single<T> {
    return Single.create(subscribe: { event in
      let search = self.base.search(query) { (result, error) in
        if let result = result,
          let hits = result["hits"] as? T {
          event(.success(hits))
        }
        if let error = error {
          event(.error(error))
        }
      }
       
      
      return Disposables.create {
        search.cancel()
      }
    })
  }
}
