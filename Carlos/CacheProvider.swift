import Foundation

/**
A simple class with the purpose of providing standard caches
*/
public class CacheProvider {
  /**
  - returns: An initialized and configured CacheLevel that takes NSURL keys and stores NSData values. Network requests are pooled for efficiency
  */
  public static func dataCache() -> BasicCache<NSURL, NSData> {
    return MemoryCacheLevel() >>> DiskCacheLevel() >>> NetworkFetcher().pooled()
  }
}