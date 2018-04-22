//
//  PreSignedUploadUrlForm+LG.swift
//  LetGo
//
//  Created by Álvaro Murillo del Puerto on 21/4/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

extension PreSignedUploadUrlForm {
    var fileKey: String? {

        if let key = inputs.first(where: { $0.key == "key" }) {
            return key.value
        } else {
            return nil
        }
    }
}
