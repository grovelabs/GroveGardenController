extension Grove {

  func fanSchedule() {
    device.callFunction("setFan", withArguments: ["schedule-resume"], completion: nil)
  }

  func fanSchedule(_ speed: Fan.Speed) {
    let scheduleString = "schedule-\(speed.digit):1"
    device.callFunction("setFan", withArguments: [scheduleString], completion: nil)
  }

  func fanInterruption(_ speed: Fan.Speed) {
    let interruptionString = "temp-\(speed.digit):0:0030"
    device.callFunction("setFan", withArguments: [interruptionString], completion: nil)
  }

}
