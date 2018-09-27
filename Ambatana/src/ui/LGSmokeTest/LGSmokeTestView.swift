import LGComponents

protocol LGSmokeTestViewDelegate: class {
    func closeButtonPressed()
    func getStartedButtonPressed()
}

final class LGSmokeTestView: UIView {
    
    private let layout = LGSmokeTestLayout()
    let collectionView: UICollectionView
    var pageControl = LGPageControl()
    
    private let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let close = UIButton(type: .custom)
    private let acceptButton = LetgoButton(withStyle: .primary(fontSize: .medium))
    private var acceptButtonTitle: String
    
    var page: Int { return layout.page }
    weak var delegate: LGSmokeTestViewDelegate?
    
    convenience init(acceptButtonTitle: String) {
        self.init(frame: .zero,
                  acceptButtonTitle: acceptButtonTitle)
    }
    
    init(frame: CGRect,
         acceptButtonTitle: String) {
        self.acceptButtonTitle = acceptButtonTitle
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.3)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        
        addSubviewsForAutoLayout([effectView, collectionView, close, pageControl, acceptButton])
        
        setupEffectView()
        setupClose()
        setupAcceptButton(withTitle: acceptButtonTitle)
        setupPageControl()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: close.bottomAnchor,
                                                constant: Metrics.veryBigMargin),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: acceptButton.topAnchor,
                                                   constant: -Metrics.veryBigMargin)
            ])
    }
    
    private func setupClose() {
        close.setTitle(R.Strings.tutorialSkipButtonTitle, for: .normal)
        
        NSLayoutConstraint.activate([
            close.topAnchor.constraint(equalTo: safeTopAnchor, constant: Metrics.shortMargin),
            close.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30)
            ])
         
        close.titleLabel?.font =  .systemBoldFont(size: 15)
        close.setTitleColor(.grayLighter, for: .normal)
        
        close.addTarget(self, action: #selector(closePressed), for: .touchUpInside)
    }
    
    private func setupEffectView() {
        NSLayoutConstraint.activate([
            effectView.topAnchor.constraint(equalTo: topAnchor),
            effectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            effectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            effectView.leadingAnchor.constraint(equalTo: leadingAnchor)
            ])

        effectView.alpha = 0.9
    }
    
    private func setupPageControl() {
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: acceptButton.topAnchor, constant: -Metrics.shortMargin),
            pageControl.heightAnchor.constraint(equalToConstant: 30)
            ])
    }
    
    private func setupAcceptButton(withTitle title: String) {
        NSLayoutConstraint.activate([
            acceptButton.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                 constant: -Metrics.margin),
            acceptButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            acceptButton.heightAnchor.constraint(equalToConstant: 50),
            acceptButton.widthAnchor.constraint(equalTo: collectionView.widthAnchor,
                                                multiplier: 0.8)
            ])

        acceptButton.setTitle(title, for: .normal)
        
        acceptButton.addTarget(self, action: #selector(LGSmokeTestView.getStartedPressed), for: .touchUpInside)
    }
    
    func updateAcceptButton() {
        let isHidden = pageControl.currentPage != pageControl.numberOfPages - 1
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.acceptButton.alpha = isHidden ? 0.0 : 1.0
        })
    }
    
    func setNumberOfPages(numberOfPages: Int) {
        pageControl.numberOfPages = numberOfPages
    }
    
    func setCurrentPage(currentPage: Int) {
        pageControl.currentPage = currentPage
    }
    
    @objc private func closePressed() {
        delegate?.closeButtonPressed()
    }
    
    @objc private func getStartedPressed() {
        delegate?.getStartedButtonPressed()
    }
}
