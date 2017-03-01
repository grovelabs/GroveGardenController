import UIKit

class PumpScheduleTableViewController: UITableViewController, NotificationListener {
  @IBOutlet weak var off: UITableViewCell!
  @IBOutlet weak var less: UITableViewCell!
  @IBOutlet weak var normal: UITableViewCell!
  @IBOutlet weak var more: UITableViewCell!
  @IBOutlet weak var on: UITableViewCell!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.clearsSelectionOnViewWillAppear = true

    addListener(forNotification: .Grove, selector: #selector(bindView))
    bindView()
  }

  func bindView() {
    DispatchQueue.main.async { [weak self] in
      guard let grove = GroveManager.shared.grove else { return }
      let schedule = grove.pump.schedule

      self?.off.accessoryType = (schedule == Pump.Schedule.Presets.off) ? .checkmark: .none
      self?.less.accessoryType = (schedule == Pump.Schedule.Presets.less) ? .checkmark: .none
      self?.normal.accessoryType = (schedule == Pump.Schedule.Presets.normal) ? .checkmark: .none
      self?.more.accessoryType = (schedule == Pump.Schedule.Presets.more) ? .checkmark: .none
      self?.on.accessoryType = (schedule == Pump.Schedule.Presets.on) ? .checkmark: .none
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    switch indexPath.row {
    case 0: GroveManager.shared.grove?.pumpSchedule(Pump.Schedule.Presets.off)
    case 1: GroveManager.shared.grove?.pumpSchedule(Pump.Schedule.Presets.less)
    case 2: GroveManager.shared.grove?.pumpSchedule(Pump.Schedule.Presets.normal)
    case 3: GroveManager.shared.grove?.pumpSchedule(Pump.Schedule.Presets.more)
    default: GroveManager.shared.grove?.pumpSchedule(Pump.Schedule.Presets.on)
    }
    tableView.reloadData()
  }

}
