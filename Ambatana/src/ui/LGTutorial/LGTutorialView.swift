//
//  LGTutorialView.swift
//  LetGo
//
//  Created by Facundo Menzella on 11/17/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

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
        
        let topView = UIView()
        let bottomView = UIView()
        
        let subviews = [effectView, topView, bottomView, collectionView]
        addSubviewsForAutoLayout(subviews)
        
        topView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        topView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        topView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        collectionView.topAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        
        bottomView.topAnchor.constraint(equalTo: collectionView.bottomAnchor).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bottomView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        bottomView.heightAnchor.constraint(equalTo: topView.heightAnchor, multiplier: 1.5).isActive = true
        bottomView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.2).isActive = true
        
        setupEffectView()
        setupAcceptButton()
        setupPageControl()
        setupClose()
    }
    
    private func setupClose() {
        close.translatesAutoresizingMaskIntoConstraints = false
        addSubview(close)
        close.setTitle(LGLocalizedString.tutorialSkipButtonTitle, for: .normal)
        close.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
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
        addSubviewForAutoLayout(pageControl)
        pageControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor).isActive = true
        pageControl.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: acceptButton.topAnchor).isActive = true
    }
    
    private func setupAcceptButton() {
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(acceptButton)
        acceptButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Metrics.veryBigMargin).isActive = true
        acceptButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        acceptButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        acceptButton.widthAnchor.constraint(equalTo: collectionView.widthAnchor, multiplier: 0.8).isActive = true
        acceptButton.setTitle(LGLocalizedString.tutorialAcceptButtonTitle, for: .normal)
        
        acceptButton.addTarget(self, action: #selector(LGTutorialView.getStartedPressed), for: .touchUpInside)
    }
    
    func updateAcceptButton() {
        acceptButton.isHidden = pageControl.currentPage != pageControl.numberOfPages - 1
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
