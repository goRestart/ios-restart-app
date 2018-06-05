import LGComponents

protocol MLPredictionDetailsViewCellDelegate: class {
    func didEdit(newValue: String)
}

class MLPredictionDetailsViewCell: UITableViewCell, ReusableCell {
    weak var delegate: MLPredictionDetailsViewCellDelegate?
    let label = UILabel()
    let textView = UITextView()
    
    // MARK: - Lifecycle
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        resetUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        clipsToBounds = true
        backgroundColor = .clear
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.font = UIFont.systemBoldFont(size: 23)
        label.numberOfLines = 2
        addShadow(toView: label)
        contentView.addSubviewForAutoLayout(label)
        label.layout(with: contentView).top().bottom().left(by: Metrics.margin)
        
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        let image: UIImage = R.Asset.Machinelearning.mlIconChevron.image
        accessoryView = UIImageView(image: image)

        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.textColor = .white
        textView.font = UIFont.systemBoldFont(size: 23)
        textView.textAlignment = .right
        textView.backgroundColor = .clear
        addShadow(toView: textView)
        contentView.addSubviewForAutoLayout(textView)
        textView.layout(with: contentView)
            .top(by: 4, relatedBy: .lessThanOrEqual, priority: UILayoutPriority.fittingSizeLevel)
            .bottom(by: -4, relatedBy: .greaterThanOrEqual, priority: UILayoutPriority.fittingSizeLevel)
            .right(by: -20)
            .centerY()
        
        label.layout(with: textView).right(to: .left, by: -Metrics.margin)
    }
    
    private func resetUI() {
        textLabel?.text = nil
        textView.text = nil
    }
    
    private func addShadow(toView view: UIView, radius: Double = 1) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 0.5
        view.layer.shadowOpacity = 1.0
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.masksToBounds = false
    }
    
    func setTextView(text: String) {
        textView.text = text
        textView.centerVertically()
    }

}

private extension UITextView {
    
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
    
}
