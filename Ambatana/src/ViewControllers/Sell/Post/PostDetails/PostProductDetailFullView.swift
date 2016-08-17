//
//  PostProductDetailFullView.swift
//  LetGo
//
//  Created by Eli Kohen on 17/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

class PostProductDetailFullView: BaseView {

    @IBOutlet var contentView: UIView!

    private let viewModel: PostProductDetailViewModel

    convenience init() {
        self.init(viewModel: PostProductDetailViewModel(), frame: CGRect.zero)
    }

    init(viewModel: PostProductDetailViewModel, frame: CGRect) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, frame: frame)
        setupUI()
    }

    init?(viewModel: PostProductDetailViewModel, coder aDecoder: NSCoder) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, coder: aDecoder)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func setupUI() {
        loadNibNamed("PostProductDetailFullView", contentView: contentView)

    }
}
