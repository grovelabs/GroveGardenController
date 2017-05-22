import UIKit

class PumpInterruptionsTableViewController: UITableViewController, NotificationListener {
  @IBOutlet weak var on: UITableViewCell!
  @IBOutlet weak var off: UITableViewCell!
  @IBOutlet weak var resumeSchedule: UITableViewCell!

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

    let interruption = grove.pump?.interruption

    resumeSchedule.isUserInteractionEnabled = (interruption != nil)
    resumeSchedule.textLabel?.textColor = (interruption != nil) ? .gr_blue_enabled : .gr_grey_disabled
    off.accessoryType = (interruption != nil && grove.pump?.on == false) ? .checkmark : .none
    on.accessoryType = (interruption != nil && grove.pump?.on == true) ? .checkmark : .none

    if (!grove.device.connected) {
      let _ = navigationController?.popToRootViewController(animated: true)
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    switch (indexPath.section, indexPath.row) {
    case (0, 0): GroveManager.shared.grove?.pumpInterruption(on: true)
    case (0, 1): GroveManager.shared.grove?.pumpInterruption(on: false)
    case (1, 0): GroveManager.shared.grove?.pumpSchedule()
    default: break
    }

    tableView.reloadData()
  }

}
