import Cocoa
import CarlosMac

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  let cache = CacheProvider.dataCache()
  
  func applicationDidFinishLaunching(aNotification: NSNotification) {
    cache.get(NSURL(string: "https://github.com/WeltN24/Carlos")!)
      .onSuccess {
        print("Got the following string from the data cache:")
        print(NSString(data: $0, encoding: NSUTF8StringEncoding))
      }
      .onFailure {
        print("Got the following error from the data cache:")
        print($0)
      }
  }
}
