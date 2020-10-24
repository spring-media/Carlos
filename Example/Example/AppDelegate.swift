import Carlos
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    true
  }
}

func simpleCache() -> BasicCache<URL, NSData> {
  CacheProvider.dataCache()
}

func delayedNetworkCache() -> BasicCache<URL, NSData> {
  MemoryCacheLevel().compose(DiskCacheLevel()).compose(DelayedNetworkFetcher())
}
