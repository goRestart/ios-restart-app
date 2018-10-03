import Foundation
import LGCoreKit

struct ListingCardMediaCarousel {
    let media: [Media]
    let currentIndex: Int

    func makeNext() -> ListingCardMediaCarousel {
        return ListingCardMediaCarousel(media: media, currentIndex: (currentIndex + 1) % media.count)
    }

    func makePrevious() -> ListingCardMediaCarousel {
        let next = (currentIndex - 1) < 0 ? media.count - 1 : currentIndex - 1
        return ListingCardMediaCarousel(media: media, currentIndex: next % media.count)
    }

}
