# Carlos

[![CI Status](http://img.shields.io/travis/Vittorio Monaco/Carlos.svg?style=flat)](https://travis-ci.org/Vittorio Monaco/Carlos)
[![Version](https://img.shields.io/cocoapods/v/Carlos.svg?style=flat)](http://cocoapods.org/pods/Carlos)
[![License](https://img.shields.io/cocoapods/l/Carlos.svg?style=flat)](http://cocoapods.org/pods/Carlos)
[![Platform](https://img.shields.io/cocoapods/p/Carlos.svg?style=flat)](http://cocoapods.org/pods/Carlos)

> A simple but flexible cache.

## What is Carlos?

Carlos is a small set of classes, global functions (that will be replaced by protocol extensions with Swift 2.0) and convenience operators to realize custom, flexible and powerful cache layers in your application.

By default, Carlos ships with an in-memory cache, a disk cache and a simple network fetcher. 

With Carlos you can:

- create more layers and fetchers depending on your needs, either through classes or with simple closures
- combine layers
- sort the different layers depending on what makes most sense for you
- transform the key each layer will get, or the values each layer will output (this means you're free to implement every layer independing on how it will be used later on)
- react to memory pressure events in your app
- automatically populate upper layers when one of the lower layers fetches a value for a key, so the next time the first layer will already have it cached
- enable or disable specific layers of your composed cache depending on boolean conditions
- easily pool requests so that expensive layers don't have to care whether 5 requests with the same keys come before even only 1 of them is done. Carlos can take care of that for you
- have a type-safe complex cache that won't even compile if the code doesn't satisfy the type requirements 

## Usage

To run the example project, clone the repo.

### Usage examples

```
let cache = MemoryCacheLevel<NSData>() >>> DiskCacheLevel()
```

This line will generate a cache that takes `String` keys and returns `NSData` values.
Setting a value for a given key on this cache will set it for both the levels.
Getting a value for a given key on this cache will first try getting it on the memory level, and if it cannot find one, will ask the disk level. In case both levels don't have a value, the request will fail.

### Creating requests

To fetch a value from a cache, use the `get` method.

```
cache.get("key").onSuccess({ value in    println("I found \(value)!")}).onFailure({ error in    println("An error occurred :( \(error)")})
```

You can also store the request somewhere and then attach multiple `onSuccess` or `onFailure` listeners to it:

```
let request = cache.get("key")

request.onSuccess({ value in    println("I found \(value)!")})
[... somewhere else]
request.onSuccess({ value in    println("I also can read \(value)!")})

```

When the cache request succeeds, all its listeners are called. And even if you add a listener after the request already did its job, you will still get the callback.

This cache is not very useful, though. It will never *actively* fetch values, just store them for later use. Let's try to make it more interesting:

```
let cache = MemoryCacheLevel<NSData>() >>> DiskCacheLevel() >>> NetworkFetcher()
```

If you try to compile this code, it will actually fail! Why is that?

`NetworkFetcher` only accepts `NSURL` keys. That makes sense, since it's using the keys to fetch data from the network. But we don't want necessarily to have URL keys all around our cache. How can we do it?

## Key transformations

Key transformations are meant to make it possible to plug cache levels in whatever cache you're building.

Let's see how they work:

```    
let transformedCache = { NSURL(string: $0)! } =>> NetworkFetcher()
``` 

With the line above, we're saying that all the keys coming into the NetworkFetcher layer have to be transformed to `NSURL` values first. We can now plug this cache into our previous structure:

```
let cache = MemoryCacheLevel<NSData>() >>> DiskCacheLevel() >>> transformedCache
```

or 

```
let cache = MemoryCacheLevel<NSData>() >>> DiskCacheLevel() >>> ({ NSURL(string: $0)! } =>> NetworkFetcher())
```

This will now compile. 
If this doesn't look very safe (one could always pass string garbage as a key and it won't magically translate to a `NSURL`!), we can still use a domain specific structure as a key, assuming it contains both `String` and `NSURL` values:

```
struct Image {
  let identifier: String
  let URL: NSURL
}

let imageToString = OneWayTransformationBox(transform: { (image: Image) -> String in    image.identifier})    let imageToURL = OneWayTransformationBox(transform: { (image: Image) -> NSURL in    image.URL})    let memoryLayer = imageToString =>> MemoryCacheLevel<NSData>()let diskLayer = imageToString =>> DiskCacheLevel()let networkLayer = imageToURL =>> NetworkFetcher()    let cache = memoryLayer >>> diskLayer >>> networkLayer
```

All the transformer objects could be replaced with closures as we did in the previous example, and the whole cache could be created in one line, if needed.

Now we can perform safe requests like this:

```
let image = Image(identifier: "550e8400-e29b-41d4-a716-446655440000", URL: NSURL(string: "http://goo.gl/KcGz8T")!)

cache.get(image).onSuccess({ value in
  println("Found \(value)!")
})
```

That's not all, though.

What if our disk cache only stores `NSData`, but we want our memory cache to conveniently store `UIImage` instances instead? 

## Value transformations

Value transformers let you have a cache that (let's say) stores `NSData` and mutate it to a cache that stores `UIImage` values. Let's see how:

```
let dataTransformer = TwoWayTransformationBox(transform: { (image: UIImage) -> NSData in    UIImagePNGRepresentation(image)}, inverseTransform: { (data: NSData) -> UIImage in    UIImage(data: data)!})    let memoryLayer = imageToString =>> MemoryCacheLevel<UIImage>() =>> dataTransformer    
``` 

This memory layer can now replace the one we had before, with the difference that it will internally store `UIImage` values!

## Pooling requests

When you have a working cache, but some of your levels are expensive (say a Network fetcher or a database fetcher), you may want to pool requests in a way that multiple requests for the same key, coming together before one of them completes, are grouped so that when one completes all of the other complete as well without having to actually perform the expensive operation multiple times. 

This functionality comes with Carlos.

```
let cache = pooled(memoryLayer >>> diskLayer >>> networkLayer)
```

Keep in mind that the key must be hashable for the `pooled` function to work:


```
extension Image: Hashable {
  var hashValue: Int {
    return identifier.hashValue
  }
}

extension Image: Equatable {
  
}

func ==(lhs: Image, rhs: Image) -> Bool {
  return lhs.identifier == rhs.identifier && lhs.URL == rhs.URL
}
```

Now we can execute multiple fetches for the same `Image` value and be sure that only one network request will be started.

## Conditioning caches 

Sometimes we may have levels that should only be queried under some conditions. Let's say we have a `DatabaseLevel` that should only be triggered when users enable a given setting in the app that actually starts storing data in the database. We may want to avoid accessing the database if the setting is disabled in the first place.

```
let conditionedCache = conditioned(cache, { key in
  return (appSettingIsEnabled, nil)
})
```

The closure gets the key the cache was asked to fetch and has to return a boolean value, indicating whether the request can proceed or should skip the level, and an optional `NSError` communicating the specific error to the caller.

The same effect can be obtained through the `<?>` operator:

```
let conditionedCache = { key in
  return (appSettingIsEnabled, nil)
} <?> cache
```

At runtime, if the variable `appSettingIsEnabled` is `false`, the `get` request will skip the level (or fail if this was the only or last level in the cache). If `true`, the `get` request will be executed. 

## Listening to memory warnings

If we store big objects in memory in our cache levels, we may want to be notified of memory warning events. This is where the `listenToMemoryWarnings` and `unsubscribeToMemoryWarnings` functions come handy:

```
let token = listenToMemoryWarnings(cache)```

and later

```
unsubscribeToMemoryWarnings(token)
```

With the first call, the cache level and all its composing levels will get a call to `onMemoryWarning` when a memory warning comes.

With the second call, the behavior will stop.


## Creating custom levels

Creating custom levels is easy and encouraged (there are multiple cache libraries already available if you only need memory, disk and network functionality).

Let's see how to do it:

```
class MyLevel: CacheLevel {  typealias KeyType = Int  typealias OutputType = Float    func get(key: KeyType) -> CacheRequest<OutputType> {    let request = CacheRequest<OutputType>()        // Perform the fetch and either succeed or fail    request.succeed(1.0)        return request  }    func set(value: OutputType, forKey key: KeyType) {    // Store the value (db, memory, file, etc)  }    func clear() {    // Clear the stored values  }    func onMemoryWarning() {    // A memory warning event came. React appropriately  }}
```

The above class conforms to the `CacheLevel` protocol (needed by all the global functions and operators). 

First thing we need is to declare what key types we accept and what output types we return. In this example case, we have `Int` keys and `Float` output values.

The required methods to implement are 4: `get`, `set`, `clear` and `onMemoryWarning`.

`get` has to return a `CacheRequest`, we can create one in the beginning of the method body and return it. Then we inform the listeners by calling `succeed` or `fail` on it depending on the outcome of the fetch. These calls can (and most of the times will) be asynchronous.

`set` has to store the given value for the given key.

`clear` expresses the intent to wipe the cache level.

`onMemoryWarning` notifies a memory pressure event in case the `listenToMemoryWarning` method was called before.

This sample cache can now be pipelined to a list of other caches, transforming its keys or values if needed as we saw in the earlier paragraphs.

## Composing with closures

Sometimes we could have simple fetchers that don't need `set`, `clear` and `onMemoryWarning` implementations because they don't store anything. In this case we can pipeline fetch closures instead of full-blown caches.

```
let fetcherLayer = { (image: Image) -> CacheRequest<NSData> in    let request = CacheRequest<NSData>()          request.succeed(NSData(contentsOfURL: image.URL)!)          return request}    
```

This fetcher can be plugged in and replace the `NetworkFetcher` for example:

```
let cache = pooled(memoryLayer >>> diskLayer >>> fetcherLayer)
```

## Requirements

The project has no dependencies. If you want to contribute, please clone the submodules by running `git submodule update --init --recursive`

## Installation

Carlos is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```
pod "Carlos"
```

If you don't use CocoaPods, you can still add Carlos as a submodule, drag and drop `Carlos.xcodeproj` into your project, and embed `Carlos.framework` in your target.

`Carthage` support is in the works.

## Authors

Carlos was made in-house by WeltN24

### Contributors:

Vittorio Monaco, vittorio.monaco@weltn24.de, @vittoriom

Esad Hajradevic, @esad

## License

Carlos is available under the MIT license. See the LICENSE file for more info.
