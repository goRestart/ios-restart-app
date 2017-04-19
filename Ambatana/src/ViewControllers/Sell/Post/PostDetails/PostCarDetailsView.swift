//
//  PostCarDetailsView.swift
//  LetGo
//
//  Created by Nestor on 06/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

class PostCarDetailsView: UIView {
    private let titleLabel = UILabel()
    private let progressView = PostCategoryDetailProgressView()
    let makeRowView = PostCategoryDetailRowView(withTitle: LGLocalizedString.postCategoryDetailCarMake)
    let modelRowView = PostCategoryDetailRowView(withTitle: LGLocalizedString.postCategoryDetailCarModel)
    let yearRowView = PostCategoryDetailRowView(withTitle: LGLocalizedString.postCategoryDetailCarYear)
    let doneButton = UIButton(type: .custom)
    
    // MARK: - Lifecycle

    init() {
        super.init(frame: CGRect.zero)
        
        setupUI()
        setupAccessibilityIds()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setupUI() {
        titleLabel.font = UIFont.systemSemiBoldFont(size: 27)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        titleLabel.text = LGLocalizedString.postCategoryDetailsTitle

        makeRowView.enabled = true
        modelRowView.enabled = false
        yearRowView.enabled = true
        
        doneButton.setStyle(.primary(fontSize: .big))
    }
    
    private func setupLayout() {
        let subviews = [titleLabel, progressView, makeRowView, modelRowView, yearRowView, doneButton]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        addSubviews(subviews)
        
        tileLabel.layout(with: )
    }
    
    // MARK: - Accessibility
    
    private func setupAccessibilityIds() {
        
    }
    
    // MARK: - Helpers
    
 /*   static private func getProgress(forCategoryDetails details: [PostCategoryDetailRow]) -> Int {
        guard details.count > 0 else { return 100 }
        var detailsFilled = 0
        details.forEach { (detail) in
            if detail.isFilled {
                detailsFilled += detailsFilled
            }
        }
        return Int(detailsFilled / details.count)
    }
 */
}
