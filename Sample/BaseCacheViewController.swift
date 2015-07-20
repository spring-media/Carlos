import Foundation
import UIKit
import Carlos

class BaseCacheViewController: UIViewController {
  @IBOutlet weak var urlKeyField: UITextField?
  @IBOutlet weak var fetchButton: UIButton!
  @IBOutlet weak var eventsLogView: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = titleForScreen()
    
    setupCache()
    
    Logger.output = { (message, _) in
      NSOperationQueue.mainQueue().addOperationWithBlock {
        self.eventsLogView.text = "\(self.eventsLogView.text)\(message)\n"
      }
    }
  }
  
  func setupCache() {
    
  }
  
  func fetchRequested() {
    
  }
  
  func titleForScreen() -> String {
    return "Carlos Sample"
  }
  
  @IBAction func fetchButtonTapped(sender: AnyObject) {
    fetchRequested()
    
    urlKeyField?.resignFirstResponder()
  }
}

extension BaseCacheViewController: UITextFieldDelegate {
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    let newText = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
    
    let textIsURL = NSURL(string: newText) != nil
    fetchButton.enabled = textIsURL
    
    return true
  }
}