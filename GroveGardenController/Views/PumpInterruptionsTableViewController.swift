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

  func bindView() {
    DispatchQueue.main.async { [weak self] in
      guard let grove = GroveManager.shared.grove else { return }

      let interruption = grove.pump.interruption

      self?.resumeSchedule.isUserInteractionEnabled = (interruption != nil)
      self?.resumeSchedule.textLabel?.textColor = (interruption != nil) ? .gr_blue_enabled : .gr_grey_disabled
      self?.off.accessoryType = (interruption != nil && !grove.pump.on) ? .checkmark : .none
      self?.on.accessoryType = (interruption != nil && grove.pump.on) ? .checkmark : .none
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
