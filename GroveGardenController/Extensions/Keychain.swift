import Foundation

struct Keychain {

  static private let serialNumberKey: NSString = "GroveSerialNumber"

  static private let kSecClassValue = NSString(format: kSecClass)
  static private let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
  static private let kSecValueDataValue = NSString(format: kSecValueData)
  static private let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
  static private let kSecAttrServiceValue = NSString(format: kSecAttrService)
  static private let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
  static private let kSecReturnDataValue = NSString(format: kSecReturnData)
  static private let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)

  static private let userAccount = "AuthenticatedUser"
  static private let accessGroup = "SecuritySerivice"

  public static func saveSerial(_ serialNumber: String) {
    save(serialNumberKey, data: serialNumber as NSString)
  }

  public static func clearSerial() {
    clear(serialNumberKey)
  }

  public static func loadSerial() -> String? {
    return load(serialNumberKey) as? String
  }

  private static func save(_ service: NSString, data: NSString) {
    guard let dataFromString = data.data(using: String.Encoding.utf8.rawValue,
                                         allowLossyConversion: false) else { return }

    let keychainQuery = NSMutableDictionary(objects: [kSecClassGenericPasswordValue,
                                                      service,
                                                      userAccount,
                                                      dataFromString],
                                            forKeys: [kSecClassValue,
                                                      kSecAttrServiceValue,
                                                      kSecAttrAccountValue,
                                                      kSecValueDataValue])

    SecItemDelete(keychainQuery as CFDictionary)
    SecItemAdd(keychainQuery as CFDictionary, nil)
  }

  private static func clear(_ service: NSString) {
    let dummyData: NSString = "dummyData"
    guard let dataFromString = dummyData.data(using: String.Encoding.utf8.rawValue,
                                              allowLossyConversion: false) else { return }

    let keychainQuery = NSMutableDictionary(objects: [kSecClassGenericPasswordValue,
                                                      service,
                                                      userAccount,
                                                      dataFromString],
                                            forKeys: [kSecClassValue,
                                                      kSecAttrServiceValue,
                                                      kSecAttrAccountValue,
                                                      kSecValueDataValue])

    SecItemDelete(keychainQuery as CFDictionary)
  }

  private static func load(_ service: NSString) -> NSString? {
    let keychainQuery = NSMutableDictionary(objects: [kSecClassGenericPasswordValue,
                                                      service,
                                                      userAccount,
                                                      kCFBooleanTrue,
                                                      kSecMatchLimitOneValue],
                                            forKeys: [kSecClassValue,
                                                      kSecAttrServiceValue,
                                                      kSecAttrAccountValue,
                                                      kSecReturnDataValue,
                                                      kSecMatchLimitValue])

    var dataTypeRef: AnyObject?
    let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)

    guard status == errSecSuccess,
      let retrievedData = dataTypeRef as? Data else {
        return nil
    }

    return NSString(data: retrievedData, encoding: String.Encoding.utf8.rawValue)
  }
}
