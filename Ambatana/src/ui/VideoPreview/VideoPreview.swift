import UIKit
import AVFoundation
import RxSwift
import RxCocoa

final class VideoPreview: UIView {

    enum Status {
        case unknown
        case readyToPlay
        case failed

        init(status: AVPlayerStatus?) {
            switch status {
            case .unknown?:
                self = .unknown
            case .readyToPlay?:
                self = .readyToPlay
            case .failed?:
                self = .failed
            case .none:
                self = .unknown
            }
        }
    }

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    var url: URL? {
        didSet {
            if let playerItem = player.currentItem {
                NotificationCenter.default.removeObserver(self,
                                                          name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                                          object: playerItem)
            }
            var playerItem: AVPlayerItem?
            if let url = url { playerItem = AVPlayerItem(url: url) }
            player.replaceCurrentItem(with: playerItem)
        }
    }

    lazy fileprivate var player: AVPlayer = {
        let player = AVPlayer(playerItem: nil)
        player.actionAtItemEnd = .none
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        return player
    }()

    private var playerLayer: AVPlayerLayer {
        guard let layer = layer as? AVPlayerLayer else {
            fatalError("Expected `AVPlayerLayer` type for layer. Check VideoPreview.layerClass implementation.")
        }
        return layer
    }

    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    private let disposeBag = DisposeBag()

    var duration: TimeInterval {
        guard let duration = player.currentItem?.duration else { return 0}
        return CMTimeGetSeconds(duration)
    }

    var currentTime: TimeInterval {
        guard let currentTime = player.currentItem?.currentTime() else { return 0}
        return CMTimeGetSeconds(currentTime)
    }

    var progress: Float {
        return Float(currentTime / duration)
    }

    var rx_progress = BehaviorRelay<Float>(value: 0.0)

    private var periodicTimeObserver: Any?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    func play() {
        player.play()
        let time = CMTimeMake(1, 20)
        periodicTimeObserver = player.addPeriodicTimeObserver(forInterval: time,
                                                              queue: DispatchQueue.main) { [weak self] (time) in
            guard let strongSelf = self else { return }
            strongSelf.rx_progress.accept(strongSelf.progress)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
    }

    func pause() {
        player.pause()
        if let periodicTimeObserver = periodicTimeObserver {
            player.removeTimeObserver(periodicTimeObserver)
        }
    }

    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem: AVPlayerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: kCMTimeZero, completionHandler: nil)
        }
    }

    private func setupUI() {
        addSubviewForAutoLayout(activityIndicator)
        setupConstraints()
        setupRx()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func setupRx() {
        rx.status
            .asDriver(onErrorJustReturn: .unknown)
            .drive(onNext: { [weak self] status in
            status == .unknown ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
        }).disposed(by: disposeBag)
    }
}

extension Reactive where Base: VideoPreview {
    var status: Observable<VideoPreview.Status> {
        return base.player.rx.observe(AVPlayerStatus.self,
                                      #keyPath(AVPlayerItem.status))
            .map { VideoPreview.Status(status: $0) }
            .asObservable()
    }
}
