import Foundation

/// A provider for the built-int caches.
public enum CacheProvider {
  /// A shared data cache instance
  public static let sharedDataCache: BasicCache<URL, NSData> = CacheProvider.dataCache()

  /// A shared JSON cache instance
  public static let sharedJSONCache: BasicCache<URL, AnyObject> = CacheProvider.JSONCache()

  /// A shared image cache instance
  public static let sharedImageCache: BasicCache<URL, CarlosImage> = CacheProvider.imageCache()

  /// - Returns: An initialized and configured CacheLevel that takes URL keys and stores NSData values.
  ///           Network requests are pooled for efficiency. Keep in mind that calling this method twice returns two different instances.
  ///           You should take care of retaining the result or use `sharedDataCache` instead.
  public static func dataCache() -> BasicCache<URL, NSData> {
    MemoryCacheLevel<URL, NSData>()
      .compose(
        DiskCacheLevel<URL, NSData>().compose(NetworkFetcher())
          .pooled()
      )
  }

  /// - Returns: An initialized and configured CacheLevel that takes URL keys and stores JSON values in the form of AnyObject.
  ///            Network requests are pooled for efficiency. Keep in mind that calling this method twice returns two different instances.
  ///            You should take care of retaining the result or use `sharedJSONCache` instead
  public static func JSONCache() -> BasicCache<URL, AnyObject> {
    dataCache().transformValues(JSONTransformer())
  }

  /// - Returns: An initialized and configured `CacheLevel` that takes URL keys and stores `CarlosImage` (UIImage | NSImage) values.
  ///            Network requests are pooled for efficiency. Keep in mind that calling this method twice returns two different instances.
  ///            You should take care of retaining the result or use `sharedImageCache` instead
  public static func imageCache() -> BasicCache<URL, CarlosImage> {
    MemoryCacheLevel<URL, CarlosImage>()
      .compose(DiskCacheLevel<URL, CarlosImage>())
      .compose(
        NetworkFetcher()
          .pooled()
          .transformValues(ImageTransformer())
      )
  }
}
