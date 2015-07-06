//
//  Logger.swift
//  CarlosSample
//
//  Created by Monaco, Vittorio on 06/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation

class Logger {
  static func log(message: String) {
    #if CARLOS_DEBUG
    println(message)
    #endif
  }
}