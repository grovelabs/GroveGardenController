struct Grove {

  enum Event: String {
    case system = "state-groveSystem"
    case light0 = "state-light0"
    case light1 = "state-light1"
    case light2 = "state-light2"
    case pump = "state-pump0"
    case fan = "state-fan0"
    case sensors = "reading-sensors"
    case energy = "reading-energy"
    case watchdog = "log-watchdogTime"
    case i2cFatal = "error-i2cFatal"
    case safeMode = "error-safeMode"
    case overCurrent = "alarm-5vOvercurrent"
  }

  var device: SparkDevice
  var serialNumber: String
  var connected: Bool
  var sensors: Sensors
  var light0: Light
  var light1: Light
  var light2: Light
  var pump: Pump
  var fan: Fan

  //  let id: String
  //  let groveSystem: String
}
