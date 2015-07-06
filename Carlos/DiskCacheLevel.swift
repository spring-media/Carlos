//
//  DiskCacheLevelLevel.swift
//  CarlosSample
//
//  Created by Monaco, Vittorio on 03/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation

/// This class is a disk cache level. It has a configurable total size that defaults to 100 MB.
public class DiskCacheLevel: CacheLevel {
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
  
  /**
  Initializes a new disk cache level
  
  :param: path The path to the disk storage. Defaults to a Carlos specific folder in the Caches sandbox folder.
  :param: capacity The total capacity in bytes for the disk cache. Defaults to 100 MB
  :param: fileManager The file manager to use. Defaults to the default NSFileManager. It's here mainly for dependency injection testing purposes.
  */
  public init(path: String = CarlosGlobals.Caches.stringByAppendingPathComponent(CarlosGlobals.QueueNamePrefix + "default"), capacity: UInt64 = 100 * 1024 * 1024, fileManager: NSFileManager = NSFileManager.defaultManager()) {
    self.path = path
    self.fileManager = fileManager
    self.capacity = capacity
    
    fileManager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: [:], error: nil)
    
    dispatch_async(self.cacheQueue, {
      self.calculateSize()
      self.controlCapacity()
    })
  }
  
  public func set(value: NSData, forKey fetchable: FetchableType) {
    dispatch_async(cacheQueue, {
      Logger.log("Setting a value for the key \(fetchable.fetchableKey) on the disk cache \(self)")
      self.setDataSync(value, key: fetchable.fetchableKey)
    })
  }
  
  public func get(fetchable: FetchableType, onSuccess success: (NSData) -> Void, onFailure failure: (NSError?) -> Void) {
    dispatch_async(cacheQueue, {
      let path = self.pathForKey(fetchable.fetchableKey)
      var error: NSError? = nil
      if let data = NSData(contentsOfFile: path, options: .allZeros, error: &error) {
        Logger.log("Fetched \(fetchable.fetchableKey) on disk level")
        dispatch_async(dispatch_get_main_queue(), {
          success(data)
        })
        self.updateDiskAccessDateAtPath(path)
      } else {
        Logger.log("Failed fetching \(fetchable.fetchableKey) on the disk cache")
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
      if let contents = self.fileManager.contentsOfDirectoryAtPath(cachePath, error: nil) as? [String] {
        for pathComponent in contents {
          let path = cachePath.stringByAppendingPathComponent(pathComponent)
          self.fileManager.removeItemAtPath(path, error: nil)
        }
        self.calculateSize()
      }
    })
  }
  
  private func updateAccessDate(@autoclosure(escaping) getData : () -> NSData?, key : String) {
    dispatch_async(cacheQueue, {
      let path = self.pathForKey(key)
      if !self.updateDiskAccessDateAtPath(path) && !self.fileManager.fileExistsAtPath(path) {
        if let data = getData() {
          self.setDataSync(data, key: key)
        }
      }
    })
  }
  
  private func pathForKey(key : String) -> String {
    return path.stringByAppendingPathComponent(key.MD5String())
  }
  
  private func calculateSize() {
    size = 0
    let cachePath = path
    if let contents = fileManager.contentsOfDirectoryAtPath(cachePath, error: nil) as? [String] {
      for pathComponent in contents {
        let path = cachePath.stringByAppendingPathComponent(pathComponent)
        if let attributes : NSDictionary = fileManager.attributesOfItemAtPath(path, error: nil) {
          size += attributes.fileSize()
        }
      }
    }
  }
  
  private func controlCapacity() {
    if size <= capacity {
      return
    }
    
    let cachePath = path
    fileManager.enumerateContentsOfDirectoryAtPath(cachePath, orderedByProperty: NSURLContentModificationDateKey, ascending: true) { (URL, _, inout stop: Bool) in
      
      if let path = URL.path {
        self.removeFileAtPath(path)
        
        stop = self.size <= self.capacity
      }
    }
  }
  
  private func setDataSync(data: NSData, key : String) {
    let path = pathForKey(key)
    let previousAttributes : NSDictionary? = fileManager.attributesOfItemAtPath(path, error: nil)
    let success = data.writeToFile(path, options: NSDataWritingOptions.AtomicWrite, error: nil)
    if !success {
      Logger.log("Failed to write key \(key) on the disk cache")
    }
    
    if let attributes = previousAttributes {
      size -= attributes.fileSize()
    }
    size += UInt64(data.length)
    
    controlCapacity()
  }
  
  private func updateDiskAccessDateAtPath(path : String) -> Bool {
    return fileManager.setAttributes([
      NSFileModificationDate: NSDate()
    ], ofItemAtPath: path, error: nil)
  }
  
  private func removeFileAtPath(path: String) {
    if let attributes : NSDictionary = fileManager.attributesOfItemAtPath(path, error: nil) {
      let fileSize = attributes.fileSize()
      if fileManager.removeItemAtPath(path, error: nil) {
        size -= fileSize
      }
    }
  }
}
