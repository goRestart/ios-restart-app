protocol DeckMoreInfoView {
    func setupWith(title: String, price: String)
}
typealias MoreInfoViewType = DeckMoreInfoView & UIView
