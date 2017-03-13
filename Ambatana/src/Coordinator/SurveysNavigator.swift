//
//  SurveysNavigator.swift
//  LetGo
//
//  Created by Eli Kohen on 09/03/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

protocol WebSurveyNavigator: class {
    func closeWebSurvey()
    func webSurveyFinished()
}

protocol NpsSurveyNavigator: class {
    func closeNpsSurvey()
    func npsSurveyFinished()
}
