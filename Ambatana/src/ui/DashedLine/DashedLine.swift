final class DashedLine: UIView {
    override var intrinsicContentSize: CGSize { return CGSize(width: UIViewNoIntrinsicMetric,
                                                              height: UIViewNoIntrinsicMetric) }

    private let dash = CAShapeLayer()
    private let color: UIColor

    init(color: UIColor) {
        self.color = color
        super.init(frame: .zero)
        self.isOpaque = false

        setupLayers()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLayers() {
        dash.frame = bounds
        dash.fillColor = UIColor.clear.cgColor
        dash.strokeColor = color.cgColor
        dash.lineWidth = 4
        dash.lineDashPattern = [10, 10]
        
        layer.insertSublayer(dash, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard dash.frame != bounds else { return }

        dash.frame = bounds

        let path = CGMutablePath()
        if bounds.width > bounds.height {
            path.move(to: CGPoint(x: 0, y: bounds.height / 2))
            path.addLine(to: CGPoint(x: bounds.width, y: bounds.height / 2))
        } else {
            path.move(to: CGPoint(x: bounds.width / 2, y: 0))
            path.addLine(to: CGPoint(x: bounds.width / 2, y: bounds.height))
        }
        dash.path = path
    }
}
