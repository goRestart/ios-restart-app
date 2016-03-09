//
//  ProcessingVideoDialogViewModel.swift
//  LetGo
//
//  Created by Dídac on 08/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


public class ProcessingVideoDialogViewModel: BaseViewModel {

    var promotionSource: PromotionSource


    // MARK: - Lifecycle

    init(promotionSource: PromotionSource) {
        self.promotionSource = promotionSource
        super.init()
    }
}
