import Foundation

extension SequenceType where Generator.Element: Async {
  /**
   Starts a race between the Futures composing this sequence
   
   - returns: A new Future that will behave as the first completed future of this sequence
   */
  public func firstCompleted() -> Future<Generator.Element.Value> {
    let result = Promise<Generator.Element.Value>()
    
    forEach { element in
      result.mimic(element.future)
    }
    
    result.onCancel {
      self.forEach { item in
        item.future.cancel()
      }
    }
    
    return result.future
  }
}