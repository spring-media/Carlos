import Foundation
import UIKit
import Carlos

class ImageCacheSampleViewController: BaseCacheViewController {
  private var cache: BasicCache<NSURL, UIImage>!
  @IBOutlet weak var imageView: UIImageView?
  
  override func fetchRequested() {
    super.fetchRequested()
    
    cache.get(NSURL(string: urlKeyField?.text ?? "")!)
      .onCompletion { (image, error) in
        if let imageView = self.imageView {
          if let image = image {
            imageView.image = image
          } else if let _ = error {
            imageView.image = self.imageWithColor(.darkGrayColor(), size: imageView.frame.size)
          }
        }
      }
  }
  
  private func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
    let rect = CGRect(origin: CGPoint.zero, size: size)
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    color.setFill()
    UIRectFill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }
  
  override func titleForScreen() -> String {
    return "Image cache"
  }
  
  override func setupCache() {
    super.setupCache()
    
    cache = CacheProvider.imageCache()
  }
}