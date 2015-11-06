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