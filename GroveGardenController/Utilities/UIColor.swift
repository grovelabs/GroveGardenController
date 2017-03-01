import class UIKit.UIColor
import CoreGraphics

public extension UIColor {
  // no more x/255
  convenience init (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
    self.init(red: r/255, green: g/255, blue: b/255, alpha: a)
  }

  public class var gr_orange: UIColor {
    return UIColor(r: 252, g: 134, b: 32)
  }

  public static var gr_orange_dark: UIColor {
    return UIColor(r: 205, g: 96, b: 3)
  }

  public static var gr_grey_disabled: UIColor {
    return UIColor(r: 143, g: 142, b: 148)
  }

  public static var gr_blue_enabled: UIColor {
    return UIColor(r: 0, g: 118, b: 255)
  }

}
