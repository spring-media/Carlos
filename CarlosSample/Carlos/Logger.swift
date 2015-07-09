import Foundation

/// A simple logger to use instead of println so that logs are only printed when the flag CARLOS_DEBUG is defined
class Logger {
  /**
  Logs a message on the console
  
  :param: message The message to log
  
  :discussion: This method only logs if the CARLOS_DEBUG flag is defined when compiling
  */
  static func log(message: String) {
    #if CARLOS_DEBUG
    println(message)
    #endif
  }
}