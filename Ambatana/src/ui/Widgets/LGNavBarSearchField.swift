import UIKit
import LGComponents

final class LGNavBarSearchField: UIView {
    
    private let containerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = LGNavBarMetrics.Container.backgroundColor
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.isUserInteractionEnabled = false
        return stackView
    }()
    
    private let magnifierIcon: UIImageView = {
        let logo = UIImageView()
        logo.contentMode = .scaleAspectFit
        logo.isUserInteractionEnabled = false
        return logo
    }()
    
    private let logoIcon: UIImageView = {
        let logo = UIImageView(image: #imageLiteral(resourceName: "navbar_logo"))
        logo.contentMode = .scaleAspectFit
        logo.isUserInteractionEnabled = false
        return logo
    }()
    
    private let searchTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
        label.text = R.Strings.searchLetgo
        label.textColor = LGNavBarMetrics.Searchfield.placeHolderTextColor
        return label
    }()
    
    let searchTextField: LGTextField = {
        let searchTextField = LGTextField()
        searchTextField.clipsToBounds = true
        searchTextField.font = LGNavBarMetrics.Searchfield.font
        searchTextField.textColor = LGNavBarMetrics.Searchfield.textColor
        searchTextField.clearButtonMode = .always
        searchTextField.clearButtonOffset = LGNavBarMetrics.Searchfield.clearButtonOffset
        searchTextField.insetX = LGNavBarMetrics.Searchfield.insetX
        return searchTextField
    }()
    
    enum State: Equatable {
        case beginEdit, completeEdit(text: String), cancelEdit
        
        static func ==(lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.beginEdit, .beginEdit): return true
            case (.cancelEdit, .cancelEdit): return true
            case let (.completeEdit(l), .completeEdit(r)): return l == r
            case (.beginEdit, _), (.completeEdit, _), (.cancelEdit, _ ): return false
            }
        }
    }

    private let boxSize: SearchBoxSize
    private let searchFieldStyle: SearchFieldStyle
    
    private var stackCenterConstraint: NSLayoutConstraint?
    private var stackLeftConstraint: NSLayoutConstraint?
    private var stackYConstraint: NSLayoutConstraint?
    
    private var state: State { didSet { renderStatefulUI() } }
    
    init(_ text: String?,
         searchBoxSize: SearchBoxSize,
         searchFieldStyle: SearchFieldStyle) {
        self.boxSize = searchBoxSize
        self.searchFieldStyle = searchFieldStyle
        if let text = text {
            self.state = .completeEdit(text: text)
        } else {
            self.state = .cancelEdit
        }
        super.init(frame: CGRect(origin: .zero, size: LGNavBarMetrics.Size.navBarSize))
        setupViews()
        setupConstraints()
        setupUI()
        renderStatefulUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize { return UILayoutFittingExpandedSize }

    
    // MARK: - Public Methods
    
    func beginEdit() {
        state = .beginEdit
    }
    
    func cancelEdit() {
        state = .cancelEdit
    }
    
    
    // MARK: - Private Methods

    private func setupViews() {
        addSubviewForAutoLayout(containerView)
        stackView.addArrangedSubview(magnifierIcon)
        stackView.addArrangedSubview(logoIcon)
        stackView.addArrangedSubview(searchTextLabel)
        containerView.addSubviewsForAutoLayout([searchTextField, stackView])
        searchTextField.addTarget(self,
                                  action: #selector(textFieldDidChange(_:)),
                                  for: UIControlEvents.editingChanged)
    }
    
    private func setupConstraints() {
        containerView.layout(with: self).fillHorizontal().centerY()
        containerView.layout().height(boxSize.boxHeight)
        
        searchTextField.layout(with: containerView).fill()
        magnifierIcon.layout()
            .width(LGNavBarMetrics.Magnifier.width)
            .height(LGNavBarMetrics.Magnifier.height)

        logoIcon.layout().height(LGNavBarMetrics.Logo.height)
        
        stackYConstraint = stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: yOffset)
        stackYConstraint?.isActive = true
        stackCenterConstraint = stackView.centerXAnchor.constraint(equalTo: searchTextField.centerXAnchor)
        stackLeftConstraint = stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.shortMargin)
    }
    
    private func setupUI() {
        containerView.cornerRadius = containerCornerRadius
        magnifierIcon.image = searchFieldStyle.magnifierImage
        logoIcon.isHidden = searchFieldStyle.shouldHideLetgoIcon
        searchTextLabel.isHidden = shouldHideGreySearchLabel
        stackView.spacing = searchFieldStyle.imageTextSpacing
    }
    
    private func renderStatefulUI() {
        switch state {
        case .beginEdit:
            setupTextFieldEditMode()
        case .completeEdit(let text):
            searchTextField.text = text
            searchTextLabel.isHidden = shouldHideGreySearchLabel
            text.isEmpty ? setupTextFieldCleanMode() : setupTextFieldEditMode()
            searchTextField.resignFirstResponder()
        case .cancelEdit:
            searchTextField.text = nil
            searchTextLabel.isHidden = shouldHideGreySearchLabel
            searchTextField.resignFirstResponder()
            setupTextFieldCleanMode()
        }
        stackView.alignment = stackAlignment
    }
    
    private var stackAlignment: UIStackViewAlignment {
        
        if let queryText = searchTextField.text,
            !queryText.isEmpty {
            return .center
        }
        
        switch (searchFieldStyle, state) {
            case (.grey, _), (_, .beginEdit): return .center
            default: return .top
        }
    }
    
    private var shouldHideGreySearchLabel: Bool {
        switch searchFieldStyle {
        case .letgoRed: return true
        case .grey: return searchTextField.text?.isEmpty == false
        }
    }

    private var yOffset: CGFloat {
        return searchFieldStyle.shouldHideLetgoIcon ?
            0 : LGNavBarMetrics.StackView.verticalDiference
    }
    
    private var containerCornerRadius: CGFloat {
        switch (searchFieldStyle, boxSize) {
        case (.grey, _): return 10
        case (.letgoRed, .normal): return LGNavBarMetrics.Container.height / 2.0
        case (.letgoRed, .large): return LGNavBarMetrics.Container.largeHeight / 2.0
        }
    }
    
    private func setupTextFieldEditMode() {
        logosLeft()
        stackYConstraint?.constant = 0
        logoIcon.animateTo(alpha: 0) { [weak self] finished in
            if finished {
                self?.searchTextField.showCursor = true
            }
        }
    }
    
    private func setupTextFieldCleanMode() {
        logosCentered()
        stackYConstraint?.constant = yOffset
        logoIcon.animateTo(alpha: 1) { [weak self] finished in
            if finished {
                self?.searchTextField.showCursor = false
            }
        }
    }
        
    private func logosCentered() {
        stackCenterConstraint?.isActive = true
        stackLeftConstraint?.isActive = false
    }
    
    private func logosLeft() {
        stackCenterConstraint?.isActive = false
        stackLeftConstraint?.isActive = true
    }
    
    
    // MARK: - TextField Actions
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        searchTextLabel.isHidden = shouldHideGreySearchLabel
    }
}
