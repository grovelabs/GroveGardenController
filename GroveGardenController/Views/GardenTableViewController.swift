import UIKit
import SafariServices

class GardenTableViewController: UITableViewController, NotificationListener {
  @IBOutlet weak var lightsCell: UITableViewCell!
  @IBOutlet weak var airCell: UITableViewCell!
  @IBOutlet weak var waterCell: UITableViewCell!
  @IBOutlet weak var lightsDetailLabel: UILabel!
  @IBOutlet weak var airDetailLabel: UILabel!
  @IBOutlet weak var waterDetailLabel: UILabel!
  @IBOutlet weak var systemDetailLabel: UILabel!

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
    guard let grove = GroveManager.shared.grove else {
      loading = true
      return
    }

    loading = false
    lightsDetailLabel.text = "Garden, Seedling, Aquarium"
    waterDetailLabel.text = grove.sensors?.water.temperature?.printableFahrenheit() ?? ""

    airDetailLabel.text = {
      switch (grove.sensors?.air.temperature, grove.sensors?.air.humidity) {
      case (let temp?, let humidity?):
        return "\(temp.printableFahrenheit())   \(humidity)%"
      case (let temp?, _):
        return temp.printableFahrenheit()
      case (_, let humidity?):
        return "\(humidity)%"
      default:
        return ""
      }
    }()

    lightsCell.isUserInteractionEnabled = grove.device.connected
    airCell.isUserInteractionEnabled = grove.device.connected
    waterCell.isUserInteractionEnabled = grove.device.connected

    let cellColor = (grove.device.connected) ? UIColor.white : UIColor.white.withAlphaComponent(0.25)
    lightsCell.backgroundColor = cellColor
    airCell.backgroundColor = cellColor
    waterCell.backgroundColor = cellColor

    systemDetailLabel.text = {
      switch grove.standby {
      case false?: return "Power On"
      case true?: return "Standby Mode"
      case nil: return ""
      }
    }()

    if (!grove.device.connected) {
      airDetailLabel.text = "OFFLINE"
      waterDetailLabel.text = "OFFLINE"
      lightsDetailLabel.text = "OFFLINE"
      systemDetailLabel.text = "OFFLINE"
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch (indexPath.section, indexPath.row) {
    case (1, 0):
      goToURL(url: URL(string: "https://grovegrown.com/market"))

    case (1, 1):
      goToURL(url: URL(string: "https://grove.helpshift.com"))

    default:
      break
    }
    tableView.reloadData()
  }

  fileprivate func goToURL(url: URL?) {
    guard let url = url else { return }
    let vc = SFSafariViewController(url: url)
    vc.view.tintColor = .gr_orange
    vc.modalPresentationStyle = .overFullScreen
    present(vc, animated: true, completion: nil)
  }

}
