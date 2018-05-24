import Foundation
import LGCoreKit
import LGComponents

protocol MLPredictionDetailsViewDelegate: class {
    func didRequestCategorySelection()
}

struct MLPredictionDetailsViewData {
    var title: String?
    var price: Double?
    var category: ListingCategory?
    
    var predictedTitle: String?
    var predictedPrice: Double?
    var predictedCategory: ListingCategory?
    
    var isEmpty: Bool {
        return title == nil
    }
    
    var userChangedPredictedTitle: Bool {
        return title != predictedTitle
    }
    var userChangedPredictedPrice: Bool {
        return price != predictedPrice
    }
    var userChangedPredictedCategory: Bool {
        return category != predictedCategory
    }
    
    init(title: String?, price: Double?, category: ListingCategory?) {
        self.title = title
        self.predictedTitle = title
        self.price = price
        self.predictedPrice = price
        self.category = category
        self.predictedCategory = category
    }
}

private enum Cells: Int {
    case title = 0, price, category
}

class MLPredictionDetailsView: UIView, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    static let cellIdentifier = "MLPostingCameraViewDetailsViewCell"
    
    private let tableView = UITableView()
    var data = MLPredictionDetailsViewData(title: nil, price: nil, category: nil)
    private var shadowLayer: CALayer?
    private let backgroundShadow = UIView()
    
    private var tapGestureToDismissKeyboard: UITapGestureRecognizer?
    
    private var textViewTitle: UITextView?
    private var textViewPrice: UITextView?
    private var textViewCategory: UITextView?
    
    weak var delegate: MLPredictionDetailsViewDelegate?
    
    // MARK: - Lifecycle
    
    init() {
        super.init(frame: CGRect.zero)
        setupUI()
        setupLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupGradientView()
    }
    
    func setEmtpy() {
        data.title = nil
        data.price = nil
        data.category = nil
    }
    
    func set(data: MLPredictionDetailsViewData) {
        self.data = data
        tableView.reloadData()
    }
    
    func set(category: ListingCategory?) {
        self.data.category = category
        tableView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGradientView() {
        if let shadowLayer = shadowLayer {
            shadowLayer.removeFromSuperlayer()
        }
        shadowLayer = CAGradientLayer.gradientWithColor(UIColor.black, alphas:[0, 0.6], locations: [0, 1])
        if let shadowLayer = shadowLayer {
            shadowLayer.frame = backgroundShadow.bounds
            backgroundShadow.layer.insertSublayer(shadowLayer, at: 0)
        }
    }
    
    private func setupUI() {
        isUserInteractionEnabled = true
        tableView.register(MLPredictionDetailsViewCell.self, forCellReuseIdentifier: MLPredictionDetailsView.cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.backgroundColor = .clear
        tableView.tintColor = .white
        tableView.isScrollEnabled = false
        backgroundShadow.backgroundColor = .clear
    }
    
    private func setupLayout() {
        addSubviewsForAutoLayout([backgroundShadow, tableView])
        
        backgroundShadow.layout(with: self).fill()
        
        tableView.layout(with: self).bottom().left().right()
        tableView.layout().height(330)
        
        tapGestureToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(didTapToDissmissKeyboard))
        tapGestureToDismissKeyboard?.cancelsTouchesInView = false
    }
    
    // MARK: - UITableView delegate & datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MLPredictionDetailsView.cellIdentifier)
            as? MLPredictionDetailsViewCell else {
            return UITableViewCell()
        }
        switch indexPath.row {
        case Cells.title.rawValue:
            cell.textView.keyboardType = .alphabet
            cell.textView.returnKeyType = .done
            cell.textView.delegate = self
            cell.label.text = R.Strings.mlDetailsTitleText
            if let title = data.title {
                cell.setTextView(text: title)
            }
            textViewTitle = cell.textView
        case Cells.price.rawValue:
            cell.textView.keyboardType = .decimalPad
            cell.textView.returnKeyType = .done
            cell.textView.delegate = self
            cell.label.text = R.Strings.mlDetailsPriceText
            if let price = data.price {
                cell.setTextView(text: String(format: "%.f", price))
            }
            textViewPrice = cell.textView
        case Cells.category.rawValue:
            cell.textView.isUserInteractionEnabled = false
            cell.textView.isEditable = false
            cell.label.text = R.Strings.mlCategoryText
            if let category = data.category {
                cell.setTextView(text: category.name.capitalized)
            }
            textViewCategory = cell.textView
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case Cells.title.rawValue:
            textViewTitle?.becomeFirstResponder()
        case Cells.price.rawValue:
            textViewPrice?.becomeFirstResponder()
        case Cells.category.rawValue:
            endEditing(true)
            delegate?.didRequestCategorySelection()
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemBoldFont(size: 13)
        label.text = R.Strings.mlDetailsSuggestedDetailsText
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        addShadow(toView: label)
        view.addSubview(label)
        label.layout(with: view).top().bottom(by: -10).right().left(by: 18)
        return view
    }
    
    private func addShadow(toView view: UIView, radius: Double = 1) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 0.5
        view.layer.shadowOpacity = 1.0
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.masksToBounds = false
    }
    
    @objc func didTapToDissmissKeyboard() {
        endEditing(true)
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        DispatchQueue.main.async {
            let newPosition = textView.endOfDocument
            textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
        }
        if let tapGesture = tapGestureToDismissKeyboard {
            addGestureRecognizer(tapGesture)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let tapGesture = tapGestureToDismissKeyboard {
            removeGestureRecognizer(tapGesture)
        }
        if let price = textViewPrice?.text {
            data.price = Double(price)
        }
        data.title = textViewTitle?.text
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}
