import UIKit
import Carlos

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    return true
  }
}

func simpleCache() -> BasicCache<URL, NSData> {
  return CacheProvider.dataCache()
}

func delayedNetworkCache() -> BasicCache<URL, NSData> {
  return MemoryCacheLevel() >>> DiskCacheLevel() >>> DelayedNetworkFetcher()
}
