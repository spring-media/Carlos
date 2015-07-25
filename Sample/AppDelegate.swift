import UIKit
import Carlos

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
    return true
  }
}

func simpleCache() -> BasicCache<NSURL, NSData> {
  return ({ (input: NSURL) -> String in
    input.absoluteString!
  } =>> (MemoryCacheLevel() >>> DiskCacheLevel())) >>> NetworkFetcher()
}

func delayedNetworkCache() -> BasicCache<NSURL, NSData> {
  return ({ (input: NSURL) -> String in
    input.absoluteString!
  } =>> (MemoryCacheLevel() >>> DiskCacheLevel())) >>> DelayedNetworkFetcher()
}