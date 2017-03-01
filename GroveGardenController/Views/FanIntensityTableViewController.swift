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

  func bindView() {
    DispatchQueue.main.async { [weak self] in
      guard let grove = GroveManager.shared.grove else { return }
      let speed = grove.fan.schedule.speed

      self?.off.accessoryType = (speed == .off) ? .checkmark : .none
      self?.low.accessoryType = (speed == .low) ? .checkmark : .none
      self?.medium.accessoryType = (speed == .medium) ? .checkmark : .none
      self?.high.accessoryType = (speed == .high) ? .checkmark : .none
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
