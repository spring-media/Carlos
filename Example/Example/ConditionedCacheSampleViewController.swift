import Foundation
import UIKit

import Carlos
import Combine

enum ConditionError: Error {
  case globalKillSwitch
  case urlScheme
  
  func toString() -> String {
    switch self {
    case .globalKillSwitch:
      return "Global kill switch is on"
    case .urlScheme:
      return "URL Scheme is not HTTP"
    }
  }
}

final class ConditionedCacheSampleViewController: BaseCacheViewController {
  private var cache: BasicCache<URL, NSData>!
  private var globalKillSwitch = false
  
  private var cancellables = Set<AnyCancellable>()
  
  override func fetchRequested() {
    super.fetchRequested()
    
    cache.get(URL(string: urlKeyField?.text ?? "")!)
      .sink(receiveCompletion: { completion in
        if case let .failure(error) = completion {
          self.eventsLogView.text = "\(self.eventsLogView.text!)Failed because of condition\n"
          print(error)
        }
      }, receiveValue: { _ in })
      .store(in: &cancellables)
  }
  
  override func titleForScreen() -> String {
    return "Conditioned cache"
  }
  
  @IBAction func killSwitchValueChanged(_ sender: UISwitch) {
    globalKillSwitch = sender.isOn
  }
  
  override func setupCache() {
    super.setupCache()
    
    cache = simpleCache().conditioned { key -> AnyPublisher<Bool, Error> in
      if self.globalKillSwitch {
        return Fail(error: ConditionError.globalKillSwitch).eraseToAnyPublisher()
      } else if key.scheme != "http" {
        return Fail(error: ConditionError.urlScheme).eraseToAnyPublisher()
      }
      
      return Just(true).setFailureType(to: Error.self).eraseToAnyPublisher()

    }
  }
}
