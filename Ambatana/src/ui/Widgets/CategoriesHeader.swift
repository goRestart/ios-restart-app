//
//  CategoriesHeader.swift
//  LetGo
//
//  Created by Juan Iglesias on 02/05/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

protocol CategoriesHeaderDelegate: class {
    func categoryHeaderPressed()
}

class CategoriesHeader: UIView {
    
    static let viewHeight: CGFloat = 120
    
    var collectionView: CategoriesHeaderCollectionView
    
    weak var delegate: CategoriesHeaderDelegate?
    
    // MARK: - Lifecycle
    
    convenience init() {
        let frame = CGRect(x: 0, y: 0, width: 200, height: CategoriesHeader.viewHeight)
        self.init(frame: frame)
        setupUI()
        setupTap()
    }
    
    override init(frame: CGRect) {
        self.collectionView = CategoriesHeaderCollectionView(categories)
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Private methods
    
    private func setupUI() {
        backgroundColor = UIColor.grayLighter
        
        addSubview(collectionView)
        collectionView.layout(with: self).fill()
    }
    
    private func setupTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tap)
    }
    
    private dynamic func viewTapped() {
        delegate?.categoryHeaderPressed()
    }
}
