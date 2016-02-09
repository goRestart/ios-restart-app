//
//  TourNotificationsViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 4/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

final class TourNotificationsViewModel: BaseViewModel {
    
    let title: String
    let subtitle: String
    let pushText: String
    
    init(title: String, subtitle: String, pushText: String) {
        self.title = title
        self.subtitle = subtitle
        self.pushText = pushText
    }
    
    func askPushNotificationsPermission() {
   
    }
}