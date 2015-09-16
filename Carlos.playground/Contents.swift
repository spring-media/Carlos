import Carlos
import UIKit

initializePlayground()

let cache = CacheProvider.imageCache()

cache.get(NSURL(string: "http://4.bp.blogspot.com/-TXzXNotuaHk/TwG1cQOC6DI/AAAAAAAACvI/m2GQlq90vfw/s1600/avido.jpg")!).onSuccess { value in
  let image = UIImageView(image: value)
  
  image
}
