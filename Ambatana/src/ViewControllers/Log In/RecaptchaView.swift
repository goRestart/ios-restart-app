import WebKit
import LGComponents

final class RecaptchaView: UIView {
    private struct Layout {
        static let closeWidth: CGFloat = 56
        static let closeHeight: CGFloat = 44
    }
    let webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.requiresUserActionForMediaPlayback = true
        configuration.allowsAirPlayForMediaPlayback = true
        let web = WKWebView(frame: .zero, configuration: configuration)
        web.backgroundColor = .clear
        return web
    }()

    let activityIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        activity.color = UIColor(red: 255, green: 63, blue: 85)
        activity.startAnimating()
        activity.hidesWhenStopped = true
        return activity
    }()
    let closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.Asset.CongratsScreenImages.icCloseRed.image, for: .normal)
        return button
    }()

    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    private func setupUI() {
        addSubviewsForAutoLayout([webView, activityIndicator, closeButton])
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: Metrics.bigMargin),
            closeButton.widthAnchor.constraint(equalToConstant: Layout.closeWidth),
            closeButton.heightAnchor.constraint(equalToConstant: Layout.closeHeight),

            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.topAnchor.constraint(equalTo: closeButton.bottomAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

}
