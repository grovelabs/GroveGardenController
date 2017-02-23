import class UIKit.UITableView
import class UIKit.UITableViewCell

enum CellType: String {
  case gardenDetail
  case garden
}

extension UITableView {
  func dequeueReusableCell(type: CellType, for indexPath: IndexPath) -> UITableViewCell {
    return self.dequeueReusableCell(withIdentifier: type.rawValue, for: indexPath)
  }
}
