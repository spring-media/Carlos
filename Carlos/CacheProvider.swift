import Foundation

/**
A simple class with the purpose of providing standard caches
*/
open class CacheProvider {
  /// A shared data cache instance
  open static let sharedDataCache: BasicCache<URL, Data> = CacheProvider.dataCache()
  
  /// A shared JSON cache instance
  open static let sharedJSONCache: BasicCache<URL, AnyObject> = CacheProvider.JSONCache()
  
  /**
  - returns: An initialized and configured CacheLevel that takes NSURL keys and stores NSData values. Network requests are pooled for efficiency. Keep in mind that calling this method twice returns two different instances. You should take care of retaining the result or use `sharedDataCache` instead
  */
  open static func dataCache() -> BasicCache<URL, Data> {
    return MemoryCacheLevel() >>> (DiskCacheLevel() >>> NetworkFetcher()).pooled()
  }
  
  /**
  - returns: An initialized and configured CacheLevel that takes NSURL keys and stores JSON values in the form of AnyObject. Network requests are pooled for efficiency. Keep in mind that calling this method twice returns two different instances. You should take care of retaining the result or use `sharedJSONCache` instead
  */
  open static func JSONCache() -> BasicCache<URL, AnyObject> {
    return dataCache() =>> JSONTransformer()
  }
}
