import Cocoa

class ViewController: NSViewController {

  override func viewDidLoad() {
    if #available(OSX 10.10, *) {
      super.viewDidLoad()
    }
  }
}

