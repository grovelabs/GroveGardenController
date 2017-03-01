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

      self?.waterTempLabel.text = grove.sensors.water.temperature.printableFahrenheit()
      self?.targetTempActionLabel.text = grove.aquariumTempTarget.printableFahrenheit()

      self?.targetTempActionLabel.text = {
        switch grove.aquariumTempTarget {
        case Int.min..<1: return "Off"
        case 19, 20, 21: return "68 ℉"
        case 255..<Int.max: return "78 ℉"
        default: return grove.aquariumTempTarget.printableFahrenheit()
        }
      }()

      self?.pumpScheduleActionLabel.text = "\(grove.pump.schedule.on) min"
    }
  }
}
