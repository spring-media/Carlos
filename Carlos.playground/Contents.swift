import Carlos
import UIKit
import XCPlayground

XCPSetExecutionShouldContinueIndefinitely(continueIndefinitely: true)

func sharedSubfolder() -> String {
  return "\(XCPSharedDataDirectoryPath)/com.carlos.cache"
}

let disk = OneWayTransformationBox<NSURL, String>(transform: { $0.absoluteString! }) =>> DiskCacheLevel<String, UIImage>(path: sharedSubfolder())

let memory = OneWayTransformationBox<NSURL, String>(transform: { $0.absoluteString! }) =>> MemoryCacheLevel<String, UIImage>()

let network = (NetworkFetcher() =>> TwoWayTransformationBox<NSData, UIImage>(transform: { UIImage(data: $0)! }, inverseTransform: { UIImagePNGRepresentation($0) }))

let cache = memory >>> disk >>> network

cache.get(NSURL(string: "http://4.bp.blogspot.com/-TXzXNotuaHk/TwG1cQOC6DI/AAAAAAAACvI/m2GQlq90vfw/s1600/avido.jpg")!).onSuccess { value in
  let image = UIImageView(image: value)
  
  image
}