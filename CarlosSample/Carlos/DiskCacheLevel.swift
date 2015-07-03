//
//  DiskCacheLevel.swift
//  CarlosSample
//
//  Created by Monaco, Vittorio on 03/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation

public class DiskCache: CacheLevel {
  private let path: String
  private var size: UInt64 = 0
  private let fileManager: NSFileManager
  public var capacity: UInt64 = 0 {
    didSet {
      dispatch_async(self.cacheQueue, {
        self.controlCapacity()
      })
    }
  }
  
  private lazy var cacheQueue : dispatch_queue_t = {
    let queueName = CarlosGlobals.QueueNamePrefix + self.path.lastPathComponent
    let cacheQueue = dispatch_queue_create(queueName, nil)
    return cacheQueue
  }()
  
  public func onMemoryWarning() {}
  
  public init(path: String = CarlosGlobals.Caches.stringByAppendingPathComponent(CarlosGlobals.QueueNamePrefix + "default"), capacity: UInt64 = 100 * CarlosGlobals.Megabyte, fileManager: NSFileManager = NSFileManager.defaultManager()) {
    self.path = path
    self.fileManager = fileManager
    self.capacity = capacity
    
    fileManager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: [:], error: nil)
    
    dispatch_async(self.cacheQueue, {
      self.calculateSize()
      self.controlCapacity()
    })
  }
  
  public func set(value: NSData, forKey key: FetchableType) {
    dispatch_async(cacheQueue, {
      self.setDataSync(value, key: key.key)
    })
  }
  
  public func get(key: FetchableType, onSuccess success: (NSData) -> Void, onFailure failure: (NSError?) -> Void) {
    dispatch_async(cacheQueue, {
      let path = self.pathForKey(key.key)
      var error: NSError? = nil
      if let data = NSData(contentsOfFile: path, options: .allZeros, error: &error) {
        dispatch_async(dispatch_get_main_queue(), {
          success(data)
        })
        self.updateDiskAccessDateAtPath(path)
      } else {
        dispatch_async(dispatch_get_main_queue(), {
          failure(error)
        })
      }
    })
  }
  
  private func removeData(key : String) {
    dispatch_async(cacheQueue, {
      let path = self.pathForKey(key)
      self.removeFileAtPath(path)
    })
  }
  
  public func clear() {
    let cachePath = path
    dispatch_async(cacheQueue, {
      var error: NSError? = nil
      if let contents = self.fileManager.contentsOfDirectoryAtPath(cachePath, error: &error) as? [String] {
        for pathComponent in contents {
          let path = cachePath.stringByAppendingPathComponent(pathComponent)
          if !self.fileManager.removeItemAtPath(path, error: &error) {
            println("Failed to remove path \(path)")
          }
        }
        self.calculateSize()
      } else {
        println("Failed to list directory")
      }
    })
  }
  
  private func updateAccessDate(@autoclosure(escaping) getData : () -> NSData?, key : String) {
    dispatch_async(cacheQueue, {
      let path = self.pathForKey(key)
      if !self.updateDiskAccessDateAtPath(path) && !self.fileManager.fileExistsAtPath(path) {
        if let data = getData() {
          self.setDataSync(data, key: key)
        } else {
          println("Failed to get data for key \(key)")
        }
      }
    })
  }
  
  private func pathForKey(key : String) -> String {
    let filename = key.MD5String()
    let keyPath = path.stringByAppendingPathComponent(filename)
    return keyPath
  }
  
  private func calculateSize() {
    size = 0
    let cachePath = path
    var error : NSError?
    if let contents = fileManager.contentsOfDirectoryAtPath(cachePath, error: &error) as? [String] {
      for pathComponent in contents {
        let path = cachePath.stringByAppendingPathComponent(pathComponent)
        if let attributes : NSDictionary = fileManager.attributesOfItemAtPath(path, error: &error) {
          size += attributes.fileSize()
        } else {
          println("Failed to read file size of \(path)")
        }
      }
    } else {
      println("Failed to list directory")
    }
  }
  
  private func controlCapacity() {
    if size <= capacity { return }
    
    let cachePath = path
    
    fileManager.enumerateContentsOfDirectoryAtPath(cachePath, orderedByProperty: NSURLContentModificationDateKey, ascending: true) { (URL : NSURL, _, inout stop : Bool) -> Void in
      
      if let path = URL.path {
        self.removeFileAtPath(path)
        
        stop = self.size <= self.capacity
      }
    }
  }
  
  private func setDataSync(data: NSData, key : String) {
    let path = pathForKey(key)
    var error: NSError?
    let previousAttributes : NSDictionary? = fileManager.attributesOfItemAtPath(path, error: nil)
    let success = data.writeToFile(path, options: NSDataWritingOptions.AtomicWrite, error:&error)
    if !success {
      println("Failed to write key \(key)")
    }
    if let attributes = previousAttributes {
      size -= attributes.fileSize()
    }
    size += UInt64(data.length)
    controlCapacity()
  }
  
  private func updateDiskAccessDateAtPath(path : String) -> Bool {
    let now = NSDate()
    var error : NSError?
    let success = fileManager.setAttributes([NSFileModificationDate : now], ofItemAtPath: path, error: &error)
    if !success {
      println("Failed to update access date")
    }
    return success
  }
  
  private func removeFileAtPath(path: String) {
    var error : NSError?
    if let attributes : NSDictionary = fileManager.attributesOfItemAtPath(path, error: &error) {
      let fileSize = attributes.fileSize()
      if fileManager.removeItemAtPath(path, error: &error) {
        self.size -= fileSize
      } else {
        println("Failed to remove file")
      }
    } else if let error = error where NSCocoaErrorDomain == error.domain && error.code == NSFileReadNoSuchFileError {
      println("File not found")
    } else {
      println("Failed to remove file")
    }
  }
}
