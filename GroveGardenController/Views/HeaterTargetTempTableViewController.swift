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

  func bindView() {
    DispatchQueue.main.async { [weak self] in
      guard let grove = GroveManager.shared.grove else { return }

      let aquariumTempTarget = grove.aquariumTempTarget
      self?.off.accessoryType = (aquariumTempTarget == 0) ? .checkmark : .none
      self?.medium.accessoryType = (aquariumTempTarget == 20) ? .checkmark : .none
      self?.max.accessoryType = (aquariumTempTarget == 255) ? .checkmark : .none
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
