import Foundation
import LGCoreKit

public enum Cache<T> {
    case data(T)
    case empty
}

protocol ListingListCache {
    func fetch(then completion: @escaping (Cache<[Listing]>)->())
}

final class PrivateListCache: ListingListCache {
    func fetch(then completion: @escaping (Cache<[Listing]>) -> ()) {
        DispatchQueue.main.async {
            completion(.empty)
        }
    }
}

final class PublicListCache: ListingListCache {
    private let disk: Disk

    init(disk: Disk) {
        self.disk = disk
    }

    func fetch(then completion: @escaping (Cache<[Listing]>) -> ()) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            do {
                guard let strSelf = self else {
                    completion(.empty)
                    return
                }
                let listings = try strSelf.disk.retrieve(.feed, from: .caches, as: [Listing].self)
                DispatchQueue.main.async {
                    completion(Cache<[Listing]>.data(listings))
                }
            } catch _ {
                completion(.empty)
            }
        }
    }
}
