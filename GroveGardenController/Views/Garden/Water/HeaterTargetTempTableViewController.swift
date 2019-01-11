import UIKit

class HeaterTargetTempTableViewController: UITableViewController, NotificationListener {
  @IBOutlet weak var off: UITableViewCell!
  @IBOutlet weak var medium: UITableViewCell!
  @IBOutlet weak var max: UITableViewCell!

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

    let aquariumTempTarget = grove.aquariumTempTarget
    off.accessoryType = (aquariumTempTarget == 0) ? .checkmark : .none
    medium.accessoryType = (aquariumTempTarget == 20) ? .checkmark : .none
    max.accessoryType = (aquariumTempTarget == 255) ? .checkmark : .none

    if (!grove.device.connected) {
      let _ = navigationController?.popToRootViewController(animated: true)
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    switch indexPath.row {
    case 0: GroveManager.shared.grove?.setAquariumHeaterTargetTemperature(.off)
    case 1: GroveManager.shared.grove?.setAquariumHeaterTargetTemperature(.medium)
    default: GroveManager.shared.grove?.setAquariumHeaterTargetTemperature(.max)
    }

    tableView.reloadData()
  }
}
