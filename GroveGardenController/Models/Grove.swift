struct Grove {

  enum Event: String {
    case status = "spark/status"
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
  var sensors: Sensors?
  var light0: Light?
  var light1: Light?
  var light2: Light?
  var pump: Pump?
  var fan: Fan?
  var standby: Bool?
  var aquariumTempTarget: Int?

  init(device: SparkDevice,
       serialNumber: String,
       sensors: Sensors? = nil,
       light0: Light? = nil,
       light1: Light? = nil,
       light2: Light? = nil,
       pump: Pump? = nil,
       fan: Fan? = nil,
       standby: Bool? = nil,
       aquariumTempTarget: Int? = nil) {
    self.device = device
    self.serialNumber = serialNumber
    self.sensors = sensors
    self.light0 = light0
    self.light1 = light1
    self.light2 = light2
    self.pump = pump
    self.fan = fan
    self.standby = standby
    self.aquariumTempTarget = aquariumTempTarget
  }
}
