import LGComponents
import RxSwift

protocol ListingCarouselVideoCellDelegate {
    func didChangeVideoStatus(status: VideoPreview.Status, pageAtIndex index: Int)
    func didChangeVideoProgress(progress: Float, pageAtIndex index: Int)
}

final class ListingCarouselVideoCell: UICollectionViewCell, ReusableCell {

    let videoPreview: VideoPreview = {
        let videoPreview = VideoPreview(frame: .zero)
        return videoPreview
    }()

    var position: Int = 0
    var status = Variable<VideoPreview.Status>(.unknown)
    var delegate: ListingCarouselVideoCellDelegate?

    private var effectsView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .dark)
        return UIVisualEffectView(effect: effect)
    }()
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
        setAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        videoPreview.url = nil
    }

    private func setupUI() {
        clipsToBounds = true

        addSubviewForAutoLayout(effectsView)
        addSubviewForAutoLayout(videoPreview)
        setupConstraints()
        setupRx()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            effectsView.topAnchor.constraint(equalTo: topAnchor),
            effectsView.rightAnchor.constraint(equalTo: rightAnchor),
            effectsView.bottomAnchor.constraint(equalTo: bottomAnchor),
            effectsView.leftAnchor.constraint(equalTo: leftAnchor),

            videoPreview.topAnchor.constraint(equalTo: topAnchor),
            videoPreview.rightAnchor.constraint(equalTo: rightAnchor),
            videoPreview.bottomAnchor.constraint(equalTo: bottomAnchor),
            videoPreview.leftAnchor.constraint(equalTo: leftAnchor)
            ])
    }

    private func setupRx() {
        videoPreview.rx_progress.asDriver().drive(onNext: { [weak self] progress in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.didChangeVideoProgress(progress: progress, pageAtIndex: strongSelf.position)
        }).disposed(by: disposeBag)
        videoPreview.rx_status.subscribeNext { [weak self] status in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.delegate?.didChangeVideoStatus(status: status, pageAtIndex: strongSelf.position)
            }
        }.disposed(by: disposeBag)
    }
}


// MARK: - Public methods

extension ListingCarouselVideoCell {
    func setVideo(url: URL) {
        videoPreview.url = url
    }

    func play() {
        videoPreview.play()        
    }

    func pause() {
        videoPreview.pause()
    }
}

// MARK: - Accessibility

private extension ListingCarouselVideoCell {
    func setAccessibilityIds() {
        set(accessibilityId: .listingCarouselVideoCell)
        videoPreview.set(accessibilityId: .listingCarouselVideoCellVideoPreview)
    }
}
