import UIKit

class GardenDetailTableViewCell: UITableViewCell {
  @IBOutlet weak var icon: UIImageView!
  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var subtitle: UILabel!
  @IBOutlet weak var callToAction: UILabel!

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}

class GardenTableViewCell: UITableViewCell {
  @IBOutlet weak var icon: UIImageView!
  @IBOutlet weak var title: UILabel!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}

class GardenTableViewController: UITableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = true
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 3
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0: return 3
    case 1: return 2
    case 2: return 2
    default: return 0
    }
  }

  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return (section == 0) ? 0 : 52
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    switch (indexPath.section, indexPath.row) {
    case (0, 0):
      let cell = tableView.dequeueReusableCell(type: .gardenDetail, for: indexPath) as! GardenDetailTableViewCell
      cell.title.text = "Lights"
      cell.subtitle.text = "8:00 AM - 11:00 PM"
      cell.callToAction.text = "Garden Light On"
      cell.imageView?.image = UIImage(named: "lights")!
      return cell

    case (0, 1):
      let cell = tableView.dequeueReusableCell(type: .gardenDetail, for: indexPath) as! GardenDetailTableViewCell
      cell.title.text = "Air"
      cell.subtitle.text = "70℃"
      cell.callToAction.text = "Fans On"
      cell.imageView?.image = UIImage(named: "air")!
      return cell

    case (0, 2):
      let cell = tableView.dequeueReusableCell(type: .gardenDetail, for: indexPath) as! GardenDetailTableViewCell
      cell.title.text = "Water"
      cell.subtitle.text = "68℃"
      cell.callToAction.text = "Pumps On"
      cell.imageView?.image = UIImage(named: "water")!
      return cell

    case (1, 0):
      let cell = tableView.dequeueReusableCell(type: .garden, for: indexPath) as! GardenTableViewCell
      cell.title.text = "Log out"
      return cell

    case (1, 1):
      let cell = tableView.dequeueReusableCell(type: .garden, for: indexPath) as! GardenTableViewCell
      cell.title.text = "Almanac"
      return cell

    case (2, 0):
      let cell = tableView.dequeueReusableCell(type: .gardenDetail, for: indexPath) as! GardenDetailTableViewCell
      cell.title.text = "System Info"
      cell.subtitle.text = "GR-ECO-00-009005"
      cell.callToAction.text = "Power On"
      return cell

    case (2, 1):
      let cell = tableView.dequeueReusableCell(type: .gardenDetail, for: indexPath) as! GardenDetailTableViewCell
      cell.title.text = "Wifi Connection"
      cell.subtitle.text = ""
      cell.callToAction.text = "Online"
      return cell

    default:
      return tableView.dequeueReusableCell(type: .garden, for: indexPath)
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch (indexPath.section, indexPath.row) {
    case (1, 0):
      Keychain.clearSerial()
      Storyboard.switchTo(.login)
    default:
      break
    }
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 77
  }

}
