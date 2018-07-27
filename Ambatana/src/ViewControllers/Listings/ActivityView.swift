final class ActivityView: UIView {
    private var leadingInset: NSLayoutConstraint?
    private var topInset: NSLayoutConstraint?
    private var trailingInset: NSLayoutConstraint?
    private var bottomInset: NSLayoutConstraint?
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        indicator.color = UIColor(red: 153, green: 153, blue: 153)
        return indicator
    }()
    
    convenience init() {
        self.init(frame: .zero)
        setupUI()
        activityIndicator.startAnimating()
    }
    
    func updateWithInsets(_ edgeInsets: UIEdgeInsets) {
        leadingInset?.constant = edgeInsets.left
        topInset?.constant = edgeInsets.top
        trailingInset?.constant = -edgeInsets.right
        bottomInset?.constant = -edgeInsets.bottom
    }
    
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0)
        setupConstraints()
    }
    
    private func setupAccessibilityIds() {
        set(accessibilityId: .listingListViewFirstLoadView)
        activityIndicator.set(accessibilityId: .listingListViewFirstLoadActivityIndicator)
    }
    
    private func setupConstraints() {
        addSubviewForAutoLayout(activityIndicator)
        let topInset = activityIndicator.topAnchor.constraint(equalTo: topAnchor)
        let leadingInset = activityIndicator.leadingAnchor.constraint(equalTo: leadingAnchor)
        let trailingInset = activityIndicator.trailingAnchor.constraint(equalTo: trailingAnchor)
        let bottomInset = activityIndicator.bottomAnchor.constraint(equalTo: bottomAnchor)
        NSLayoutConstraint.activate([ topInset, leadingInset, trailingInset, bottomInset ])
        self.topInset = topInset
        self.leadingInset = leadingInset
        self.trailingInset = trailingInset
        self.bottomInset = bottomInset
    }
}
