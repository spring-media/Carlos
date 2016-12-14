extension Future {
  /**
  Zips this Future with another Future`<U>` to obtain a Future of type (T,U)
   
  - parameter other: The other Future you want to zip
   
  - returns: A new Future of type (T, U) that will only succeed if both Futures succeed. It will fail or be canceled accordingly to its components
  */
  public func zip<U>(_ other: Future<U>) -> Future<(T, U)> {
    return flatMap { thisResult in
      other.map { otherResult in
        (thisResult, otherResult)
      }
    }
  }
  
  /**
   Zips this Future with a Result`<U>` to obtain a Future of type (T,U)
   
   - parameter other: The Result you want to zip
   
   - returns: A new Future of type (T, U) that will only succeed if both this Future and the Result succeed. It will fail or be canceled accordingly to its components
  */
  public func zip<U>(_ other: Result<U>) -> Future<(T, U)> {
    return other.flatMap { otherResult in
      self.map { thisResult in
        (thisResult, otherResult)
      }
    }
  }
}
