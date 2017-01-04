//
//  BaseView.swift
//  LetGo
//
//  Created by Albert Hernández López on 20/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

class BaseView: UIView {

    private var viewModel: BaseViewModel!

    open var active: Bool = false {
        didSet {
            if oldValue != active {
                viewModel.active = active

                if active {
                    didBecomeActive(activeFirstTime)
                    activeFirstTime = false
                } else {
                    didBecomeInactive()
                }
            }
        }
    }
    private var activeFirstTime = true

    
    // MARK: - Lifecycle
    
    public init(viewModel: BaseViewModel, frame: CGRect) {
        self.viewModel = viewModel
        super.init(frame: frame)
    }

    public init?(viewModel: BaseViewModel, coder aDecoder: NSCoder) {
        self.viewModel = viewModel
        super.init(coder: aDecoder)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func switchViewModel(_ viewModel: BaseViewModel) {
        self.viewModel.active = false
        self.viewModel = viewModel
        self.viewModel.active = self.active
    }

    // MARK: - Internal methods
    
    internal func didBecomeActive(_ firstTime: Bool) {
        
    }

    internal func didBecomeInactive() {

    }


    // MARK: - Helper methods

    func loadNibNamed(_ nibName: String, contentView: () -> UIView?) {
        Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        guard let view = contentView() else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(view)
    }
}
