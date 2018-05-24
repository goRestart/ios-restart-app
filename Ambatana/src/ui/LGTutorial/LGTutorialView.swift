import LGComponents

protocol LGTutorialViewDelegate: class {
    func closeButtonPressed()
    func getStartedButtonPressed()
}

final class LGTutorialView: UIView {
    
    private let layout = LGTutorialLayout()
    let collectionView: UICollectionView
    var pageControl = LGPageControl()
    
    private let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let close = UIButton(type: .custom)
    private let acceptButton = LetgoButton(withStyle: .primary(fontSize: .medium))
    
    var page: Int { return layout.page }
    weak var delegate: LGTutorialViewDelegate?
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        super.init(frame: frame)
        setupUI()
    }
    
    override func layoutSubviews() {
        setupAcceptButton()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.3)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        
        addSubviewsForAutoLayout([effectView, collectionView, close, pageControl, acceptButton])
        
        setupEffectView()
        setupClose()
        setupAcceptButton()
        setupPageControl()
        setupCollectionView()
        
    }
    
    private func setupCollectionView() {
        collectionView.topAnchor.constraint(equalTo: close.bottomAnchor, constant: Metrics.margin).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: pageControl.topAnchor).isActive = true
    }
    
    private func setupClose() {
        close.setTitle(R.Strings.tutorialSkipButtonTitle, for: .normal)
        close.topAnchor.constraint(equalTo: topAnchor, constant: Metrics.margin).isActive = true
        close.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30).isActive = true
         
        close.titleLabel?.font =  UIFont.systemBoldFont(size: 15)
        close.setTitleColor(UIColor.grayLighter, for: .normal)
        
        close.addTarget(self, action: #selector(LGTutorialView.closePressed), for: .touchUpInside)
    }
    
    private func setupEffectView() {
        effectView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        effectView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        effectView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        effectView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        effectView.alpha = 0.9
    }
    
    private func setupPageControl() {
        pageControl.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: acceptButton.topAnchor, constant: -Metrics.shortMargin).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: 30)
    }
    
    private func setupAcceptButton() {
        acceptButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Metrics.margin).isActive = true
        acceptButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        acceptButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        acceptButton.widthAnchor.constraint(equalTo: collectionView.widthAnchor, multiplier: 0.8).isActive = true
        acceptButton.setTitle(R.Strings.tutorialAcceptButtonTitle, for: .normal)
        
        acceptButton.addTarget(self, action: #selector(LGTutorialView.getStartedPressed), for: .touchUpInside)
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
