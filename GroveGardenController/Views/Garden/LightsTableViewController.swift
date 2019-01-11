import UIKit

class LightsTableViewController: UITableViewController, NotificationListener {
  @IBOutlet weak var gardenDetailLabel: UILabel!
  @IBOutlet weak var seedlingDetailLabel: UILabel!
  @IBOutlet weak var aquariumDetailLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.clearsSelectionOnViewWillAppear = true

    addListener(forNotification: .Grove, selector: #selector(bindView))
    bindView()
  }

  deinit {
    removeListener(forNotification: .Grove)
  }

  @objc func bindView() {
    guard let grove = GroveManager.shared.grove else { return }

    func sunriseToNight(_ schedule: Light.Schedule?) -> String {
      guard
        let sunrise = schedule?.sunriseBegins.printable(),
        let night = schedule?.nightBegins.printable() else { return "" }
      return sunrise + " - " + night
    }

    gardenDetailLabel.text = sunriseToNight(grove.light0?.schedule)
    seedlingDetailLabel.text = sunriseToNight(grove.light1?.schedule)
    aquariumDetailLabel.text = sunriseToNight(grove.light2?.schedule)

    if (!grove.device.connected) {
      let _ = navigationController?.popToRootViewController(animated: true)
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)

    switch segue.identifier {
    case let identifier? where identifier == "toGarden":
      let vc = segue.destination as! LightScheduleTableViewController
      vc.lightLocation = .garden
    case let identifier? where identifier == "toSeedling":
      let vc = segue.destination as! LightScheduleTableViewController
      vc.lightLocation = .seedling
    case let identifier? where identifier == "toAquarium":
      let vc = segue.destination as! LightScheduleTableViewController
      vc.lightLocation = .aquarium
    default: break
    }
  }

}
