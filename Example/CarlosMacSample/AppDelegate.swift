import Cocoa
import Carlos

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  let cache = CacheProvider.dataCache()

  func applicationDidFinishLaunching(_ notification: Notification) {
    cache.get(URL(string: "https://github.com/WeltN24/Carlos")!)
      .onSuccess {
        print("Got the following string from the data cache:")
        print(String(describing: String(data: $0 as Data, encoding: .utf8)))
      }
      .onFailure {
        print("Got the following error from the data cache:")
        print($0)
      }
  }
}
