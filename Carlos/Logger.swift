import Foundation

/// A simple logger to use instead of println with configurable output closure
public class Logger {
  /// The level of the logged message
  public enum Level : String {
    case Debug = "Debug"
    case Info = "Info"
    case Warning = "Warning"
    case Error = "Error"
  }

  private static let queue = dispatch_queue_create(CarlosGlobals.QueueNamePrefix + "logger", DISPATCH_QUEUE_SERIAL)

  /**
  Called to output the log message. Override for custom logging.
  */
  public static var output: (String, Level) -> Void = { (msg, level) in
    dispatch_async(queue) {
      print("[Carlos][\(level.rawValue)]: \(msg)")
    }
  }

  /**
  Logs a message on the console
  
  - parameter message: The message to log
  
  :discussion: This method uses the output closure internally to output the message. The closure is always dispatched on the main queue
  */
  public static func log(message: String, _ level: Level = Level.Debug) {
    dispatch_async(dispatch_get_main_queue()) {
      self.output(message, level)
    }
  }
}