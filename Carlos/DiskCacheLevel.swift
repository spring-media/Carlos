import Foundation

/// This class is a disk cache level. It has a configurable total size that defaults to 100 MB.
public class DiskCacheLevel<K: StringConvertible, T: NSCoding>: CacheLevel {
  /// At the moment the disk cache level only accepts keys that can be converted to string values
  public typealias KeyType = K
  
  /// The output type of the cache, should conform to NSCoding
  public typealias OutputType = T
  
  private let path: String
  private var size: UInt64 = 0
  private let fileManager: NSFileManager
  
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
  public init(path: String = (CarlosGlobals.Caches as NSString).stringByAppendingPathComponent(CarlosGlobals.QueueNamePrefix + "default"), capacity: UInt64 = 100 * 1024 * 1024, fileManager: NSFileManager = NSFileManager.defaultManager()) {
    self.path = path
    self.fileManager = fileManager
    self.capacity = capacity
    
    _ = try? fileManager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: [:])
    
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
  public func set(value: T, forKey key: K) {
    cacheQueue.async { Void -> Void in
      Logger.log("Setting a value for the key \(key.toString()) on the disk cache \(self)")
      self.setDataSync(value, key: key)
    }
  }
  
  /**
  Asynchronously gets the value for the given key
  
  - parameter key: The key for the value
  
  - returns: A Future where you can call onSuccess and onFailure to be notified of the result of the fetch
  */
  public func get(key: KeyType) -> Future<OutputType> {
    let request = Promise<OutputType>()
    
    cacheQueue.async { Void -> Void in
      let path = self.pathForKey(key)
      
      if let obj = NSKeyedUnarchiver.su_unarchiveObjectWithFilePath(path) as? T {
        Logger.log("Fetched \(key.toString()) on disk level")
        GCD.main {
          request.succeed(obj)
        }
        self.updateDiskAccessDateAtPath(path)
      } else {
        // Remove the file (maybe corrupted)
        _ = try? self.fileManager.removeItemAtPath(path)
        
        Logger.log("Failed fetching \(key.toString()) on the disk cache")
        GCD.main {
          request.fail(FetchError.ValueNotInCache)
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
      for filePath in self.itemsInDirectory(self.path) {
        _ = try? self.fileManager.removeItemAtPath(filePath)
      }
      self.calculateSize()
    }
  }
  
  // MARK: Private
  
  private func removeData(key: K) {
    cacheQueue.async {
      self.removeFileAtPath(self.pathForKey(key))
    }
  }
  
  private func updateAccessDate(@autoclosure(escaping) getData: () -> T?, key: K) {
    cacheQueue.async { Void -> Void in
      let path = self.pathForKey(key)
      if !self.updateDiskAccessDateAtPath(path) && !self.fileManager.fileExistsAtPath(path) {
        if let data = getData() {
          self.setDataSync(data, key: key)
        }
      }
    }
  }
  
  private func pathForKey(key: K) -> String {
    return (path as NSString).stringByAppendingPathComponent(key.toString().MD5String())
  }
  
  private func sizeForFileAtPath(filePath: String) -> UInt64 {
    var size: UInt64 = 0
    
    do {
      let attributes: NSDictionary = try fileManager.attributesOfItemAtPath(filePath)
      size = attributes.fileSize()
    } catch {}
    
    return size
  }
  
  private func calculateSize() {
    size = itemsInDirectory(path).reduce(0, combine: { (accumulator, filePath) in
      accumulator + sizeForFileAtPath(filePath)
    })
  }
  
  private func controlCapacity() {
    if size > capacity {
      enumerateContentsOfDirectorySortedByAscendingModificationDateAtPath(path) { (URL, inout stop: Bool) in
        if let path = URL.path {
          removeFileAtPath(path)
          stop = size <= capacity
        }
      }
    }
  }
  
  private func setDataSync(data: T, key: K) {
    let path = pathForKey(key)
    let previousSize = sizeForFileAtPath(path)
    if !NSKeyedArchiver.archiveRootObject(data, toFile: path) {
      Logger.log("Failed to write key \(key.toString()) on the disk cache", .Error)
    }
    
    size += max(0, sizeForFileAtPath(path) - previousSize)
    
    controlCapacity()
  }
  
  private func updateDiskAccessDateAtPath(path: String) -> Bool {
    var result = false
    
    do {
      try fileManager.setAttributes([
            NSFileModificationDate: NSDate()
          ], ofItemAtPath: path)
      result = true
    } catch _ {}
    
    return result
  }
  
  private func removeFileAtPath(path: String) {
    do {
      if let attributes: NSDictionary = try fileManager.attributesOfItemAtPath(path) {
        try fileManager.removeItemAtPath(path)
        size -= attributes.fileSize()
      }
    } catch _ {}
  }
  
  private func itemsInDirectory(directory: String) -> [String] {
    var items: [String] = []
    
    do {
      items = try fileManager.contentsOfDirectoryAtPath(directory).map {
        (directory as NSString).stringByAppendingPathComponent($0)
      }
    } catch _ {}
    
    return items
  }
  
  private func enumerateContentsOfDirectorySortedByAscendingModificationDateAtPath(path: String, @noescape usingBlock block: (NSURL, inout Bool) -> Void) {
    let property = NSURLContentModificationDateKey
    
    do {
      let directoryURL = NSURL(fileURLWithPath: path)
      let contents = try fileManager.contentsOfDirectoryAtURL(directoryURL, includingPropertiesForKeys: [property], options: [])
      let sortedContents = contents.sort({ (URL1, URL2) in
        var value1: AnyObject?
        do {
          try URL1.getResourceValue(&value1, forKey: property)
        } catch _ {
          return true
        }
        
        var value2: AnyObject?
        do {
          try URL2.getResourceValue(&value2, forKey: property)
        } catch _ {
          return false
        }
        
        if let date1 = value1 as? NSDate, let date2 = value2 as? NSDate {
          return date1.compare(date2) == .OrderedAscending
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