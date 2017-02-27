open class GroveManager: NSObject, Notifier {
  static let shared = GroveManager()
  override fileprivate init() {}

  var grove: Grove? = nil {
    didSet {
      sendNotification(.Grove)
    }
  }

  func eventParser(incomingEvent: SparkEvent?, error: Error?) -> Void {
    guard
      let event = incomingEvent,
      let eventType = Grove.Event(rawValue: event.event),
      let dataAsString = event.data,
      let json = try? dataAsString.parseJSON() else {
        // "log-watchdogTime" comes through with non-JSON data...
        return print("eventParser Error:", incomingEvent)
    }

    switch eventType {
    case .light0:
      guard let light = try? Light(json: json) else { return }
      GroveManager.shared.grove?.light0 = light

    case .light1:
      guard let light = try? Light(json: json) else { return }
      GroveManager.shared.grove?.light1 = light

    case .light2:
      guard let light = try? Light(json: json) else { return }
      GroveManager.shared.grove?.light2 = light

    case .pump:
      guard let pump = try? Pump(json: json) else { return }
      GroveManager.shared.grove?.pump = pump

    case .fan:
      guard let fan = try? Fan(json: json) else { return }
      GroveManager.shared.grove?.fan = fan

    case .sensors:
      guard let sensors = try? Sensors(json: json) else { return }
      GroveManager.shared.grove?.sensors = sensors

    default:
      print("Uncaught JSON", eventType, json)
    }
  }

  /**
   1. Logins into SparkCloud
   2. Gets the device from the could
   3. Saves the serial number to the iOS' device's keychain
   4. Gets all the variables required to build a grove object
   5. Saves the new grove object to GroveManager.shared.grove
   */
  func getDevice(serialNumber: String,
                 completion: @escaping (_ error: Error?) -> Void) {

    loginIfNeeded { error in
      if let error = error { return completion(error) }

      SparkCloud.sharedInstance().getDevice(serialNumber) { (device, error) in
        if let error = error { return completion(error) }
        guard let device = device else { return completion(ParticleError.noDevice) }

        Keychain.saveSerial(serialNumber)
        SparkCloud.sharedInstance().subscribeToDeviceEvents(withPrefix: nil,
                                                            deviceID: device.id,
                                                            handler: self.eventParser)
        // TODO: handle offline groves and other failure states
        GroveManager.getAllVariables(device: device) { (grove, error) in
          if let error = error {
            return completion(error)
          }

          GroveManager.shared.grove = grove
        }

        print("device:", device)
        return completion(nil)
      }
    }
  }

  func loginIfNeeded(completion: @escaping (_ error: Error?) -> Void) {
    switch SparkCloud.sharedInstance().isAuthenticated {
    case true:
      completion(nil)
    case false:
      SparkCloud.sharedInstance().login(withUser: Secrets.Particle.username,
                                        password: Secrets.Particle.password,
                                        completion: completion)
    }
  }

  /**
   Calls each variable from the Grove until it has all the data required to build a Grove.

   Completion closure will contain a Grove object, or nil if there was an error.
   */
  static func getAllVariables(device: SparkDevice, completion: @escaping (Grove?, Error?) -> Void) {

    let dispatchVariables = DispatchGroup()

    var _sensors: Sensors? = nil
    var _light0: Light? = nil
    var _light1: Light? = nil
    var _light2: Light? = nil
    var _pump: Pump? = nil
    var _fan: Fan? = nil

    dispatchVariables.enter()
    device.getVariable("sensors") { (data, error) in
      guard
        let jsonString = data as? String,
        let json = try? jsonString.parseJSON(),
        let sensors = try? Sensors(json: json) else {
          return dispatchVariables.leave()
      }
      _sensors = sensors
      dispatchVariables.leave()
    }

    dispatchVariables.enter()
    device.getVariable("light0") { (data, error) in
      guard
        let jsonString = data as? String,
        let json = try? jsonString.parseJSON() else {
          return dispatchVariables.leave()
      }
      _light0 = try? Light(json: json)
      dispatchVariables.leave()
    }

    dispatchVariables.enter()
    device.getVariable("light1") { (data, error) in
      guard
        let jsonString = data as? String,
        let json = try? jsonString.parseJSON() else {
          return dispatchVariables.leave()
      }
      _light1 = try? Light(json: json)
      dispatchVariables.leave()
    }

    dispatchVariables.enter()
    device.getVariable("light2") { (data, error) in
      guard
        let jsonString = data as? String,
        let json = try? jsonString.parseJSON() else {
          return dispatchVariables.leave()
      }
      _light2 = try? Light(json: json)
      dispatchVariables.leave()
    }

    dispatchVariables.enter()
    device.getVariable("pump0") { (data, error) in
      guard
        let jsonString = data as? String,
        let json = try? jsonString.parseJSON() else {
          return dispatchVariables.leave()
      }
      _pump = try? Pump(json: json)
      dispatchVariables.leave()
    }

    dispatchVariables.enter()
    device.getVariable("fan0") { (data, error) in
      guard
        let jsonString = data as? String,
        let json = try? jsonString.parseJSON() else {
          return dispatchVariables.leave()
      }
      _fan = try? Fan(json: json)
      dispatchVariables.leave()
    }

    dispatchVariables.notify(queue: .main) {
      guard
        let name = device.name,
        let sensors = _sensors,
        let light0 = _light0,
        let light1 = _light1,
        let light2 = _light2,
        let pump = _pump,
        let fan = _fan else {
          return completion(nil, nil)
      }
      let grove = Grove(device: device,
                        serialNumber: name,
                        connected: device.connected,
                        sensors: sensors,
                        light0: light0,
                        light1: light1,
                        light2: light2,
                        pump: pump,
                        fan: fan)
      completion(grove, nil)
    }
  }
}
