final class DeckViewCollectionDelegate: NSObject, ListingCardViewDelegate, ListingDeckCollectionViewLayoutDelegate {
    private let viewModel: ListingDeckViewModel
    private let listingDeckView: ListingDeckView
    var lastPageBeforeDragging: Int = 0

    init(viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView) {
        self.viewModel = viewModel
        self.listingDeckView = listingDeckView
    }

    func targetPage(forProposedPage proposedPage: Int,
                    withScrollingDirection direction: ScrollingDirection) -> Int {
        guard direction != .none else {
            return proposedPage
        }
        return min(max(0, lastPageBeforeDragging + direction.delta), max(viewModel.objectCount - 1, 0))
    }

    private func currentPageCell() -> ListingCardView? {
        return listingDeckView.cardAtIndex(viewModel.currentIndex)
    }

    func cardViewDidTapOnMoreInfo(_ cardView: ListingCardView) {
        viewModel.showListingDetail(at: cardView.tag)
    }
}
