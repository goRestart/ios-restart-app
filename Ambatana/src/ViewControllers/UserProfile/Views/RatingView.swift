import Foundation
import LGComponents

/* View showing 5 horizontal stars */
final class RatingView: UIView {
    private let star1 = UIImageView()
    private let star2 = UIImageView()
    private let star3 = UIImageView()
    private let star4 = UIImageView()
    private let star5 = UIImageView()
    private let stackView = UIStackView()
    private let layout: Layout
    private var stars: [UIImageView] {
        return [star1, star2, star3, star4, star5]
    }

    enum Layout {
        case normal
        case mini

        var starSize: CGFloat {
            switch self {
            case .normal: return 17
            case .mini: return 12
            }
        }

        var starSpacing: CGFloat {
            switch self {
            case .normal: return 3
            case .mini: return 2
            }
        }
    }

    init(layout: RatingView.Layout) {
        self.layout = layout
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: CGFloat(stars.count)*layout.starSize + CGFloat(stars.count-1)*layout.starSpacing, height: layout.starSize)
    }

    private func setupViews() {
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = layout.starSpacing
        addSubviewForAutoLayout(stackView)

        for (i, star) in stars.enumerated() {
            star.tag = i + 1 // tags starting in 1
            star.frame = CGRect(x: 0, y: 0, width: layout.starSize, height: layout.starSize)
            stackView.addArrangedSubview(star)
            star.image = R.Asset.IconsButtons.icUserProfileStar.image
            star.contentMode = .scaleAspectFit
        }
        setupConstraints()
    }

    private func setupConstraints() {
        let constraints = [
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    func setupValue(rating: Float) {
        for star in stars {
            star.alpha = Float(star.tag) <= rating ? 1 : 0.4
        }
    }
}
