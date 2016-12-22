//
//  String+LG.swift
//  LGCoreKit
//
//  Created by Nestor Garcia on 19/12/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation

extension String {
    func lastComponentSeparatedByCharacter(character: Character) -> String? {
        return self.characters.split(character).last.map { String($0) }
    }
}
