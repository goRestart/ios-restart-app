//
//  Logger.swift
//  LetGo
//
//  Created by Eli Kohen on 11/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

public enum LoggerLevel {
    case Info, Warning, Error
}

protocol Logger {
    func log(level: LoggerLevel, message: String)
}
