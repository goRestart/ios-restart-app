//
//  LGPageControl.swift
//  LetGo
//
//  Created by Juan Iglesias on 15/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

final class LGPageControl: UIControl {

    private var dots: [UIView] = []
    private var stackViewContainer = UIStackView()
    
    private struct Layout {
        static let dotHeight: CGFloat = 8
        static let dotWidth: CGFloat = 8
        static let dotScale: CGFloat = 1.5
    }
    var numberOfPages: Int {
        didSet {
            cleanStackView()
            setupUI()
        }
    }
    var currentPage: Int {
        didSet {
            updateCurrentPage(to: currentPage)
        }
    }
    
    init(numberOfPages: Int = 1, currentPage: Int = 0) {
        self.numberOfPages = numberOfPages
        self.currentPage = currentPage
        
        super.init(frame: CGRect.zero)
        cleanStackView()
        setupUI()
        setupConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dots.forEach { $0.setRoundedCorners() }
    }
    
    override var intrinsicContentSize: CGSize {
        return stackViewContainer.frame.size
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func cleanStackView() {
         stackViewContainer.arrangedSubviews.forEach({$0.removeFromSuperview()})
    }
    
    private func setupUI() {
        guard numberOfPages > 1 else { return }
        for index in 0...numberOfPages - 1 {
            let dot: UIView = UIView()
            dot.layout().height(Layout.dotHeight).width(Layout.dotWidth)
            dot.backgroundColor = .white
            let transform = CGAffineTransform(scaleX: Layout.dotScale, y: Layout.dotScale)
            
            dot.transform = index == currentPage ? transform : CGAffineTransform.identity
            dots.append(dot)
        }
        dots.forEach { stackViewContainer.addArrangedSubview($0) }
    }
    private func setupConstraints() {
        addSubviewForAutoLayout(stackViewContainer)
        
        stackViewContainer.axis = .horizontal
        stackViewContainer.distribution = .fillProportionally
        stackViewContainer.alignment = .center
        stackViewContainer.spacing = 10
        
        stackViewContainer.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        stackViewContainer.isLayoutMarginsRelativeArrangement = true
        
        stackViewContainer.backgroundColor = UIColor.redBarBackground
        
        NSLayoutConstraint.activate([stackViewContainer.topAnchor.constraint(equalTo: topAnchor),
                                     stackViewContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     stackViewContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     stackViewContainer.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
    
    func updateCurrentPage(to page: Int) {
        stackViewContainer.arrangedSubviews.enumerated().forEach { (index, dot) in
            UIView.animate(withDuration: 0.3, animations: {
                dot.transform = index == page ? CGAffineTransform(scaleX: Layout.dotScale, y: Layout.dotScale) : CGAffineTransform.identity
            })
        }
    }
}
