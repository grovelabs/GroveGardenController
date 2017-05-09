extension Grove {

  func pumpSchedule() {
    device.callFunction("setPump", withArguments: ["schedule-resume"], completion: nil)
  }

  func pumpSchedule(_ schedule: Pump.Schedule) {
    let scheduleString: String = {
      let onString = String(format: "%03d", Int(schedule.on / 60))
      let offString = String(format: "%03d", Int(schedule.off / 60))
      return "schedule-\(onString):\(offString)"
    }()
    device.callFunction("setPump", withArguments: [scheduleString], completion: nil)
  }

  func pumpInterruption(on: Bool) {
    let stateString = (on) ? "1" : "0"
    let interruptionString = "temp-\(stateString):0030"
    device.callFunction("setPump", withArguments: [interruptionString], completion: nil)
  }

  enum AquariumHeaterTargetTemperatures: String {
    case off = "000"
    case medium = "020"
    case max = "255"
  }

  func setAquariumHeaterTargetTemperature(_ temp: AquariumHeaterTargetTemperatures) {
    let targetString = "aquariumHeaterTargetTemperature-" + temp.rawValue

    device.callFunction("muxFunction", withArguments: [targetString]) { (data, error) in
      guard error == nil,
        let data = data as Int?,
        data == 1,
        let value = Int(temp.rawValue) else { return }
      GroveManager.shared.grove?.aquariumTempTarget = value
    }
  }
}
