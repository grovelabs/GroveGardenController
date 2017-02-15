import UIKit

internal final class DeviceViewController: UIViewController {
  @IBOutlet weak var logoutButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()

    // bind styles
    logoutButton.layer.backgroundColor = UIColor.gr_orange.cgColor
    logoutButton.layer.borderWidth = 1
    logoutButton.layer.borderColor = UIColor.gr_orange_dark.cgColor
  }

  @IBAction
  internal func logoutButtonPressed(_ sender: UIButton) {
    Keychain.clearSerial()
    let storyboard = UIStoryboard(.login)
    let initViewController = storyboard.instantiateInitialViewController()!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    appDelegate.window?.rootViewController = initViewController
  }
}
