import UIKit

class LightInterruptionsTableViewController: UITableViewController, NotificationListener {
  @IBOutlet weak var onSchedule: UITableViewCell!
  @IBOutlet weak var off: UITableViewCell!
  @IBOutlet weak var harvestMode: UITableViewCell!
  @IBOutlet weak var movieMode: UITableViewCell!
  @IBOutlet weak var photoMode: UITableViewCell!
  @IBOutlet weak var otherMode: UITableViewCell!

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = true

    addListener(forNotification: .Grove, selector: #selector(bindView))
    bindView()
  }

  func bindView() {
    DispatchQueue.main.async { [weak self] in
      guard let grove = GroveManager.shared.grove else {
        return
      }

      let interrupted: Bool = {
        return (grove.light0.interruption != nil) ||
          (grove.light1.interruption != nil) ||
          (grove.light2.interruption != nil)
      }()
      let interruption = grove.light0.interruption

      self?.onSchedule.accessoryType = (!interrupted) ? .checkmark : .none
      self?.off.accessoryType = (interruption?.setting == Light.Settings.Presets.off.settings) ? .checkmark : .none
      self?.harvestMode.accessoryType = (interruption?.setting == Light.Settings.Presets.harvest.settings) ? .checkmark : .none
      self?.movieMode.accessoryType = (interruption?.setting == Light.Settings.Presets.movie.settings) ? .checkmark : .none
      self?.photoMode.accessoryType = (interruption?.setting == Light.Settings.Presets.photo.settings) ? .checkmark : .none

      self?.otherMode.accessoryType = {
        if (!interrupted) { return .none }
        let setting = interruption?.setting
        if (setting == Light.Settings.Presets.off.settings ||
          setting == Light.Settings.Presets.harvest.settings ||
          setting == Light.Settings.Presets.movie.settings ||
          setting == Light.Settings.Presets.photo.settings) {
          return .none
        }
        return .checkmark
      }()
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    switch indexPath.row {
    case 0: GroveManager.shared.grove?.lightSchedule()
    case 1: GroveManager.shared.grove?.lightInterruption(.off)
    case 2: GroveManager.shared.grove?.lightInterruption(.harvest)
    case 3: GroveManager.shared.grove?.lightInterruption(.movie)
    case 4: GroveManager.shared.grove?.lightInterruption(.photo)
    default: break
    }

    tableView.reloadData()
  }

}
