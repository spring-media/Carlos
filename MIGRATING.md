## Migrating from 0.6 to 0.7

##### - Please note that with `Carlos` 0.7 the `Future` and `Promise`s code has been moved to a new framework. 

- If you use `CocoaPods` or `Carthage`, you will just have to add a `import PiedPiper` line everywhere you make use of Carlos' `Future`s. 
- If you did a submodule integration, please add `PiedPiper` as `Embedded binary` to your target.
- If you did a manual integration, please make sure that all the files missing from your target are re-added from the `Futures` folder.

##### - Check all your usages of `onCompletion` and replace the tuple `(value, error)` with the value `result`. Code will look like the following:

*Before*
```swift
future.onCompletion { (value, error) in
  if let value = value {
    //handle success case
  } else if let error = error {
  	//handle error case
  } else {
    //handle cancelation case
  }
}
```

*Now*
```swift
future.onCompletion { result in
  switch result {
  case .Success(let value):
     //handle success case
  case .Error(let error):
    //handle error case
  case .Cancelled:
    //handle cancelation case
  }
}
```

##### - Check all your usages of closures in the API. Methods taking closures instead of `Fetcher`, `CacheLevel` or `OneWayTransformer` values have been deprecated.

## Migrating from 0.4 to 0.5

##### - Rename all your usages of `CacheRequest` to `Future`
##### - If you created come custom `CacheLevel` or `Fetcher`, you should internally use `Promise` instead of `Future` so that you can control when the request can `fail` or `succeed`. `Future` is in fact a read-only version of `Promise`

*Before*
```swift
class MyCustomLevel: Fetcher {
  typealias KeyType = String
  typealias OutputType = String

  func get(key: String) -> CacheRequest<String> {
    let request = CacheRequest<String>()
   
    //Do stuff...
    request.succeed("Yay!")

    return request
  }
}
```

*Now*
```swift
class MyCustomLevel: Fetcher {
  typealias KeyType = String
  typealias OutputType = String

  func get(key: String) -> Future<String> {
    let request = Promise<String>()
   
    //Do stuff...
    request.succeed("Yay!")

    return request.future
  }
}
```

##### - If you created some custom `OneWayTransformer` or `TwoWayTransformer`, you should return `Future` now. This means that you have to wrap simple return values into `Future` instances

*Before*
```swift
let transformer = OneWayTransformationBox<String, String>(transform: { $0.uppercaseString })
```

*Now*
```swift
let transformer = OneWayTransformationBox<String, String>(transform: { Promise(value: $0.uppercaseString).future })
```

##### - If you used the `conditioned` API, the same async changes apply

*Before*
```swift
let conditionedCache = myCache.conditioned { key in 
  //whatever
  return true
}
```

*Now*
```swift
let conditionedCache = myCache.conditioned { key in
  return Promise(value: true).future
}
```

##### - If you use global functions, please consider using protocol extensions instead. Global functions are now **deprecated** and will be discontinued in `Carlos 1.0`

For example:

*Before*
```swift
let cache = compose(firstLevel, secondLevel)
```

*Now*
```swift
let cache = firstLevel.compose(secondLevel)
```