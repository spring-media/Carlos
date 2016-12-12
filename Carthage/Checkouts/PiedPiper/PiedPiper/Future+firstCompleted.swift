import Foundation

extension Sequence where Iterator.Element: Async {
  /**
   Starts a race between the Futures composing this sequence
   
   - returns: A new Future that will behave as the first completed future of this sequence
   */
  public func firstCompleted() -> Future<Iterator.Element.Value> {
    let result = Promise<Iterator.Element.Value>()
    
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
