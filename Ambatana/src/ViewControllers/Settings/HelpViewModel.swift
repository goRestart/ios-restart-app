//
//  HelpViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 24/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

public class HelpViewModel: BaseViewModel {
   
    public var url: NSURL? {
        return LetgoURLHelper.composeURL(Constants.helpURL)
    }
}
