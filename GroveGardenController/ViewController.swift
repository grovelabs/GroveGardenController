import UIKit

internal final class ViewController: UIViewController {
  @IBOutlet fileprivate weak var serialTextField: UITextField!
  @IBOutlet fileprivate weak var passwordTextField: UITextField!
  @IBOutlet fileprivate weak var loginButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()

    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    self.view.addGestureRecognizer(tap)

    self.serialTextField.addTarget(self,
                                   action: #selector(serialTextFieldChanged(_:)),
                                   for: [.editingDidEndOnExit, .editingChanged])

    self.serialTextField.addTarget(self,
                                   action: #selector(serialTextFieldDoneEditing),
                                   for: .editingDidEndOnExit)

    self.passwordTextField.addTarget(self,
                                     action: #selector(passwordTextFieldChanged(_:)),
                                     for: .editingChanged)

    self.passwordTextField.addTarget(self,
                                     action: #selector(passwordTextFieldDoneEditing),
                                     for: .editingDidEndOnExit)
  }

  internal func serialTextFieldChanged(_ textField: UITextField) {
    print(#function)
  }

  internal func serialTextFieldDoneEditing() {
    print(#function)
  }

  internal func passwordTextFieldChanged(_ textField: UITextField) {
    print(#function)
  }

  internal func passwordTextFieldDoneEditing() {
    print(#function)
  }

  internal func dismissKeyboard() {
    self.view.endEditing(true)
  }

}
