import UIKit

internal final class LoginViewController: UIViewController {
  @IBOutlet fileprivate weak var serialTextField: UITextField!
  @IBOutlet fileprivate weak var passwordTextField: UITextField!
  @IBOutlet fileprivate weak var loginButton: UIButton!

  var serialSuffix: String = ""

  override func viewDidLoad() {
    super.viewDidLoad()

    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    self.view.addGestureRecognizer(tap)

    self.serialTextField.addTarget(self,
                                   action: #selector(serialTextFieldChanged(_:)),
                                   for: [.editingDidEndOnExit, .editingChanged])

    self.passwordTextField.addTarget(self,
                                     action: #selector(passwordTextFieldDoneEditing),
                                     for: .editingDidEndOnExit)

    // bind styles
    loginButton.layer.backgroundColor = UIColor.gr_orange.cgColor
    loginButton.layer.borderWidth = 1
    loginButton.layer.borderColor = UIColor.gr_orange_dark.cgColor
  }

  enum AlertOptions {
    case serialNotLongEnough
    case incorrectSerialOrPassword
    case other

    var alertCopy: (title: String, message: String) {
      switch self {
      case .serialNotLongEnough:
        return (title: "Serial number is not long enough.",
                message: "The serial number needs to include exactly 6 numbers")
      case .incorrectSerialOrPassword:
        return (title: "Incorrect serial number or password",
                message: "Please check that you are entering your correct serial number and password and try again.")
      case .other:
        return (title: "Something else went wrong.",
                message: "Check your phone's internet connection and try again.")
      }
    }
  }

  private func showAlert(_ alertOption: AlertOptions) {
    let alertController = UIAlertController(title: alertOption.alertCopy.title,
                                            message: alertOption.alertCopy.message,
                                            preferredStyle: .alert)
    let alert = UIAlertAction(title: "OK", style: .default) { _ in
      alertController.dismiss(animated: true, completion: nil)
    }
    alertController.addAction(alert)
    self.present(alertController, animated: true, completion: nil)
  }

  @IBAction
  internal func loginButtonPressed(_ sender: UIButton) {

    guard serialSuffix.count == 6 else {
      return showAlert(.serialNotLongEnough)
    }

    let serialNumber = "GR-ECO-00-" + serialSuffix

    guard Secrets.Groves[serialNumber] == passwordTextField.text else {
      return showAlert(.incorrectSerialOrPassword)
    }

    sender.isEnabled = false
    GroveManager.shared.getDevice(serialNumber: serialNumber) { [weak self] error in
      sender.isEnabled = true
      switch error {
      case _?:
        self?.showAlert(.other)
      case nil:
        Storyboard.switchTo(.main)
      }
    }
  }

  internal func serialTextFieldChanged(_ textField: UITextField) {

    switch textField.text {
    case let text? where text.count <= 6:
      serialSuffix = text
    default:
      break
    }

    serialTextField.text = serialSuffix
  }

  internal func passwordTextFieldDoneEditing() {
    loginButtonPressed(loginButton)
  }

  internal func dismissKeyboard() {
    self.view.endEditing(true)
  }

}
