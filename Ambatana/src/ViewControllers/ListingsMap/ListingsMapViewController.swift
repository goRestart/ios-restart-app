//
//  ListingsMapViewController.swift
//  LetGo
//
//  Created by Tomas Cobo on 30/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

final class ListingsMapViewController: BaseViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel : ListingsMapViewModel
    
    // MARK: - Subviews
    private let mapView = LGMapView()
    
    // MARK: - Lifecycle
    
    init(viewModel: ListingsMapViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        setupUI()
        setupRx()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateNavigationBar()
        setupMap()
        retrive()
    }
    
    // MARK: Private methods
    
    private func setupUI() {
        view.addSubviewsForAutoLayout([mapView])
        mapView.layout(with: view).fillHorizontal().bottom()
        mapView.layout(with: topLayoutGuide).top(to: .bottom)
    }
    
    private func updateNavigationBar() {
        setNavBarTitleStyle(.text(LGLocalizedString.listingsMapTitle))
        setNavBarBackButton(#imageLiteral(resourceName: "navbar_back_red"), selector: #selector(ListingsMapViewController.onNavBarBack))
    }
    
    private func setupMap() {
        mapView.delegate = self
        mapView.updateMapRegion(location: viewModel.location)
    }
    
    private func setupRx() {
        viewModel.mkAnnotationVariable
            .asDriver()
            .drive(onNext: { [weak self] annotations in
                self?.mapView.update(annotations: annotations)
            }).disposed(by: disposeBag)
    }
    
    private func retrive() {
        viewModel.retrieve()
    }
    
    @objc private func onNavBarBack() {
        popBackViewController()
        viewModel.close()
    }
    
}

extension ListingsMapViewController: LGMapViewDelegate {
    func gpsButtonTapped() {
        // TODO: to be implemented in following interactions
    }
}
