enum ParticleError: Swift.Error {
  case noDevice
}

open class GroveManager: NSObject {
  static let shared = GroveManager()
  override fileprivate init() {}

  var device: SparkDevice? = nil
  var grove: Grove? = nil

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
