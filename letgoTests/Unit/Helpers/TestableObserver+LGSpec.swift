//
//  TestableObserver+LGSpec.swift
//  LetGo
//
//  Created by Eli Kohen on 07/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxTest

extension TestableObserver {

    var lastValue: Element? {
        return eventValues.last
    }

    var eventValues: [Element] {
        return events.flatMap{ $0.value.element }
    }
}
