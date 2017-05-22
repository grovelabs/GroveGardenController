import UIKit

class FanIntensityTableViewController: UITableViewController, NotificationListener {
  @IBOutlet weak var off: UITableViewCell!
  @IBOutlet weak var low: UITableViewCell!
  @IBOutlet weak var medium: UITableViewCell!
  @IBOutlet weak var high: UITableViewCell!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.clearsSelectionOnViewWillAppear = true

    addListener(forNotification: .Grove, selector: #selector(bindView))
    bindView()
  }

  deinit {
    removeListener(forNotification: .Grove)
  }

  func bindView() {
    guard let grove = GroveManager.shared.grove else { return }
    let speed = grove.fan?.schedule.speed

    off.accessoryType = (speed == .off) ? .checkmark : .none
    low.accessoryType = (speed == .low) ? .checkmark : .none
    medium.accessoryType = (speed == .medium) ? .checkmark : .none
    high.accessoryType = (speed == .high) ? .checkmark : .none

    if (!grove.device.connected) {
      let _ = navigationController?.popToRootViewController(animated: true)
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    switch indexPath.row {
    case 0: GroveManager.shared.grove?.fanSchedule(.off)
    case 1: GroveManager.shared.grove?.fanSchedule(.low)
    case 2: GroveManager.shared.grove?.fanSchedule(.medium)
    default: GroveManager.shared.grove?.fanSchedule(.high)
    }

    tableView.reloadData()
  }

}
