//
//  PostCategoryDetailsView.swift
//  LetGo
//
//  Created by Nestor on 06/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

class PostCategoryDetailsView: UIView {
    private let titleLabel = UILabel()
    private let progressView: PostCategoryDetailProgressView
    private var detailRowViews: [PostCategoryDetailRowView] = []
    private let doneButton = UIButton()
    
    private let categoryDetails: [PostCategoryDetailRow]
    
    // MARK: - Lifecycle
    
    init(withCategoryDetails categoryDetails: [PostCategoryDetailRow]) {
        self.categoryDetails = categoryDetails
        progressView = PostCategoryDetailProgressView()
        
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

        var details: [PostCategoryDetailRowView] = []
        for detail in categoryDetails {
            details.append(PostCategoryDetailRowView(withCategoryDetailRow: detail))
        }
    }
    
    private func setupLayout() {
        let subviews = [titleLabel, progressView, doneButton]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        addSubviews(subviews)
        
        
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
