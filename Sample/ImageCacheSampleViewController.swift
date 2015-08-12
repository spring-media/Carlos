import Foundation
import UIKit
import Carlos

class ImageCacheSampleViewController: BaseCacheViewController {
  private var cache: BasicCache<NSURL, UIImage>!
  @IBOutlet weak var imageView: UIImageView?
  
  override func fetchRequested() {
    super.fetchRequested()
    
    cache.get(NSURL(string: urlKeyField?.text ?? "")!)
      .onSuccess { image in
        self.imageView?.image = image
      }
      .onFailure { _ in
        self.imageView?.image = self.imageWithColor(.darkGrayColor(), size: self.imageView?.frame.size ?? CGSize.zeroSize)
      }
  }
  
  private func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
    let rect = CGRect(origin: CGPoint.zeroPoint, size: size)
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