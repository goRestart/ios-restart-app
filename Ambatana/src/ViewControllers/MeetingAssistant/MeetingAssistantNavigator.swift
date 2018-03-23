//
//  MeetingAssistantNavigator.swift
//  LetGo
//
//  Created by Dídac on 22/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

protocol MeetingAssistantNavigator: class {
    func openEditLocation(withViewModel viewModel: EditLocationViewModel)
    func meetingCreationDidFinish()
    func openMeetingTipsWith(closingCompletion: (()->Void)?)
}
