import Foundation
import UIKit
import Carlos

class ImageCacheSampleViewController: BaseCacheViewController {
  private var cache: BasicCache<URL, UIImage>!
  @IBOutlet weak var imageView: UIImageView?
  
  override func fetchRequested() {
    super.fetchRequested()
    
    cache.get(URL(string: urlKeyField?.text ?? "")!)
      .onCompletion { result in
        guard let imageView = self.imageView else {
          return
        }
        
        switch result {
        case .success(let image):
          imageView.image = image
        case .error(_):
          imageView.image = self.imageWithColor(.darkGray, size: imageView.frame.size)
        default:
          break
        }
      }
  }
  
  private func imageWithColor(_ color: UIColor, size: CGSize) -> UIImage {
    let rect = CGRect(origin: CGPoint.zero, size: size)
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    color.setFill()
    UIRectFill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
  }
  
  override func titleForScreen() -> String {
    return "Image cache"
  }
  
  override func setupCache() {
    super.setupCache()
    
    cache = CacheProvider.imageCache()
  }
}
