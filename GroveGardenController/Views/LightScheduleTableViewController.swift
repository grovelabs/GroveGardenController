import UIKit

class LightScheduleTableViewController: UITableViewController, NotificationListener {
  @IBOutlet weak var sunriseDetail: UILabel!
  @IBOutlet weak var sunrisePicker: UIDatePicker!
  @IBOutlet weak var brightnessSlider: UISlider!
  @IBOutlet weak var dayLengthPreset1: UITableViewCell!
  @IBOutlet weak var dayLengthPreset2: UITableViewCell!
  @IBOutlet weak var dayLengthPreset3: UITableViewCell!
  @IBOutlet weak var dayLengthCustomLabel: UILabel!
  @IBOutlet weak var dayLengthCustomDetailLabel: UILabel!
  @IBOutlet weak var dayLengthPicker: UIDatePicker!
  @IBOutlet weak var colorTempSlider: UISlider!

  var lightLocation: Light.Location!

  var showSunrisePicker: Bool = false
  var showDayLengthPicker: Bool = false

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

      let sunrise = light.schedule.sunriseBegins

      self?.sunriseDetail.text = sunrise.toPrintableTime()

      guard
        let sunriseDate = sunrise.toDate(),
        let nightDate = light.schedule.nightBegins.toDate() else {
          return
      }

      self?.sunrisePicker.setDate(sunriseDate, animated: false)

      self?.dayLengthCustomDetailLabel.text = {
        switch Date.timeBetween(sunriseDate, nightDate).hoursAndMinutes() {
        case (0, let minutes): return "\(minutes) min"
        case (1, 0): return "1 hour"
        case (let hours, 0): return "\(hours) hours"
        case (1, let minutes): return "1 hour \(minutes) min"
        case (let hours, let minutes): return "\(hours)hrs \(minutes)min"
        }
      }()

      self?.dayLengthPicker.datePickerMode = .countDownTimer
      self?.dayLengthPicker.countDownDuration = nightDate.timeIntervalSince(sunriseDate)

      let day = light.schedule.day
      self?.brightnessSlider.setValue(day.intensity.toSliderValue(), animated: false)
      self?.colorTempSlider.setValue(day.colorTemp.toSliderValue(), animated: false)
    }
  }

  private func showAlert() {
    let alertController = UIAlertController(title: "Day length is too short",
                                            message: "A day must be at least an hour.",
                                            preferredStyle: .alert)
    let alert = UIAlertAction(title: "OK", style: .default) { _ in
      alertController.dismiss(animated: true, completion: nil)
    }
    alertController.addAction(alert)
    self.present(alertController, animated: true, completion: nil)
  }


  @IBAction
  internal func sunrisePickerChanged(_ sender: UIDatePicker) {
    guard let grove = GroveManager.shared.grove else { return }
    let schedule: Light.Schedule = {
      switch lightLocation {
      case .garden?: return grove.light0.schedule
      case .seedling?: return grove.light1.schedule
      default: return grove.light2.schedule
      }
    }()

    do {
      let newSchedule = try schedule.changeSettings(sunriseBegins: sender.date.seconds())
      grove.lightSchedule(lightLocation, schedule: newSchedule)
    } catch {
      showAlert()
    }
  }

  @IBAction
  func dayLengthPickerChanged(_ sender: UIDatePicker) {
    guard sender.countDownDuration >= 3600 else {
      sender.countDownDuration = 3600
      showAlert()
      return dayLengthPickerChanged(sender)
    }
    guard let grove = GroveManager.shared.grove else { return }
    let schedule: Light.Schedule = {
      switch lightLocation {
      case .garden?: return grove.light0.schedule
      case .seedling?: return grove.light1.schedule
      default: return grove.light2.schedule
      }
    }()

    do {
      let dayLength = Int(sender.countDownDuration)
      let newSchedule = try schedule.changeSettings(dayLength: dayLength)
      grove.lightSchedule(lightLocation, schedule: newSchedule)
    } catch {
      showAlert()
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

    do {
      let intensity = Int(sender.value * 100)
      let newSchedule = try schedule.changeSettings(intensity: intensity)
      grove.lightSchedule(lightLocation, schedule: newSchedule)
    } catch {
      showAlert()
    }
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

    do {
      let color = Int(colorTempSlider.value * 100)
      let newSchedule = try schedule.changeSettings(color: color)
      grove.lightSchedule(lightLocation, schedule: newSchedule)
    } catch {
      showAlert()
    }
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch (indexPath.section, indexPath.row) {
    case (0, 1): return (showSunrisePicker) ? 219 : 0
    case (1, 0...2) where lightLocation == .aquarium: return 0
    case (1, 4): return (showDayLengthPicker) ? 219 : 0
    case (3, _) where lightLocation != .garden: return 0
    default: return super.tableView(tableView, heightForRowAt: indexPath)
    }
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if (section == 3 && lightLocation != .garden) { return nil }
    return super.tableView(tableView, titleForHeaderInSection: section)
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch (indexPath.section, indexPath.row) {
    case (0, 0): showSunrisePicker = !showSunrisePicker
    case (1, 0): sendPresetDayLength(12 * 60 * 60)
    case (1, 1): sendPresetDayLength(15 * 60 * 60)
    case (1, 2): sendPresetDayLength(18 * 60 * 60)
    case (1, 3): showDayLengthPicker = !showDayLengthPicker
    default: break
    }
    tableView.reloadData()
  }

  private func sendPresetDayLength(_ dayLength: Int) {
    guard let grove = GroveManager.shared.grove else { return }
    let schedule: Light.Schedule = {
      switch lightLocation {
      case .garden?: return grove.light0.schedule
      case .seedling?: return grove.light1.schedule
      default: return grove.light2.schedule
      }
    }()
    do {
      let newSchedule = try schedule.changeSettings(dayLength: dayLength)
      grove.lightSchedule(lightLocation, schedule: newSchedule)
    } catch {
      showAlert()
    }
  }
}
