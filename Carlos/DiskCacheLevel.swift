import Foundation
import PiedPiper

public enum DiskCacheLevelError: Error {
  case diskArchiveWriteFailed
}

/// This class is a disk cache level. It has a configurable total size that defaults to 100 MB.
public final class DiskCacheLevel<K: StringConvertible, T: NSCoding>: CacheLevel {
  /// At the moment the disk cache level only accepts keys that can be converted to string values
  public typealias KeyType = K
  
  /// The output type of the cache, should conform to NSCoding
  public typealias OutputType = T
  
  private let path: String
  private var size: UInt64 = 0
  private let fileManager: FileManager
  
  /// The capacity of the cache
  public var capacity: UInt64 = 0 {
    didSet {
      self.cacheQueue.async {
        self.controlCapacity()
      }
    }
  }
  
  private lazy var cacheQueue: GCDQueue = {
    return GCD.serial("\(CarlosGlobals.QueueNamePrefix)\((self.path as NSString).lastPathComponent)")
  }()
  
  /**
  This method is a no-op since all the contents of the cache are stored on disk, so removing them would have no benefit for memory pressure
  */
  public func onMemoryWarning() {}
  
  /**
  Initializes a new disk cache level
  
  - parameter path: The path to the disk storage. Defaults to a Carlos specific folder in the Caches sandbox folder.
  - parameter capacity: The total capacity in bytes for the disk cache. Defaults to 100 MB
  - parameter fileManager: The file manager to use. Defaults to the default NSFileManager. It's here mainly for dependency injection testing purposes.
  */
  public init(path: String = (CarlosGlobals.Caches as NSString).appendingPathComponent(CarlosGlobals.QueueNamePrefix + "default"), capacity: UInt64 = 100 * 1024 * 1024, fileManager: FileManager = FileManager.default) {
    self.path = path
    self.fileManager = fileManager
    self.capacity = capacity
    
    _ = try? fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: [:])
    
    cacheQueue.async { Void -> Void in
      self.calculateSize()
      self.controlCapacity()
    }
  }
  
  /**
  Asynchronously sets a value for the given key
  
  - parameter value: The value to save on disk
  - parameter key: The key for the value
  */
  public func set(_ value: T, forKey key: K) -> Future<()> {
    let result = Promise<()>()
    
    cacheQueue.async { Void -> Void in
      Logger.log("Setting a value for the key \(key.toString()) on the disk cache \(self)")
      result.mimic(self.setDataSync(value, key: key))
    }
    
    return result.future
  }
  
  /**
  Asynchronously gets the value for the given key
  
  - parameter key: The key for the value
  
  - returns: A Future where you can call onSuccess and onFailure to be notified of the result of the fetch
  */
  public func get(_ key: KeyType) -> Future<OutputType> {
    let request = Promise<OutputType>()
    
    cacheQueue.async { Void -> Void in
      let path = self.pathForKey(key)
      
      if let obj = NSKeyedUnarchiver.su_unarchiveObject(withFilePath: path) as? T {
        Logger.log("Fetched \(key.toString()) on disk level")
        GCD.main {
          request.succeed(obj)
        }
        _ = self.updateDiskAccessDateAtPath(path)
      } else {
        // Remove the file (maybe corrupted)
        _ = try? self.fileManager.removeItem(atPath: path)
        
        Logger.log("Failed fetching \(key.toString()) on the disk cache")
        GCD.main {
          request.fail(FetchError.valueNotInCache)
        }
      }
    }
    
    return request.future
  }
  
  /**
  Asynchronously clears the contents of the cache
  
  All the cached files will be removed from the disk storage
  */
  public func clear() {
    cacheQueue.async { Void -> Void in
      self.itemsInDirectory(self.path).forEach { filePath in
        _ = try? self.fileManager.removeItem(atPath: filePath)
      }
      self.calculateSize()
    }
  }
  
  // MARK: Private
  
  private func removeData(_ key: K) {
    cacheQueue.async {
      self.removeFileAtPath(self.pathForKey(key))
    }
  }
  
  private func pathForKey(_ key: K) -> String {
    return (path as NSString).appendingPathComponent(key.toString().MD5String())
  }
  
  private func sizeForFileAtPath(_ filePath: String) -> UInt64 {
    var size: UInt64 = 0
    
    do {
      let attributes: NSDictionary = try fileManager.attributesOfItem(atPath: filePath) as NSDictionary
      size = attributes.fileSize()
    } catch {}
    
    return size
  }
  
  private func calculateSize() {
    size = itemsInDirectory(path).reduce(0, { (accumulator, filePath) in
      accumulator + sizeForFileAtPath(filePath)
    })
  }
  
  private func controlCapacity() {
    if size > capacity {
      enumerateContentsOfDirectorySortedByAscendingModificationDateAtPath(path) { (URL, stop: inout Bool) in
        removeFileAtPath(URL.path)
        stop = size <= capacity
      }
    }
  }
  
  private func setDataSync(_ data: T, key: K) -> Future<()> {
    let result = Promise<()>()
    let path = pathForKey(key)
    let previousSize = sizeForFileAtPath(path)
    
    if NSKeyedArchiver.archiveRootObject(data, toFile: path) {
      _ = updateDiskAccessDateAtPath(path)
      
      let newSize = sizeForFileAtPath(path)
      if newSize > previousSize {
        size += newSize - previousSize
        controlCapacity()
      } else {
        size -= previousSize - newSize
      }
      
      result.succeed()
    } else {
      Logger.log("Failed to write key \(key.toString()) on the disk cache", .Error)
      result.fail(DiskCacheLevelError.diskArchiveWriteFailed)
    }
    
    return result.future
  }
  
  private func updateDiskAccessDateAtPath(_ path: String) -> Bool {
    var result = false
    
    do {
      try fileManager.setAttributes([
            FileAttributeKey.modificationDate: Date()
          ], ofItemAtPath: path)
      result = true
    } catch _ {}
    
    return result
  }
  
  private func removeFileAtPath(_ path: String) {
    do {
      if let attributes: NSDictionary = try fileManager.attributesOfItem(atPath: path) as NSDictionary? {
        try fileManager.removeItem(atPath: path)
        size -= attributes.fileSize()
      }
    } catch _ {}
  }
  
  private func itemsInDirectory(_ directory: String) -> [String] {
    var items: [String] = []
    
    do {
      items = try fileManager.contentsOfDirectory(atPath: directory).map {
        (directory as NSString).appendingPathComponent($0)
      }
    } catch _ {}
    
    return items
  }
  
  private func enumerateContentsOfDirectorySortedByAscendingModificationDateAtPath(_ path: String, usingBlock block: (URL, inout Bool) -> Void) {
    let property = URLResourceKey.contentModificationDateKey
    
    do {
      let directoryURL = URL(fileURLWithPath: path)
      let contents = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: [property], options: [])
      let sortedContents = contents.sorted(by: { (URL1, URL2) in
        var value1: AnyObject?
        do {
          try (URL1 as NSURL).getResourceValue(&value1, forKey: property)
        } catch _ {
          return true
        }
        
        var value2: AnyObject?
        do {
          try (URL2 as NSURL).getResourceValue(&value2, forKey: property)
        } catch _ {
          return false
        }
        
        if let date1 = value1 as? Date, let date2 = value2 as? Date {
          return date1.compare(date2) == .orderedAscending
        }
        
        return false
      })
      
      for value in sortedContents {
        var stop = false
        block(value, &stop)
        if stop {
          break
        }
      }
    } catch _ {}
  }
}
