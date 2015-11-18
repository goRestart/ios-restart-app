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
                didSetActive(active)
            }
        }
    }
    
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
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let _ = superview {
            active = true
        }
        else {
            active = false
        }
    }
    
    // MARK: - Internal methods
    
    internal func didSetActive(active: Bool) {
        
    }
}
