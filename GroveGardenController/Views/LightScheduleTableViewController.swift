import UIKit

class LightScheduleTableViewController: UITableViewController, NotificationListener {
  @IBOutlet weak var sunriseDetail: UILabel!
  @IBOutlet weak var brightnessSlider: UISlider!
  @IBOutlet weak var colorTempSlider: UISlider!

  var lightLocation: Light.Location!

  var showTimePicker: Bool = false {
    didSet { tableView.reloadData() }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.clearsSelectionOnViewWillAppear = true

    let clearImage = UIImage()
    colorTempSlider.setMinimumTrackImage(clearImage, for: .normal)
    colorTempSlider.setMaximumTrackImage(clearImage, for: .normal)

    addListener(forNotification: .Grove, selector: #selector(bindView))
    bindView()
  }

  func bindView() {
    DispatchQueue.main.async { [weak self] in
      guard let grove = GroveManager.shared.grove else { return }

      let light: Light = {
        switch self?.lightLocation {
        case .garden?: return grove.light0
        case .seedling?: return grove.light1
        default: return grove.light2
        }
      }()

      self?.sunriseDetail.text = light.schedule.sunriseBegins.secondsToPrintableTime()

      let day = light.schedule.day
      self?.brightnessSlider.setValue(day.intensity.toSliderValue(), animated: false)
      self?.colorTempSlider.setValue(day.colorTemp.toSliderValue(), animated: false)
    }
  }

  @IBAction
  internal func brightnessSliderChanged(_ sender: UISlider) {
    guard let grove = GroveManager.shared.grove else { return }
    let schedule: Light.Schedule = {
      switch lightLocation {
      case .garden?: return grove.light0.schedule
      case .seedling?: return grove.light1.schedule
      default: return grove.light2.schedule
      }
    }()

    let intensity = Int(sender.value * 100)
    let newSchedule = schedule.changeSettings(intensity: intensity)
    grove.lightSchedule(lightLocation, schedule: newSchedule)
  }

  var colorSliderDebounceTimer: Timer = Timer()

  @IBAction
  internal func colorSliderChanged(_ sender: UISlider) {
    // Snap the color slider to the 50% mark
    let roundedValue: Float = {
      switch sender.value {
      case 0.46..<0.54: return 0.5
      default: return sender.value
      }
    }()
    sender.setValue(roundedValue, animated: false)

    // debounce how frequenly the slider changes send OTA commands
    colorSliderDebounceTimer.invalidate()
    colorSliderDebounceTimer = Timer(fireAt: Date().addingTimeInterval(0.25),
                                     interval: 0,
                                     target: self,
                                     selector: #selector(sendNewColor),
                                     userInfo: nil,
                                     repeats: false)
    RunLoop.current.add(colorSliderDebounceTimer, forMode: .defaultRunLoopMode)
  }

  internal func sendNewColor() {
    guard let grove = GroveManager.shared.grove else { return }
    let schedule: Light.Schedule = {
      switch lightLocation {
      case .garden?: return grove.light0.schedule
      case .seedling?: return grove.light1.schedule
      default: return grove.light2.schedule
      }
    }()

    let color = Int(colorTempSlider.value * 100)
    let newSchedule = schedule.changeSettings(color: color)
    grove.lightSchedule(lightLocation, schedule: newSchedule)
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch (lightLocation, indexPath.section, indexPath.row) {
    case (.garden?, 1, _): return UITableViewCell()
    default: return super.tableView(tableView, cellForRowAt: indexPath)
    }

  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 3 where lightLocation != .garden:
      // seedling and aquarium don't need the color temp slider
      return 0

    case 0 where !showTimePicker:
      // don't show the time picker unless we explicitly want it
      return 1

    default:
      return super.tableView(tableView, numberOfRowsInSection: section)
    }
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if (section == 3 && lightLocation != .garden) { return nil }
    return super.tableView(tableView, titleForHeaderInSection: section)
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch (indexPath.section, indexPath.row) {
    case (0, 0): showTimePicker = !showTimePicker
    default: break
    }
    tableView.reloadData()
  }
}
