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

  func bindView() {
    DispatchQueue.main.async { [weak self] in
      guard let grove = GroveManager.shared.grove else { return }

      self?.waterTempLabel.text = grove.sensors.water.temperature?.printableFahrenheit() ?? ""

      self?.targetTempActionLabel.text = grove.aquariumTempTarget.printableFahrenheit()

      self?.targetTempActionLabel.text = {
        switch grove.aquariumTempTarget {
        case Int.min..<1: return "Off"
        case 19, 20, 21: return "68 ℉"
        case 255..<Int.max: return "78 ℉"
        default: return grove.aquariumTempTarget.printableFahrenheit()
        }
      }()

      self?.pumpScheduleActionLabel.text = "\(Int(grove.pump.schedule.on) / 60) min"
    }
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch (indexPath.section, GroveManager.shared.grove?.sensors.water.temperature) {
    case (0, nil), (1, nil):
      return 0
    default:
      return super.tableView(tableView, heightForRowAt: indexPath)
    }
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch (section, GroveManager.shared.grove?.sensors.water.temperature) {
    case (0, nil), (1, nil):
      return nil
    default:
      return super.tableView(tableView, titleForHeaderInSection: section)
    }
  }

  override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    switch (section, GroveManager.shared.grove?.sensors.water.temperature) {
    case (0, nil), (1, nil):
      return nil
    default:
      return super.tableView(tableView, titleForFooterInSection: section)
    }
  }
}
