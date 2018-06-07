import Foundation
import MapKit
import LGComponents
import LGCoreKit

final class EditLocationView: UIView {
    private struct Layout {
        struct Height {
            static let slider: CGFloat = 50
            static let gpsButton: CGFloat = 50
            static let searchView: CGFloat = 38
            static let tableView: CGFloat = 44
            static let button: CGFloat = 44
        }
        struct Margin {
            static let searchView: CGFloat = 8
        }
    }
    var pin: UIImageView { return approxView.pin }
    var aproxLocationArea: UIView { return approxView }
    private let approxView = ApproxLocationView()

    var searchButton: UIButton { return searchView.searchButton }
    var searchTextField: UITextField { return searchView.textField }
    private let searchView = EditLocationSearchTextField()
    let searchTableView: UITableView = {
        let tableView = UITableView()
        tableView.delaysContentTouches = true
        tableView.cornerRadius = LGUIKitConstants.smallCornerRadius
        tableView.layer.borderColor = UIColor.lineGray.cgColor
        tableView.layer.borderWidth = LGUIKitConstants.onePixelSize
        return tableView
    }()

    lazy var mapView: MKMapView = {
        let mapView = MKMapView.sharedInstance
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isPitchEnabled = true
        mapView.removeAllGestureRecognizers() // As it's a singleton, it may be used in another view
        mapView.removeFromSuperview()

        return mapView
    }()

    let gpsLocatizationButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.Asset.IconsButtons.mapUserLocationButton.image, for: .normal)
        button.applyDefaultShadow()
        return button
    }()

    private lazy var filterDistanceSlider = FilterDistanceSlider()
    private var locationToBottomView: NSLayoutConstraint?
    private var locationToApproxView: NSLayoutConstraint?
    private let locationButtonLayoutGuide = UILayoutGuide()
    let locationButton: UIButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .medium))
        button.setTitle(R.Strings.changeLocationApplyButton, for: .normal)
        return button
    }()
    let locationActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let approximateSwitchLayoutGuide = UILayoutGuide()
    private let approximateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemLightFont(size: 16)
        label.text = R.Strings.changeLocationApproximateLocationLabel
        label.textAlignment = .left
        return label
    }()
    let approximateSwitch: UISwitch = {
        let approximateSwitch = UISwitch()
        approximateSwitch.tintColor = .primaryColor
        approximateSwitch.onTintColor = .primaryColor
        return approximateSwitch
    }()

    convenience init() { self.init(frame: .zero) }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    func setApproxArea(hidden: Bool) {
        approxView.backgroundColor = hidden ? .clear : UIColor.black.withAlphaComponent(0.1)
    }

    func setApproxLocation(hidden: Bool) {
        approximateLabel.isHidden = hidden
        approximateSwitch.isHidden = hidden
        if hidden {
            locationToBottomView?.priority = .required - 1
            locationToApproxView?.priority = .defaultLow
        } else {
            locationToBottomView?.priority = .defaultLow
            locationToApproxView?.priority = .required - 1
        }
    }

    private func setupUI() {
        backgroundColor = .white
        addSubviewsForAutoLayout([mapView, approxView, gpsLocatizationButton, searchTableView, searchView])
        setupLocationButton()
        setupApproximateSwitch()

        NSLayoutConstraint.activate([
            mapView.leftAnchor.constraint(equalTo: leftAnchor),
            mapView.topAnchor.constraint(equalTo: topAnchor),
            mapView.rightAnchor.constraint(equalTo: rightAnchor),

            approxView.heightAnchor.constraint(equalTo: approxView.widthAnchor),
            approxView.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
            approxView.centerYAnchor.constraint(equalTo: mapView.centerYAnchor),
            approxView.widthAnchor.constraint(equalTo: mapView.widthAnchor, multiplier: 0.6),

            searchTableView.topAnchor.constraint(equalTo: searchView.bottomAnchor),
            searchTableView.heightAnchor.constraint(equalToConstant: Layout.Height.tableView),
            searchTableView.leftAnchor.constraint(equalTo: searchView.leftAnchor),
            searchTableView.rightAnchor.constraint(equalTo: searchView.rightAnchor),

            searchView.leftAnchor.constraint(equalTo: leftAnchor, constant: Layout.Margin.searchView),
            searchView.topAnchor.constraint(equalTo: mapView.topAnchor, constant: Metrics.shortMargin),
            searchView.rightAnchor.constraint(equalTo: rightAnchor, constant: -Layout.Margin.searchView),
            searchView.heightAnchor.constraint(equalToConstant: Layout.Height.searchView),

            gpsLocatizationButton.widthAnchor.constraint(equalTo: gpsLocatizationButton.heightAnchor),
            gpsLocatizationButton.widthAnchor.constraint(equalToConstant: Layout.Height.gpsButton),
            gpsLocatizationButton.rightAnchor.constraint(equalTo: searchView.rightAnchor),
            gpsLocatizationButton.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: Metrics.shortMargin)
            ])
    }

    func addSliderViewWith(delegate: FilterDistanceSliderDelegate, distanceType: DistanceType, distanceRadius: Int) {
        let sliderContainer = UIView()
        sliderContainer.backgroundColor = .white
        addSubviewForAutoLayout(sliderContainer)
        sliderContainer.layout().height(Layout.Height.slider)
        sliderContainer.layout(with: self).fillHorizontal()
        sliderContainer.layout(with: locationButtonLayoutGuide).bottom(to: .top)

        sliderContainer.addSubviewForAutoLayout(filterDistanceSlider)
        filterDistanceSlider.layout(with: sliderContainer).fill()

        filterDistanceSlider.delegate = delegate
        filterDistanceSlider.distanceType = distanceType
        filterDistanceSlider.distance = distanceRadius
    }

    private func setupLocationButton() {
        let margin = Metrics.veryBigMargin
        addLayoutGuide(locationButtonLayoutGuide)
        addSubviewsForAutoLayout([locationActivityIndicator, locationButton])

        let bottomToContainer = locationButtonLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor)
        bottomToContainer.priority = 999
        NSLayoutConstraint.activate([
            locationButtonLayoutGuide.leftAnchor.constraint(equalTo: leftAnchor),
            locationButtonLayoutGuide.topAnchor.constraint(equalTo: mapView.bottomAnchor),
            locationButtonLayoutGuide.rightAnchor.constraint(equalTo: rightAnchor),
            bottomToContainer,

            locationActivityIndicator.centerXAnchor.constraint(equalTo: locationButton.centerXAnchor),
            locationActivityIndicator.centerYAnchor.constraint(equalTo: locationButton.centerYAnchor),

            locationButton.leftAnchor.constraint(equalTo: locationButtonLayoutGuide.leftAnchor,
                                                 constant: Metrics.margin),
            locationButton.heightAnchor.constraint(equalToConstant: Layout.Height.button),
            locationButton.topAnchor.constraint(equalTo: locationButtonLayoutGuide.topAnchor, constant: margin),
            locationButton.rightAnchor.constraint(equalTo: locationButtonLayoutGuide.rightAnchor,
                                                  constant: -Metrics.margin),
            locationButton.bottomAnchor.constraint(equalTo: locationButtonLayoutGuide.bottomAnchor, constant: -margin)
            ])
        self.locationToBottomView = bottomToContainer
    }

    private func setupApproximateSwitch() {
        addLayoutGuide(approximateSwitchLayoutGuide)
        addSubviewsForAutoLayout([approximateLabel, approximateSwitch])
        let approxToSetLocation = approximateSwitchLayoutGuide.topAnchor.constraint(equalTo: locationButtonLayoutGuide.bottomAnchor)
        approxToSetLocation.priority = .defaultLow
        NSLayoutConstraint.activate([
            approxToSetLocation,
            approximateSwitchLayoutGuide.leftAnchor.constraint(equalTo: leftAnchor),
            approximateSwitchLayoutGuide.rightAnchor.constraint(equalTo: rightAnchor),
            approximateSwitchLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Metrics.bigMargin),
            
            approximateLabel.leftAnchor.constraint(equalTo: approximateSwitchLayoutGuide.leftAnchor,
                                                   constant: Metrics.margin),
            approximateLabel.centerYAnchor.constraint(equalTo: approximateSwitch.centerYAnchor),

            approximateSwitch.leftAnchor.constraint(equalTo: approximateLabel.rightAnchor, 
                                                    constant: Metrics.shortMargin),
            approximateSwitch.topAnchor.constraint(equalTo: approximateSwitchLayoutGuide.topAnchor,
                                                   constant: Metrics.shortMargin),
            approximateSwitch.rightAnchor.constraint(equalTo: approximateSwitchLayoutGuide.rightAnchor,
                                                     constant: -Metrics.margin),
            approximateSwitch.bottomAnchor.constraint(equalTo: approximateSwitchLayoutGuide.bottomAnchor,
                                                      constant: -Metrics.shortMargin),
            ])
        self.locationToApproxView = approxToSetLocation
    }
}

