import class UIKit.UIStoryboard
import class UIKit.UIApplication

public enum Storyboard: String {
  case login = "Login"
  case device = "Device"

  public static func switchTo(_ name: Storyboard) {
    let storyboard = UIStoryboard(name)
    let initViewController = storyboard.instantiateInitialViewController()!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    appDelegate.window?.rootViewController = initViewController
  }
}

public extension UIStoryboard {
  convenience init(_ name: Storyboard, bundle: Bundle? = nil) {
    self.init(name: name.rawValue, bundle: bundle)
  }
}
