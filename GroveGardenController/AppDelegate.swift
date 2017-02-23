import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    switch Keychain.loadSerial() {
    case nil:
      Storyboard.switchTo(.login)
    case let savedSerialNumber?:
      GroveManager.shared.getDevice(serialNumber: savedSerialNumber) { error in
        switch error {
        case _?:
          Storyboard.switchTo(.login)
        case nil:
          Storyboard.switchTo(.main)
        }
      }
    }

    return true
  }
  
}
