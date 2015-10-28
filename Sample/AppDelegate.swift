import UIKit
import Carlos

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    return true
  }
}

func simpleCache() -> BasicCache<NSURL, NSData> {
  return CacheProvider.dataCache()
}

func delayedNetworkCache() -> BasicCache<NSURL, NSData> {
  return MemoryCacheLevel() >>> DiskCacheLevel() >>> DelayedNetworkFetcher()
}