//
//  NSFileManagerFake.swift
//  Carlos
//
//  Created by Monaco, Vittorio on 06/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation

class NSFileManagerFake: NSFileManager {
  var createdDirectoryAtPath: String?
  override func createDirectoryAtPath(path: String, withIntermediateDirectories createIntermediates: Bool, attributes: [NSObject : AnyObject]?, error: NSErrorPointer) -> Bool {
    createdDirectoryAtPath = path
    
    return super.createDirectoryAtPath(path, withIntermediateDirectories: createIntermediates, attributes: attributes, error: error)
  }
}
