import Foundation
import ParticleSDK

open class GroveManager: NSObject, Notifier {
  static let shared = GroveManager()
  override fileprivate init() {}

  var grove: Grove? = nil {
    didSet { sendNotification(.Grove) }
  }

  func eventParser(incomingEvent: SparkEvent?, error: Error?) -> Void {
    guard
      let event = incomingEvent,
      event.deviceID == GroveManager.shared.grove?.device.id,
      let eventType = Grove.Event(rawValue: event.event) else { return }

    guard let dataAsString = event.data,
      let json = try? dataAsString.parseJSON() else {

        // If the device connection is changing status:
        DispatchQueue.main.async { [weak self] in
          if (eventType == .status) {
            self?.sendNotification(.Grove)
          }
        }
        return
    }

    DispatchQueue.main.async {
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

      case .system:
        guard let powerOn = json["powerOn"] as? Bool else { return }
        GroveManager.shared.grove?.standby = !powerOn
        
      default: break
      }
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

        GroveManager.shared.grove = Grove(device: device,
                                          serialNumber: serialNumber)
        if (device.connected) {
          GroveManager.shared.getAllVariables()
        }

        return completion(nil)
      }
    }
  }

  func loginIfNeeded(completion: @escaping (_ error: Error?) -> Void) {
    SparkCloud.sharedInstance().logout()
    switch SparkCloud.sharedInstance().isAuthenticated {
    case true:
      completion(nil)
    case false:
      SparkCloud.sharedInstance().login(withUser: Secrets.Particle.username,
                                        password: Secrets.Particle.password)
      { (error) in
        
          completion(error)
  
      }
    }
  }

  /**
   Calls each variable from the Grove and assigns the responses data to the current grove.
   
   Careful, as each call to this will overwrite each currently held variable.
   */
  func getAllVariables() {
    
    guard let device = self.grove?.device else { return }

    device.getVariable("sensors") { (data, error) in
      guard
        let jsonString = data as? String,
        let json = try? jsonString.parseJSON(),
        let sensors = try? Sensors(json: json) else { return }
      GroveManager.shared.grove?.sensors = sensors
    }

    device.getVariable("light0") { (data, error) in
      guard
        let jsonString = data as? String,
        let json = try? jsonString.parseJSON(),
        let light0 = try? Light(json: json) else { return  }
      GroveManager.shared.grove?.light0 = light0
    }


    device.getVariable("light1") { (data, error) in
      guard
        let jsonString = data as? String,
        let json = try? jsonString.parseJSON(),
        let light1 = try? Light(json: json) else { return  }
      GroveManager.shared.grove?.light1 = light1
    }

    device.getVariable("light2") { (data, error) in
      guard
        let jsonString = data as? String,
        let json = try? jsonString.parseJSON(),
        let light2 = try? Light(json: json) else { return  }
      GroveManager.shared.grove?.light2 = light2
    }

    device.getVariable("pump0") { (data, error) in
      guard
        let jsonString = data as? String,
        let json = try? jsonString.parseJSON(),
        let pump = try? Pump(json: json) else { return }
      GroveManager.shared.grove?.pump = pump
    }

    device.getVariable("fan0") { (data, error) in
      guard
        let jsonString = data as? String,
        let json = try? jsonString.parseJSON(),
        let fan = try? Fan(json: json) else { return }
      GroveManager.shared.grove?.fan = fan
    }

    device.getVariable("groveSystem") { (data, error) in
      guard
        let jsonString = data as? String,
        let json = try? jsonString.parseJSON() else { return }

      if let powerOn = json["powerOn"] as? Bool {
        GroveManager.shared.grove?.standby = !powerOn
      }

      if let aquariumTempTarget = json["aquaTempTarget"] as? Int {
        GroveManager.shared.grove?.aquariumTempTarget = aquariumTempTarget
      }
    }
  }
}
