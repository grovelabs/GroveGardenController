import class UIKit.UIViewController
import class UIKit.UIView
import class UIKit.UIActivityIndicatorView
import CoreGraphics

extension UIViewController {
  func makeActivityIndicator() -> UIView {
    let loadingView = UIView()
    loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
    loadingView.center = self.view.center
    loadingView.backgroundColor = .gray
    loadingView.clipsToBounds = true
    loadingView.layer.cornerRadius = 10

    let spinner = UIActivityIndicatorView()
    spinner.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
    spinner.style = .whiteLarge
    spinner.center = CGPoint(x: (loadingView.frame.width / 2),
                             y: (loadingView.frame.height / 2))
    spinner.hidesWhenStopped = true

    loadingView.addSubview(spinner)
    spinner.startAnimating()
    return loadingView
  }
}
