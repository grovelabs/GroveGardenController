import UIKit

class AirTableViewController: UITableViewController, NotificationListener {
  @IBOutlet weak var airTempLabel: UILabel!
  @IBOutlet weak var humidityLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.clearsSelectionOnViewWillAppear = true

    addListener(forNotification: .Grove, selector: #selector(bindView))
    bindView()
  }

  func bindView() {
    DispatchQueue.main.async { [weak self] in
      guard let grove = GroveManager.shared.grove else { return }
      let sensors = grove.sensors

      self?.airTempLabel.text = (sensors.air.temperature != nil) ? "\(grove.sensors.air.temperature!) ℃" : "No data"
      self?.humidityLabel.text = (sensors.air.humidity != nil) ? "\(grove.sensors.air.humidity!)%" : "No data"
    }
  }

}
