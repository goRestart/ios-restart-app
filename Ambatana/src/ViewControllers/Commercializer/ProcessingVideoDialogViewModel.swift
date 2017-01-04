//
//  ProcessingVideoDialogViewModel.swift
//  LetGo
//
//  Created by Dídac on 08/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

enum VideoProcessStatus {
    case processOK
    case processFail
}

class ProcessingVideoDialogViewModel: BaseViewModel {

    var promotionSource: PromotionSource
    var videoProcessStatus: VideoProcessStatus


    // MARK: - Lifecycle

    init(promotionSource: PromotionSource, status: VideoProcessStatus) {
        self.promotionSource = promotionSource
        self.videoProcessStatus = status
        super.init()
    }
}
