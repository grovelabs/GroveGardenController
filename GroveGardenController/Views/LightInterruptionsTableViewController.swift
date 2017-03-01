import UIKit

class LightInterruptionsTableViewController: UITableViewController, NotificationListener {
  @IBOutlet weak var off: UITableViewCell!
  @IBOutlet weak var harvestMode: UITableViewCell!
  @IBOutlet weak var movieMode: UITableViewCell!
  @IBOutlet weak var photoMode: UITableViewCell!
  @IBOutlet weak var otherMode: UITableViewCell!
  @IBOutlet weak var resumeSchedule: UITableViewCell!

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

      self?.resumeSchedule.isUserInteractionEnabled = interrupted
      self?.resumeSchedule.textLabel?.textColor = (interrupted) ? .gr_blue_enabled : .gr_grey_disabled

      let interruption = grove.light0.interruption

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

    switch (indexPath.section, indexPath.row) {
    case (0, 0): GroveManager.shared.grove?.lightInterruption(.off)
    case (0, 1): GroveManager.shared.grove?.lightInterruption(.harvest)
    case (0, 2): GroveManager.shared.grove?.lightInterruption(.movie)
    case (0, 3): GroveManager.shared.grove?.lightInterruption(.photo)
    case (1, 0): GroveManager.shared.grove?.lightSchedule()
    default: break
    }

    tableView.reloadData()
  }

}
