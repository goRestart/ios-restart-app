final class FeedDetailedListingCell: FeedListingCell {
    
    private let feedDetailView = FeedDetailView()
    
    override func setupUI() {
        super.setupUI()
        contentView.addSubviewsForAutoLayout([feedDetailView])
        feedDetailView.feedDetailViewDelegate = self
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        feedDetailView.layout(with: contentView)
            .fillHorizontal()
            .bottom()
        feedDetailView.layout(with: thumbnailImageView).below()
    }
    
    override func setupFeedListingData(_ data: FeedListingData) {
        super.setupFeedListingData(data)
        feedDetailView.setupTitleAndPrice(with: data.title,
                                          price: data.price,
                                          priceType: data.priceType)
    }
    
    func setupFeedDetailButton(_ data: FeedListingData, buttonHeight: CGFloat) {
        feedDetailView.setupButton(data.isMine,
                                   buttonHeight: buttonHeight,
                                   buttonTitle: data.chatNowTitle)
    }

    override func resetUI() {
        super.resetUI()
        feedDetailView.resetUI()
    }
}

extension FeedDetailedListingCell: FeedDetailViewDelegate {
    func openChat() {
        guard let listing = feedListingData?.listing else { return }
        delegate?.chatButtonPressedFor(listing: listing)
    }
}
