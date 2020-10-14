# Carlos

[![Build Status](https://travis-ci.org/spring-media/Carlos.svg?branch=master)](https://travis-ci.org/spring-media/Carlos)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

> A simple but flexible cache, written in Swift for `iOS 13+` and `WatchOS 6` apps.

# Breaking Changes
Carlos 1.0.0 has been migrated from PiedPiper dependency to Combine hence the minimum supported platfroms versions are equal to the Combine's minimum supported platforms versions. See the releases page for more information. 

# Contents of this Readme

- [What is Carlos?](#what-is-carlos)
- [Installation](#installation)
- [Playground](#playground)
- [Requirements](#requirements)
- [Usage](#usage)
  - [Usage examples](#usage-examples)
  - [Creating requests](#creating-requests)
  - [Key transformations](#key-transformations)
  - [Value transformations](#value-transformations)
  - [Output post-processing](#post-processing-output)
  - [Conditioned output post-processing](#conditioned-output-post-processing)
  - [Conditioned value transformation](#conditioned-value-transformation)
  - [Composing transformers](#composing-transformers)
  - [Pooling requests](#pooling-requests)
  - [Batching get requests](#batching-get-requests)
  - [Limiting concurrent requests](#limiting-concurrent-requests)
  - [Conditioning caches](#conditioning-caches)
  - [Dispatching with GCD](#dispatching-caches)
  - [Multiple cache lanes](#multiple-cache-lanes)
  - [Listening to memory warnings](#listening-to-memory-warnings)
  - [Normalizing cache levels](#normalization)
  - [Creating custom levels](#creating-custom-levels)
  - [Creating custom fetchers](#creating-custom-fetchers)
  - [Built-in levels](#built-in-levels)
  - [Logging](#logging)
- [Tests](#tests)
- [Future development](#future-development)
- [Apps using Carlos](#apps-using-carlos)
- [Authors](#authors)
- [License](#license)
- [Acknowledgements](#acknowledgements)

## What is Carlos?

`Carlos` is a small set of classes and functions to **realize custom, flexible and powerful cache layers** in your application.

With a Functional Programming vocabulary, Carlos makes for a monoidal cache system. You can check the best explanation of how that is realized [here](https://bkase.github.io/slides/composable-caching-swift/) or in [this video](https://www.youtube.com/watch?v=8uqXuEZLyUU), thanks to [@bkase](https://github.com/bkase) for the slides.

By default, **`Carlos` ships with an in-memory cache, a disk cache, a simple network fetcher and a `NSUserDefaults` cache** (the disk cache is inspired by [HanekeSwift](https://github.com/Haneke/HanekeSwift)).

With `Carlos` you can:

- **[create levels and fetchers](#creating-custom-levels)** depending on your needs
- [combine levels](#usage-examples)
- Cancel pending requests
- [transform the key](#key-transformations) each level will get, [or the values](#value-transformations) each level will output (this means you're free to implement every level independing on how it will be used later on). Some common value transformers are already provided with `Carlos`
- Apply [post-processing steps](#post-processing-output) to a cache level, for example sanitizing the output or resizing images
- [Post-processing steps](#conditioned-output-post-processing) and [value transformations](#conditioned-value-transformation) can also be applied conditionally on the key used to fetch the value
- [react to memory pressure events](#listening-to-memory-warnings) in your app
- **automatically populate upper levels when one of the lower levels fetches a value** for a key, so the next time the first level will already have it cached
- enable or disable specific levels of your composed cache depending on [boolean conditions](#conditioning-caches)
- easily [**pool requests**](#pooling-requests) so you don't have to care whether 5 requests with the same key have to be executed by an expensive cache level before even only 1 of them is done. `Carlos` can take care of that for you
- [batch get requests](#batching-get-requests) to only get notified when all of them are done
- setup [multiple lanes](#multiple-cache-lanes) for complex scenarios where, depending on certain keys or conditions, different caches should be used
- have a type-safe complex cache that won't even compile if the code doesn't satisfy the type requirements

## Installation

### Swift Package Manager (Preferred)
Add `Carlos` to your project through the Xcode or add the following line to your package dependencies: 
```swift
.package("https://github.com/spring-media/Carlos", from: "1.0.0")
```

### CocoaPods
`Carlos` is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```
pod "Carlos", :git => "https://github.com/spring-media/Carlos"
```

### Carthage
`Carthage` is also supported.

## Requirements
- iOS 13.0+
- WatchOS 6+
- Xcode 12+

## Usage
To run the example project, clone the repo.

### Usage examples
```swift
let cache = MemoryCacheLevel<String, NSData>().compose(DiskCacheLevel())
```

This line will generate a cache that takes `String` keys and returns `NSData` values.
Setting a value for a given key on this cache will set it for both the levels.
Getting a value for a given key on this cache will first try getting it on the memory level, and if it cannot find one, will ask the disk level.
In case both levels don't have a value, the request will fail.
In case the disk level can fetch a value, this will also be set on the memory level so that the next fetch will be faster.

`Carlos` comes with a `CacheProvider` class so that standard caches are easily accessible.

- `CacheProvider.dataCache()` to create a cache that takes `URL` keys and returns `NSData` values
- `CacheProvider.imageCache()` to create a cache that takes `URL` keys and returns `UIImage` values
- `CacheProvider.JSONCache()` to create a cache that takes `URL` keys and returns `AnyObject` values (that should be then safely casted to arrays or dictionaries depending on your application)

The above methods always create new instances (so calling `CacheProvider.imageCache()` twice doesn't return the same instance, even though the disk level will be effectively shared because it will use the same folder on disk, but this is a side-effect and should not be relied upon) and you should take care of retaining the result in your application layer.
If you want to always get the same instance, you can use the following accessors instead:

- `CacheProvider.sharedDataCache` to retrieve a shared instance of a data cache
- `CacheProvider.sharedImageCache` to retrieve a shared instance of an image cache
- `CacheProvider.sharedJSONCache` to retrieve a shared instance of a JSON cache

### Creating requests

To fetch a value from a cache, use the `get` method.

```swift
cache.get("key")
  .sink( 
    receiveCompletion: { completion in 
      if case let .failure(error) = completion {
        print("An error occurred :( \(error)")
      }
    },
    receiveValue: { value in 
      print("I found \(value)!")
    }
  )
```

A request can also be canceled with the `cancel()` method, and you can be notified of this event by calling `onCancel` on a given request:

```swift
let cancellable = cache.get(key)
                    .handleEvents(receiveCancel: { 
                      print("Looks like somebody canceled this request!")
                    })
                    .sink(...)
[... somewhere else]
cancellable.cancel()
```

This cache is not very useful, though. It will never *actively* fetch values, just store them for later use. Let's try to make it more interesting:

```swift
let cache = MemoryCacheLevel()
              .compose(DiskCacheLevel())
              .compose(NetworkFetcher())
```

This will create a cache level that takes `URL` keys and stores `NSData` values (the type is inferred from the `NetworkFetcher` hard-requirement of `URL` keys and `NSData` values, while `MemoryCacheLevel` and `DiskCacheLevel` are much more flexible as described later).

### Key transformations

Key transformations are meant to make it possible to plug cache levels in whatever cache you're building.

Let's see how they work:

```swift    
// Define your custom ErrorType values
enum URLTransformationError: Error {
    case invalidURLString
}

let transformedCache = NetworkFetcher().transformKeys(
  OneWayTransformationBox(
    transform: {
      Future { promise in 
        let url = URL(string: $0) {
          promise(.success(url))
        } else {
          promise(.failure(URLTransformationError.invalidURLString))
        }
      }
    }
  )
)
```

With the line above, we're saying that all the keys coming into the NetworkFetcher level have to be transformed to `URL` values first. We can now plug this cache into a previously defined cache level that takes `String` keys:

```swift
let cache = MemoryCacheLevel<String, NSData>().compose(transformedCache)
```

If this doesn't look very safe (one could always pass string garbage as a key and it won't magically translate to a `URL`, thus causing the `NetworkFetcher` to silently fail), we can still use a domain specific structure as a key, assuming it contains both `String` and `URL` values:

```swift
struct Image {
  let identifier: String
  let URL: Foundation.URL
}

let imageToString = OneWayTransformationBox(transform: { (image: Image) -> AnyPublisher<String, String> in
    Just(image.identifier).eraseToAnyPublisher()
})

let imageToURL = OneWayTransformationBox(transform: { (image: Image) -> AnyPublisher<URL> in
    Just(image.URL).eraseToAnyPublisher()
})

let memoryLevel = MemoryCacheLevel<String, NSData>().transformKeys(imageToString)
let diskLevel = DiskCacheLevel<String, NSData>().transformKeys(imageToString)
let networkLevel = NetworkFetcher().transformKeys(imageToURL)

let cache = memoryLevel.compose(diskLevel).compose(networkLevel)
```

Now we can perform safe requests like this:

```swift
let image = Image(identifier: "550e8400-e29b-41d4-a716-446655440000", URL: URL(string: "http://goo.gl/KcGz8T")!)

cache.get(image).sink {
  print("Found \(value)!")
}
```

Since `Carlos 0.5` you can also apply conditions to `OneWayTransformers` used for key transformations. Just call the `conditioned` function on the transformer and pass your condition. The condition can also be asynchronous and has to return a `AnyPublisher<Bool, Error>`, having the chance to return a specific error for the failure of the transformation.

```swift
let transformer = OneWayTransformationBox<String, URL>(transform: { key in
  Future { promise in 
    if let value = URL(string: key) {
      promise(.success(value))
    } else {
      promise(.failure(MyError.stringIsNotURL))
    }
  }.eraseToAnyPublisher()
}).conditioned { key in
  Just(key)
    .filter { $0.rangeOfString("http") != nil }
    .eraseToAnyPublisher()
}

let cache = CacheProvider.imageCache().transformKeys(transformer)
```

That's not all, though.

What if our disk cache only stores `Data`, but we want our memory cache to conveniently store `UIImage` instances instead?

### Value transformations

Value transformers let you have a cache that (let's say) stores `Data` and mutate it to a cache that stores `UIImage` values. Let's see how:

```swift
let dataTransformer = TwoWayTransformationBox(transform: { (image: UIImage) -> AnyPublisher<Data, Error> in
    Just(UIImagePNGRepresentation(image)).eraseToAnyPublisher()
}, inverseTransform: { (data: Data) -> AnyPublisher<UIImage, Error> in
    Just(UIImage(data: data)!).eraseToAnyPublisher()
})

let memoryLevel = MemoryCacheLevel<String, UIImage>().transformKeys(imageToString).transformValues(dataTransformer)
```

This memory level can now replace the one we had before, with the difference that it will internally store `UIImage` values!

Keep in mind that, as with key transformations, if your transformation closure fails (either the forward transformation or the inverse transformation), the cache level will be skipped, as if the fetch would fail. Same considerations apply for `set` calls.

`Carlos` comes with some value transformers out of the box, for example:

- `JSONTransformer` to serialize `NSData` instances into JSON
- `ImageTransformer` to serialize `NSData` instances into `UIImage` values (not available on the Mac OS X framework)
- `StringTransformer` to serialize `NSData` instances into `String` values with a given encoding
- Extensions for some Cocoa classes (`DateFormatter`, `NumberFormatter`, `MKDistanceFormatter`) so that you can use customized instances depending on your needs.

As of `Carlos 0.4`, it's possible to transform values coming out of `Fetcher` instances with just a `OneWayTransformer` (as opposed to the required `TwoWayTransformer` for normal `CacheLevel` instancess. This is because the `Fetcher` protocol doesn't require `set`).
This means you can easily chain `Fetcher`s that get a JSON from the internet and transform their output to a model object (for example a `struct`) into a complex cache pipeline without having to create a dummy inverse transformation just to satisfy the requirements of the `TwoWayTransformer` protocol.

As of `Carlos 0.5`, all transformers natively support asynchronous computation, so you can have expensive transformations in your custom transformers without blocking other operations. In fact, the `ImageTransformer` that comes out of the box processes image transformations on a background queue.

As of `Carlos 0.5` you can also apply conditions to `TwoWayTransformers` used for value transformations. Just call the `conditioned` function on the transformer and pass your conditions (one for the forward transformation, one for the inverse transformation). The conditions can also be asynchronous and have to return a `AnyPublisher<Bool, Error>`, having the chance to return a specific error for the failure of the transformation.

```swift
let transformer = JSONTransformer().conditioned({ input in
  Just(myCondition).eraseToAnyPublisher()
}, inverseCondition: { input in
  Just(myCondition)eraseToAnyPublisher()
})

let cache = CacheProvider.dataCache().transformValues(transformer)
```

### Post-processing output

In some cases your cache level could return the right value, but in a sub-optimal format. For example, you would like to sanitize the output you're getting from the Cache as a whole, independently of the exact layer that returned it.

For these cases, the `postProcess` function introduced with `Carlos 0.4` could come helpful.
The function is available as a protocol extension of the `CacheLevel` protocol.

The `postProcess` function takes a `CacheLevel` and a `OneWayTransformer` with `TypeIn == TypeOut` as parameters and outputs a decorated `BasicCache` with the post-processing step embedded in.

```swift
// Let's create a simple "to uppercase" transformer
let transformer = OneWayTransformationBox<NSString, String>(transform: { Just($0.uppercased() as String).eraseToAnyPublisher() })

// Our memory cache
let memoryCache = MemoryCacheLevel<String, NSString>()

// Our decorated cache
let transformedCache = memoryCache.postProcess(transformer)

// Lowercase value set on the memory layer
memoryCache.set("test String", forKey: "key")

// We get the lowercase value from the undecorated memory layer
memoryCache.get("key").sink { value in
  let x = value
}

// We get the uppercase value from the decorated cache, though
transformedCache.get("key").sink { value in
  let x = value
}
```

Since `Carlos 0.5` you can also apply conditions to `OneWayTransformers` used for post processing transformations. Just call the `conditioned` function on the transformer and pass your condition. The condition can also be asynchronous and has to return a `AnyPublisher<Bool, Error>`, having the chance to return a specific error for the failure of the transformation. Keep in mind that the condition will actually take the output of the cache as the input, not the key used to fetch this value! If you want to apply conditions based on the key, use `conditionedPostProcess` instead, but keep in mind this doesn't support using `OneWayTransformer` instances yet.

```swift
let processer = OneWayTransformationBox<NSData, NSData>(transform: { value in
      Future { promise in 
        if let value = String(data: value as Data, encoding: .utf8)?.uppercased().data(using: .utf8) as NSData? {
          promise(.success(value))
        } else {
          promise(.failure(FetchError.conditionNotSatisfied))
        }
      }
    }).conditioned { value in
      Just(value.length < 1000).eraseToAnyPublisher()
    }

let cache = CacheProvider.dataCache().postProcess(processer)
```

### Conditioned output post-processing

Extending the case for simple [output post-processing](#post-processing-output), you can also apply conditional transformations based on the key used to fetch the value.

For these cases, the `conditionedPostProcess` function introduced with `Carlos 0.6` could come helpful.
The function is available as a protocol extension of the `CacheLevel` protocol.

The `conditionedPostProcess` function takes a `CacheLevel` and a conditioned transformer conforming to `ConditionedOneWayTransformer` as parameters and outputs a decorated `CacheLevel` with the conditional post-processing step embedded in.

```swift

// Our memory cache
let memoryCache = MemoryCacheLevel<String, NSString>()

// Our decorated cache
let transformedCache = memoryCache.conditionedPostProcess(ConditionedOneWayTransformationBox(conditionalTransformClosure: { (key, value) in
	if key == "some sentinel value" {
	    return Just(value.uppercased()).eraseToAnyPublisher()
	} else {
	    return Just(value).eraseToAnyPublisher()
	}
})

// Lowercase value set on the memory layer
memoryCache.set("test String", forKey: "some sentinel value")

// We get the lowercase value from the undecorated memory layer
memoryCache.get("some sentinel value").sink { value in
  let x = value
}

// We get the uppercase value from the decorated cache, though
transformedCache.get("some sentinel value").sink { value in
  let x = value
}
```

### Conditioned value transformation

Extending the case for simple [value transformation](#value-transformations), you can also apply conditional transformations based on the key used to fetch or set the value.

For these cases, the `conditionedValueTransformation` function introduced with `Carlos 0.6` could come helpful.
The function is available as a protocol extension of the `CacheLevel` protocol.

The `conditionedValueTransformation` function takes a `CacheLevel` and a conditioned transformer conforming to `ConditionedTwoWayTransformer` as parameters and outputs a decorated `CacheLevel` with a modified `OutputType` (equal to the transformer's `TypeOut`, as in the normal value transformation case) with the conditional value transformation step embedded in.

```swift

// Our memory cache
let memoryCache = MemoryCacheLevel<String, NSString>()

// Our decorated cache
let transformedCache = memoryCache.conditionedValueTransformation(ConditionedTwoWayTransformationBox(conditionalTransformClosure: { (key, value) in
	if key == "some sentinel value" {
	    return Just(1).eraseToAnyPublisher()
	} else {
	    return Just(0).eraseToAnyPublisher()
	}
}, conditionalInverseTransformClosure: { (key, value) in
    if key > 0 {
	    return Just("Positive").eraseToAnyPublisher()
	} else {
		return Just("Null or negative").eraseToAnyPublisher()
	}
})

// Value set on the memory layer
memoryCache.set("test String", forKey: "some sentinel value")

// We get the same value from the undecorated memory layer
memoryCache.get("some sentinel value").sink { value in
  let x = value
}

// We get 1 from the decorated cache, though
transformedCache.get("some sentinel value").sink { value in
  let x = value
}

// We set "Positive" on the decorated cache
transformedCache.set(5, forKey: "test")
```

### Composing transformers

As of `Carlos 0.4`, it's possible to compose multiple `OneWayTransformer` objects.
This way, one can create several transformer modules to build a small library and then combine them as more convenient depending on the application.

You can compose the transformers in the same way you do with normal `CacheLevel`s: with the `compose` protocol extension:

```swift
let firstTransformer = ImageTransformer() // NSData -> UIImage
let secondTransformer = ImageTransformer().invert() // Trivial UIImage -> NSData

let identityTransformer = firstTransformer.compose(secondTransformer)
```

The same approach can be applied to `TwoWayTransformer` objects (that by the way are already `OneWayTransformer` as well).

Many transformer modules will be provided by default with `Carlos`.

### Pooling requests

When you have a working cache, but some of your levels are expensive (say a Network fetcher or a database fetcher), **you may want to pool requests in a way that multiple requests for the same key, coming together before one of them completes, are grouped so that when one completes all of the other complete as well without having to actually perform the expensive operation multiple times**.

This functionality comes with `Carlos`.

```swift
let cache = (memoryLevel.compose(diskLevel).compose(networkLevel)).pooled()
```

Keep in mind that the key must conform to the `Hashable` protocol for the `pooled` function to work:


```swift
extension Image: Hashable {
  var hashValue: Int {
    return identifier.hashValue
  }
}

extension Image: Equatable {}

func ==(lhs: Image, rhs: Image) -> Bool {
  return lhs.identifier == rhs.identifier && lhs.URL == rhs.URL
}
```

Now we can execute multiple fetches for the same `Image` value and be sure that only one network request will be started.

### Batching get requests

Since `Carlos 0.7` you can pass a list of keys to your `CacheLevel` through `batchGetSome`.
This returns a `AnyPublisher` that succeeds when all the requests for the specified keys *complete*, not necessarily succeeding. You will only get the successful values in the success callback, though.

Since `Carlos 0.9` you can transform your `CacheLevel` into one that takes a list of keys through `allBatch`.
Calling `get` on such a `CacheLevel` returns a `AnyPublisher` that succeeds only when the requests for **all** of the specified keys succeed, and fails **as soon as one** of the requests for the specified keys fails.
If you cancel the `AnyPublisher` returned by this `CacheLevel`, all of the pending requests are canceled, too.

An example of the usage:

```swift
let cache = MemoryCacheLevel<String, Int>()

for iter in 0..<99 {
  cache.set(iter, forKey: "key_\(iter)")
}

let keysToBatch = (0..<100).map { "key_\($0)" }

cache.batchGetSome(keysToBatch).sink(
    receiveCompletion: { completion in 
        print("Failed because \($0)")
    },
    receiveValue: { values in 
        print("Got \(values.count) values in total")
    }
)
```

In this case the `allBatch().get` call would fail because there are only 99 keys set and the last request will make the whole batch fail, with a `valueNotInCache` error. The `batchGetSome().get` will succeed instead, printing `Got 99 values in total`.

Since `allBatch` returns a new `CacheLevel` instance, it can be composed or transformed just like any other cache:

In this case `cache` is a cache that takes a sequence of `String` keys and returns a `AnyPublisher` of a list of `Int` values, but is limited to 3 concurrent requests (see the next paragraph for more information on limiting concurrent requests).

### Conditioning caches

Sometimes we may have levels that should only be queried under some conditions. Let's say we have a `DatabaseLevel` that should only be triggered when users enable a given setting in the app that actually starts storing data in the database. We may want to avoid accessing the database if the setting is disabled in the first place.

```swift
let conditionedCache = cache.conditioned { key in
  Just(appSettingIsEnabled).eraseToAnyPublisher()
}
```

The closure gets the key the cache was asked to fetch and has to return a `AnyPublisher<Bool, Error>` object indicating whether the request can proceed or should skip the level, with the possibility to fail with a specific `Error` to communicate the error to the caller.

At runtime, if the variable `appSettingIsEnabled` is `false`, the `get` request will skip the level (or fail if this was the only or last level in the cache). If `true`, the `get` request will be executed.

### Multiple cache lanes

If you have a complex scenario where, depending on the key or some other external condition, either one or another cache should be used, then the `switchLevels` function could turn useful.

Usage:

```swift
let lane1 = MemoryCacheLevel<URL, NSData>() // The two lanes have to be equivalent (same key type, same value type).
let lane2 = CacheProvider.dataCache() // Keep in mind that you can always use key transformation or value transformations if two lanes don't match by default

let switched = switchLevels(lane1, lane2) { key in
  if key.scheme == "http" {
  	return .cacheA
  } else {
   	return .cacheB // The example is just meant to show how to return different lanes
  }
}
```

Now depending on the scheme of the key URL, either the first lane or the second will be used.

### Listening to memory warnings

If we store big objects in memory in our cache levels, we may want to be notified of memory warning events. This is where the `listenToMemoryWarnings` and `unsubscribeToMemoryWarnings` functions come handy:

```swift
let token = cache.listenToMemoryWarnings()
```

and later

```swift
unsubscribeToMemoryWarnings(token)
```

With the first call, the cache level and all its composing levels will get a call to `onMemoryWarning` when a memory warning comes.

With the second call, the behavior will stop.

Keep in mind that this functionality is not yet supported by the WatchOS 2 framework `CarlosWatch.framework`.

### Normalization

In case you need to store the result of multiple `Carlos` composition calls in a property, it may be troublesome to set the type of the property to `BasicCache` as some calls return different types (e.g. `PoolCache`). In this case, you can `normalize` the cache level before assigning it to the property and it will be converted to a `BasicCache` value.

```swift
import Carlos

class CacheManager {
  let cache: BasicCache<URL, NSData>

  init(injectedCache: BasicCache<URL, NSData>) {
	self.cache = injectedCache
  }
}

[...]

let manager = CacheManager(injectedCache: CacheProvider.dataCache().pooled()) // This won't compile

let manager = CacheManager(injectedCache: CacheProvider.dataCache().pooled().normalize()) // This will
```

As a tip, always use `normalize` if you need to assign the result of multiple composition calls to a property. The call is a no-op if the value is already a `BasicCache`, so there will be no performance loss in that case.

### Creating custom levels

Creating custom levels is easy and encouraged (after all, there are multiple cache libraries already available if you only need memory, disk and network functionalities!).

Let's see how to do it:

```swift
class MyLevel: CacheLevel {
  typealias KeyType = Int
  typealias OutputType = Float

  func get(_ key: KeyType) -> AnyPublisher<OutputType, Error> {
    Future {
      // Perform the fetch and either succeed or fail
    }.eraseToAnyPublisher()
  }

  func set(_ value: OutputType, forKey key: KeyType) -> AnyPublisher<Void, Error> {  
    Future {
      // Store the value (db, memory, file, etc) and call this on completion:
    }.eraseToAnyPublisher()
  }

  func clear() {
    // Clear the stored values
  }

  func onMemoryWarning() {
    // A memory warning event came. React appropriately
  }
}
```

The above class conforms to the `CacheLevel` protocol.
First thing we need is to declare what key types we accept and what output types we return. In this example case, we have `Int` keys and `Float` output values.

The required methods to implement are 4: `get`, `set`, `clear` and `onMemoryWarning`.
This sample cache can now be pipelined to a list of other caches, transforming its keys or values if needed as we saw in the earlier paragraphs.

### Creating custom fetchers

With `Carlos 0.4`, the `Fetcher` protocol was introduced to make it easier for users of the library to create custom fetchers that can be used as read-only levels in the cache. An example of a "`Fetcher` in disguise" that has always been included in `Carlos` is `NetworkFetcher`: you can only use it to read from the network, not to write (`set`, `clear` and `onMemoryWarning` were **no-ops**).

This is how easy it is now to implement your custom fetcher:

```swift
class CustomFetcher: Fetcher {
  typealias KeyType = String
  typealias OutputType = String

  func get(_ key: KeyType) -> Anypublisher<OutputType, Error> {
    return Just("Found an hardcoded value :)").eraseToAnyPublisher()
  }
}
```

You still need to declare what `KeyType` and `OutputType` your `CacheLevel` deals with, of course, but then you're only required to implement `get`. Less boilerplate for you!

### Built-in levels

`Carlos` comes with 3 cache levels out of the box:

- `MemoryCacheLevel`
- `DiskCacheLevel`
- `NetworkFetcher`
- Since the `0.5` release, a `UserDefaultsCacheLevel`

**MemoryCacheLevel** is a volatile cache that internally stores its values in an `NSCache` instance. The capacity can be specified through the initializer, and it supports clearing under memory pressure (if the level is [subscribed to memory warning notifications](#listening-to-memory-warnings)).
It accepts keys of any given type that conforms to the `StringConvertible` protocol and can store values of any given type that conforms to the `ExpensiveObject` protocol. `Data`, `NSData`, `String`, `NSString` `UIImage`, `URL` already conform to the latter protocol out of the box, while `String`, `NSString` and `URL` conform to the `StringConvertible` protocol.
This cache level is thread-safe.

**DiskCacheLevel** is a persistent cache that asynchronously stores its values on disk. The capacity can be specified through the initializer, so that the disk size will never get too big.
It accepts keys of any given type that conforms to the `StringConvertible` protocol and can store values of any given type that conforms to the `NSCoding` protocol.
This cache level is thread-safe, and currently the only `CacheLevel` that can fail when calling `set`, with a `DiskCacheLevelError.diskArchiveWriteFailed` error.

**NetworkFetcher** is a cache level that asynchronously fetches values over the network.
It accepts `URL` keys and returns `NSData` values.
This cache level is thread-safe.

**NSUserDefaultsCacheLevel** is a persistent cache that stores its values on a `UserDefaults` persistent domain with a specific name.
It accepts keys of any given type that conforms to the `StringConvertible` protocol and can store values of any given type that conforms to the `NSCoding` protocol.
It has an internal soft cache used to avoid hitting the persistent storage too often, and can be cleared without affecting other values saved on the `standardUserDefaults` or on other persistent domains.
This cache level is thread-safe.

### Logging

When we decided how to handle logging in Carlos, we went for the most flexible approach that didn't require us to code a complete logging framework, that is the ability to plug-in your own logging library.
If you want the output of Carlos to only be printed if exceeding a given level, if you want to completely silent it for release builds, or if you want to route it to a file, or whatever else: just assign your logging handling closure to `Carlos.Logger.output`:

```swift
Carlos.Logger.output = { message, level in
   myLibrary.log(message) //Plug here your logging library
}
```

## Tests

`Carlos` is thouroughly tested so that the features it's designed to provide are safe for refactoring and as much as possible bug-free.

We use [Quick](https://github.com/Quick/Quick) and [Nimble](https://github.com/Quick/Nimble) instead of `XCTest` in order to have a good BDD test layout.

As of today, there are around **1000 tests** for `Carlos` (see the folder `Tests`), and overall the tests codebase is *double the size* of the production codebase.

## Future development

`Carlos` is under development and [here](https://github.com/WeltN24/Carlos/issues) you can see all the open issues. They are assigned to milestones so that you can have an idea of when a given feature will be shipped.

If you want to contribute to this repo, please:

- Create an issue explaining your problem and your solution
- Clone the repo on your local machine
- Create a branch with the issue number and a short abstract of the feature name
- Implement your solution
- Write tests (untested features won't be merged)
- When all the tests are written and green, create a pull request, with a short description of the approach taken

## Apps using Carlos

- [Die Welt Edition](https://itunes.apple.com/de/app/welt-edition-digitale-zeitung/id372746348?mt=8)
- [Welt news](https://itunes.apple.com/de/app/welt-news-aktuelle-nachrichten/id340021100?mt=8)

Using Carlos? Please let us know through a Pull request, we'll be happy to mention your app!

## Authors

`Carlos` was made in-house by WeltN24

### Contributors:

Vittorio Monaco, [vittorio.monaco@weltn24.de](mailto:vittorio.monaco@weltn24.de), [@vittoriom](https://github.com/vittoriom) on Github, [@Vittorio_Monaco](https://twitter.com/Vittorio_Monaco) on Twitter

Esad Hajdarevic, @esad

## License

`Carlos` is available under the MIT license. See the LICENSE file for more info.

## Acknowledgements

`Carlos` internally uses:

The **DiskCacheLevel** class is inspired by [Haneke](https://github.com/Haneke/HanekeSwift). The source code has been heavily modified, but adapting the original file has proven valuable for `Carlos` development.
