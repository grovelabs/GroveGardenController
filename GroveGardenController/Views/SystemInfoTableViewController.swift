import UIKit
import ParticleDeviceSetupLibrary

class SystemInfoTableViewController: UITableViewController {
  @IBOutlet weak var serialNumberDetailLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.clearsSelectionOnViewWillAppear = true

    serialNumberDetailLabel.text = GroveManager.shared.grove?.serialNumber ?? ""
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    switch (indexPath.section, indexPath.row) {
    case (0, 1):
      Keychain.clearSerial()
      GroveManager.shared.grove = nil
      Storyboard.switchTo(.login)

    case (1, 0):
      let c = SparkSetupCustomization.sharedInstance()
      c?.deviceName = "Grove Garden"
      c?.brandName = "Grove"
      c?.productSlug = "grove"
      c?.brandImageBackgroundColor = .gr_orange
      c?.brandImage = UIImage(named: "")
      c?.disableLogOutOption = true
      c?.allowSkipAuthentication = true
      c?.disableDeviceRename = true
      c?.networkNamePrefix = "Grove"
      c?.pageBackgroundColor = .white
      //      c?.normalTextFontName = "Avenir-Roman"
      //      c?.boldTextFontName = "Avenir-Medium"
      //      c?.headerTextFontName = "Avenir-Medium"
      c?.elementBackgroundColor = .gr_orange
      c?.linkTextColor = .gr_orange

      if let vc = SparkSetupMainController(setupOnly: true) {
        self.present(vc, animated: true, completion: nil)
      }

    default: break
    }

    tableView.reloadData()
  }
}
