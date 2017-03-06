import Foundation
import class UIKit.UITableView
import class UIKit.UITableViewCell

extension UITableView {

  enum CellType: String {
    case gardenBasic
    case gardenDetail
//    case airBasic
//    case airInterruptionBasic
  }

  func dequeueReusableCell(type: UITableView.CellType, for indexPath: IndexPath) -> UITableViewCell {
    return self.dequeueReusableCell(withIdentifier: type.rawValue, for: indexPath)
  }
}
