import UIKit

class GardenTableViewController: UITableViewController, NotificationListener {
  @IBOutlet weak var airDetailLabel: UILabel!
  @IBOutlet weak var waterDetailLabel: UILabel!

  var loadingView: UIView?
  var loading = false {
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

    self.clearsSelectionOnViewWillAppear = true

    addListener(forNotification: .Grove, selector: #selector(bindView))
    bindView()
  }

  func bindView() {
    DispatchQueue.main.async { [weak self] in
      switch GroveManager.shared.grove {
      case let grove?:
        self?.loading = false

        self?.airDetailLabel.text = {
          switch (grove.sensors.air.temperature, grove.sensors.air.humidity) {
          case (let temp?, let humidity?):
            return "\(temp.printableFahrenheit())   \(humidity)%"
          case (let temp?, _):
            return temp.printableFahrenheit()
          case (_, let humidity?):
            return "\(humidity)%"
          default:
            return "No sensor data"
          }
        }()

        self?.waterDetailLabel.text = grove.sensors.water.temperature.printableFahrenheit()

      case nil:
        self?.loading = true
      }
      self?.tableView.reloadData()
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch (indexPath.section, indexPath.row) {
    case (1, 0):
      Keychain.clearSerial()
      GroveManager.shared.grove = nil
      Storyboard.switchTo(.login)

    default:
      break
    }
  }

}
