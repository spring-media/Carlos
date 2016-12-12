import Foundation
import PiedPiper

/// A simple logger to use instead of println with configurable output closure
open class Logger {
  /// The level of the logged message
  public enum Level : String {
    case Debug = "Debug"
    case Info = "Info"
    case Warning = "Warning"
    case Error = "Error"
  }

  fileprivate static let queue = GCD.serial(CarlosGlobals.QueueNamePrefix + "logger")

  /**
  Called to output the log message. Override for custom logging.
  */
  open static var output: (String, Level) -> Void = { (msg, level) in
    queue.async {
      print("[Carlos][\(level.rawValue)]: \(msg)")
    }
  }

  /**
  Logs a message on the console
  
  - parameter message: The message to log
  
  This method uses the output closure internally to output the message. The closure is always dispatched on the main queue
  */
  open static func log(_ message: String, _ level: Level = Level.Debug) {
    GCD.main {
      self.output(message, level)
    }
  }
}