final private class ApproxLocationView: UIView {

    let pin = UIImageView(image: R.Asset.IconsButtons.mapPin.image)

    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    convenience init() { self.init(frame: .zero) }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    private func setupUI() {
        isUserInteractionEnabled = false
        backgroundColor = UIColor.black.withAlphaComponent(0.1)
        addSubviewForAutoLayout(pin)
        NSLayoutConstraint.activate([
            pin.centerXAnchor.constraint(equalTo: centerXAnchor),
            pin.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setRoundedCorners()
    }

}

final private class EditLocationSearchTextField: UIView {
    private struct Layout {
        static let textfieldInset: CGFloat = 40
        static let shadowRadius: CGFloat = 6
        static let shadowOffset: CGSize = CGSize(width: 0, height: 2)
    }
    private struct Color {
        static let gray = UIColor(red: 85, green: 85, blue: 85)
    }
    let textField: LGTextField = {
        let textfield = LGTextField.init(frame: .zero)
        textfield.insetX = Layout.textfieldInset
        textfield.clearButtonMode = .always
        textfield.autocapitalizationType = .none
        textfield.backgroundColor = .white
        textfield.textColor = Color.gray

        textfield.layer.shadowColor = UIColor.black.cgColor
        textfield.layer.shadowOpacity = 0.16
        textfield.layer.shadowOffset = Layout.shadowOffset
        textfield.layer.shadowRadius = Layout.shadowRadius

        textfield.cornerRadius = LGUIKitConstants.mediumCornerRadius
        textfield.layer.borderColor = UIColor.lineGray.cgColor
        textfield.layer.borderWidth = LGUIKitConstants.onePixelSize

        textfield.placeholder = R.Strings.changeLocationSearchFieldHint
        return textfield
    }()

    let searchButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.Asset.IconsButtons.listSearch.image, for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    convenience init() { self.init(frame: .zero) }

    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    private func setupUI() {
        backgroundColor = .clear
        addSubviewsForAutoLayout([textField, searchButton])
        NSLayoutConstraint.activate([
            textField.leftAnchor.constraint(equalTo: leftAnchor),
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.rightAnchor.constraint(equalTo: rightAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),

            searchButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            searchButton.leftAnchor.constraint(equalTo: textField.leftAnchor, constant: Metrics.shortMargin)
            ])
    }
}
