import Cocoa
import Carlos
import OpenCombine

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  let cache = CacheProvider.dataCache()
  
  private var cancellables = Set<AnyCancellable>()

  func applicationDidFinishLaunching(_ notification: Notification) {
    cache.get(URL(string: "https://github.com/WeltN24/Carlos")!)
      .sink(receiveCompletion: { completion in
        if case let .failure(error) = completion {
          print("Got the following error from the data cache:")
          print(error)
        }
      }, receiveValue: { value in
        print("Got the following string from the data cache:")
        print(String(describing: String(data: value as Data, encoding: .utf8)))
      })
      .store(in: &cancellables)
  }
}
