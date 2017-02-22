extension Notification.Name {
  static let Grove = Notification.Name("Grove")
}

protocol Notifier {
  func sendNotification(_ name: Notification.Name, userInfo: [AnyHashable : Any]?)
}

extension Notifier {
  func sendNotification(_ name: Notification.Name, userInfo: [AnyHashable : Any]? = nil) {
    NotificationCenter.default.post(Notification(name: name, object: nil, userInfo: userInfo))
  }
}

protocol NotificationListener: class {
  func addListener(forNotification notification: Notification.Name, selector: Selector)
}

extension NotificationListener {
  func addListener(forNotification notification: Notification.Name, selector: Selector) {
    NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
  }
}
