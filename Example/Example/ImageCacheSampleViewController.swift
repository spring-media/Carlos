import Foundation
import UIKit

import Carlos
import Combine

final class ImageCacheSampleViewController: BaseCacheViewController {
  private var cache: BasicCache<URL, UIImage>!
  private var cancellables = Set<AnyCancellable>()

  @IBOutlet var imageView: UIImageView?

  override func fetchRequested() {
    super.fetchRequested()

    cache.get(URL(string: urlKeyField?.text ?? "")!)
      .sink(receiveCompletion: { completion in
        switch completion {
        case .failure:
          self.imageView?.image = self.imageWithColor(.darkGray, size: self.imageView?.frame.size ?? .zero)
        default:
          break
        }
      }, receiveValue: { image in
        self.imageView?.image = image
      })
      .store(in: &cancellables)
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
    "Image cache"
  }

  override func setupCache() {
    super.setupCache()

    cache = CacheProvider.imageCache()
  }
}
