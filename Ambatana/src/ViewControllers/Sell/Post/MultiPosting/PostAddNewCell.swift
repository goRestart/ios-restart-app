import LGComponents

final class PostAddNewCell: UITableViewCell, ReusableCell {

    var title: String? = nil {
        didSet {
            textLabel?.text = title
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        textLabel?.font = UIFont.postingFlowSelectableItem
        textLabel?.textColor = .white
        imageView?.image = R.Asset.IconsButtons.icCirlePlus.image.withRenderingMode(.alwaysTemplate)
        imageView?.tintColor = .white
        imageView?.contentMode = .left
    }
}
