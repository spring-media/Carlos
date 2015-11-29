import Foundation

/**
A simple class with the purpose of providing standard caches
*/
public class CacheProvider {
  /// A shared data cache instance
  public static let sharedDataCache: BasicCache<NSURL, NSData> = CacheProvider.dataCache()
  
  /// A shared JSON cache instance
  public static let sharedJSONCache: BasicCache<NSURL, AnyObject> = CacheProvider.JSONCache()
  
  /**
  - returns: An initialized and configured CacheLevel that takes NSURL keys and stores NSData values. Network requests are pooled for efficiency. Keep in mind that calling this method twice returns two different instances. You should take care of retaining the result or use `sharedDataCache` instead
  */
  public static func dataCache() -> BasicCache<NSURL, NSData> {
    return MemoryCacheLevel() >>> (DiskCacheLevel() >>> NetworkFetcher()).pooled()
  }
  
  /**
  - returns: An initialized and configured CacheLevel that takes NSURL keys and stores JSON values in the form of AnyObject. Network requests are pooled for efficiency. Keep in mind that calling this method twice returns two different instances. You should take care of retaining the result or use `sharedJSONCache` instead
  */
  public static func JSONCache() -> BasicCache<NSURL, AnyObject> {
    return dataCache() =>> JSONTransformer()
  }
}