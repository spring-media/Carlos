import Foundation

/// A simple logger to use instead of println with configurable output closure
public class Logger {
  public enum Level : String {
    case Debug = "Debug"
    case Info = "Info"
    case Warning = "Warning"
    case Error = "Error"
  }

  private static var queue = dispatch_queue_create(CarlosGlobals.QueueNamePrefix + "logger", DISPATCH_QUEUE_SERIAL)

  /**
  Called to output the log message. Override for custom logging.
  */
  public static var output: (String, Level) -> Void = { msg, level in
    dispatch_async(queue) {
      println("[Carlos][\(level.rawValue)]: \(msg)")
    }
  }

  /**
  Logs a message on the console
  
  :param: message The message to log
  
  :discussion: This method uses the output closure internally to output the message
  */
  public static func log(message: String, _ level: Level = Level.Debug) {
    //TODO: Should we always dispatch on the main queue? What happens if a client sets an output closure? We shouldn't want him to also create a queue just to make sure that all the operations he writes in the closure will be executed on the same (or main) queue..
    output(message, level)
  }
}