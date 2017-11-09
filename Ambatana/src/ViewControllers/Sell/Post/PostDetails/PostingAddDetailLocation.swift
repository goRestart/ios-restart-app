//
//  PostingAddDetailLocation.swift
//  LetGo
//
//  Created by Juan Iglesias on 06/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//


import RxSwift
import MapKit
import LGCoreKit

final class PostingAddDetailLocation: UIView, PostingViewConfigurable {
    
    private let bottomMessage = UILabel()
    private let searchMapView = LGSearchMap(frame: CGRect.zero, viewModel: LGSearchMapViewModel())
    var position = Variable<LGLocationCoordinates2D?>(nil)
    
    private let disposeBag = DisposeBag()
    
    
    // MARK - Lifecycle
    
    init(viewControllerDelegate: LGSearchMapViewControllerModelDelegate) {
        super.init(frame: CGRect.zero)
        setupUI()
        setupConstraints()
        setupRx()
        searchMapView.viewModel.viewControllerDelegate = viewControllerDelegate
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        bottomMessage.text = LGLocalizedString.realEstateLocationNotificationMessage
        bottomMessage.font = UIFont.subtitleFont
        bottomMessage.textColor = UIColor.white
    }
    
    private func setupConstraints() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: [bottomMessage, searchMapView])
        addSubviews([bottomMessage, searchMapView])
        
        searchMapView.layout(with: self).top().fillHorizontal(by: Metrics.bigMargin)
        bottomMessage.layout(with: searchMapView).below(by: Metrics.margin).fillHorizontal()
        bottomMessage.layout(with: self).bottom()
    }
    
    private func setupRx() {
       
    }
    
    
    
    // MARK: - PostingViewConfigurable
    
    func setupView(viewModel: PostingDetailsViewModel) {
        
    }
    func setupContainerView(view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        layout(with: view).fill()
    }
    
    
}
