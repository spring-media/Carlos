import Foundation
import UIKit
import Carlos

class SimpleCacheSampleViewController: UIViewController {
  @IBOutlet weak var urlKeyField: UITextField!
  @IBOutlet weak var fetchButton: UIButton!
  @IBOutlet weak var eventsLogView: UITextView!
  
  private var cache: BasicCache<NSURL, NSData>!
  
  @IBAction func fetchButtonTapped(sender: AnyObject) {
    cache.get(NSURL(string: urlKeyField.text)!)
    
    urlKeyField.resignFirstResponder()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Simple cache"
    
    let urlToString = OneWayTransformationBox(transform: { (input: NSURL) -> String in
      input.absoluteString!
    })
    
    cache = (urlToString =>> (MemoryCacheLevel() >>> DiskCacheLevel())) >>> NetworkFetcher()
    
    Logger.output = { (message, _) in
      NSOperationQueue.mainQueue().addOperationWithBlock {
        self.eventsLogView.text = "\(self.eventsLogView.text)\(message)\n"
      }
    }
  }
}

extension SimpleCacheSampleViewController: UITextFieldDelegate {
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    let newText = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
    
    let textIsURL = NSURL(string: newText) != nil
    fetchButton.enabled = textIsURL
    
    return true
  }
}