import Foundation
import LGCoreKit

struct ListingCardMediaCarousel {
    let media: [Media]
    let current: Int

    func makeNext() -> ListingCardMediaCarousel {
        return ListingCardMediaCarousel(media: media, current: (current + 1) % media.count)
    }

    func makePrevious() -> ListingCardMediaCarousel {
        let next = (current - 1) < 0 ? media.count - 1 : current - 1
        return ListingCardMediaCarousel(media: media, current: next % media.count)
    }

}
