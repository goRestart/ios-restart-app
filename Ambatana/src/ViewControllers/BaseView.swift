//
//  BaseView.swift
//  LetGo
//
//  Created by Albert Hernández López on 20/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

public class BaseView: UIView {

    private var viewModel: BaseViewModel!

    public var active: Bool = false {
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


    // MARK: - Internal methods
    
    internal func didBecomeActive(firstTime: Bool) {
        
    }

    internal func didBecomeInactive() {

    }
}
