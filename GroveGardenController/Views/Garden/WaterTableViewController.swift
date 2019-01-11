import UIKit

class WaterTableViewController: UITableViewController, NotificationListener {
  @IBOutlet weak var waterTempLabel: UILabel!
  @IBOutlet weak var targetTempActionLabel: UILabel!
  @IBOutlet weak var pumpScheduleActionLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.clearsSelectionOnViewWillAppear = true

    addListener(forNotification: .Grove, selector: #selector(bindView))
    bindView()
  }

  deinit {
    removeListener(forNotification: .Grove)
  }

  @objc func bindView() {
    guard let grove = GroveManager.shared.grove else { return }

    waterTempLabel.text = grove.sensors?.water.temperature?.printableFahrenheit() ?? ""
    targetTempActionLabel.text = grove.aquariumTempTarget?.printableFahrenheit() ?? ""

    targetTempActionLabel.text = {
      switch grove.aquariumTempTarget {
      case let target?:
        switch target {
        case Int.min..<1: return "Off"
        case 19, 20, 21: return "68 ℉"
        case 255..<Int.max: return "78 ℉"
        default: return grove.aquariumTempTarget?.printableFahrenheit() ?? ""
        }
      case nil:
        return ""
      }
    }()

    pumpScheduleActionLabel.text = {
      switch grove.pump {
      case let pump?:
        return "\(Int(pump.schedule.on) / 60) min"
      case nil:
        return ""
      }
    }()

    if (!grove.device.connected) {
      let _ = navigationController?.popToRootViewController(animated: true)
    }
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch (indexPath.section, GroveManager.shared.grove?.sensors?.water.temperature) {
    case (0, nil), (1, nil):
      return 0
    default:
      return super.tableView(tableView, heightForRowAt: indexPath)
    }
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch (section, GroveManager.shared.grove?.sensors?.water.temperature) {
    case (0, nil), (1, nil):
      return nil
    default:
      return super.tableView(tableView, titleForHeaderInSection: section)
    }
  }

  override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    switch (section, GroveManager.shared.grove?.sensors?.water.temperature) {
    case (0, nil), (1, nil):
      return nil
    default:
      return super.tableView(tableView, titleForFooterInSection: section)
    }
  }
}
