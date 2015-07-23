import Foundation

/**
This class is a workaround for an issue with Swift where generic subclasses of NSOperation won't get the start() or main() func called.
*/
public class GenericOperation: ConcurrentOperation {
  public override func start() {
    genericStart()
  }
  
  /**
  The method to override if you have a generic subclass of NSOperation (more specifically of ConcurrentOperation), so that your start() method will be called after adding the operation itself to a NSOperationQueue
  */
  public func genericStart() {}
}