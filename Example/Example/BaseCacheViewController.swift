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
      self.eventsLogView.text = "\(self.eventsLogView.text!)\(message)\n"
    }
  }
  
  func setupCache() {
    
  }
  
  func fetchRequested() {
    
  }
  
  func titleForScreen() -> String {
    return "Carlos Sample"
  }
  
  @IBAction func fetchButtonTapped(_ sender: AnyObject) {
    fetchRequested()
    
    urlKeyField?.resignFirstResponder()
  }
}

extension BaseCacheViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if let text = textField.text {
      let newText = (text as NSString).replacingCharacters(in: range, with: string)
      let textIsURL = URL(string: newText) != nil
      fetchButton.isEnabled = textIsURL
    }
    
    return true
  }
}
