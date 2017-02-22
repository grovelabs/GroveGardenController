open class GroveManager: NSObject, Notifier {
  static let shared = GroveManager()
  override fileprivate init() {}

  var device: SparkDevice? = nil {
    didSet {
      switch (device, oldValue) {
      case (let device?, _):
        // new device was set
        SparkCloud.sharedInstance().subscribeToDeviceEvents(withPrefix: nil,
                                                            deviceID: device.id,
                                                            handler: eventParser)

        print("device:", device)
        Grove.getAllVariables(device: device) { grove in
          GroveManager.shared.grove = grove
        }

      case (nil, let oldDevice?):
        // device was unset
        SparkCloud.sharedInstance().unsubscribeFromEvent(withID: oldDevice.id)
      default: break
      }
    }
  }

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

  func getDevice(serialNumber: String,
                        completion: @escaping (_ error: Error?) -> Void) {

    loginIfNeeded { error in
      if let error = error { return completion(error) }

      SparkCloud.sharedInstance().getDevice(serialNumber) { (device, error) in
        if let error = error { return completion(error) }
        guard let device = device else { return completion(ParticleError.noDevice) }

        GroveManager.shared.device = device
        Keychain.saveSerial(serialNumber)
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
}
