import UIKit

internal final class DeviceViewController: UIViewController, NotificationListener {
  @IBOutlet weak var serialNumberLabel: UILabel!
  @IBOutlet weak var onlineStatusLabel: UILabel!
  @IBOutlet weak var pumpOnValue: UILabel!
  @IBOutlet weak var fanOnValue: UILabel!
  @IBOutlet weak var airTempContainer: UIStackView!
  @IBOutlet weak var airTempValue: UILabel!
  @IBOutlet weak var humidityContainer: UIStackView!
  @IBOutlet weak var humidityValue: UILabel!
  @IBOutlet weak var waterTempValue: UILabel!
  @IBOutlet weak var logoutButton: UIButton!

  var loadingView: UIView?
  var loading: Bool = false {
    didSet {
      switch (loading, oldValue) {
      case (true, false):
        loadingView = makeActivityIndicator()
        self.view.addSubview(loadingView!)
      case (false, true):
        loadingView?.removeFromSuperview()
        loadingView = nil
      default:
        break
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // add styles
    logoutButton.layer.backgroundColor = UIColor.gr_orange.cgColor
    logoutButton.layer.borderWidth = 1
    logoutButton.layer.borderColor = UIColor.gr_orange_dark.cgColor

    // add listeners
    addListener(forNotification: .Grove, selector: #selector(bindView))
    bindView()
  }

  func bindView() {
    DispatchQueue.main.async { [weak self] in
      switch GroveManager.shared.grove {
      case let grove?:
        self?.serialNumberLabel.text = grove.serialNumber
        self?.onlineStatusLabel.text = grove.connected ? "😀" : "🙁"

        self?.pumpOnValue.text = grove.pump.on ? "On" : "Off"
        self?.fanOnValue.text = "\(grove.fan.intensity)"

        self?.airTempValue.text = "\(grove.sensors.air.temperature ?? -1) ℃"
        self?.humidityValue.text = "\(grove.sensors.air.humidity ?? -1) %"
        self?.waterTempValue.text = "\(grove.sensors.water.temperature) ℃"

        self?.loading = false

      case nil:
        self?.loading = true
      }
    }
  }

  @IBAction
  internal func logoutButtonPressed(_ sender: UIButton) {
    Keychain.clearSerial()
    Storyboard.switchTo(.login)
  }
}
