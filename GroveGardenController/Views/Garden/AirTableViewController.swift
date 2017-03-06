import UIKit

class AirTableViewController: UITableViewController, NotificationListener {
  @IBOutlet weak var airTempLabel: UILabel!
  @IBOutlet weak var humidityLabel: UILabel!
  @IBOutlet weak var fanActionLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.clearsSelectionOnViewWillAppear = true

    addListener(forNotification: .Grove, selector: #selector(bindView))
    bindView()
  }

  func bindView() {
    guard let grove = GroveManager.shared.grove else { return }

    airTempLabel.text = grove.sensors?.air.temperature?.printableFahrenheit() ?? ""
    fanActionLabel.text = grove.fan?.schedule.speed.rawValue ?? ""
    humidityLabel.text = {
      switch grove.sensors?.air.humidity {
      case let humidity?: return "\(humidity)%"
      case nil: return ""
      }
    }()

    if (!grove.device.connected) {
      let _ = navigationController?.popToRootViewController(animated: true)
    }
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch (indexPath.section, indexPath.row) {
    case (0, 0) where (GroveManager.shared.grove?.sensors?.air.temperature == nil):
      return 0
    case (0, 1) where (GroveManager.shared.grove?.sensors?.air.humidity == nil):
      return 0
    default:
      return super.tableView(tableView, heightForRowAt: indexPath)
    }
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if (section == 0 &&
      GroveManager.shared.grove?.sensors?.air.temperature == nil &&
      GroveManager.shared.grove?.sensors?.air.humidity == nil) {
      return ""
    }
    return super.tableView(tableView, titleForHeaderInSection: section)
  }

  override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    if (section == 0 &&
      GroveManager.shared.grove?.sensors?.air.temperature == nil &&
      GroveManager.shared.grove?.sensors?.air.humidity == nil) {
      return ""
    }
    return super.tableView(tableView, titleForFooterInSection: section)
  }

}
