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

  func bindView() {
    DispatchQueue.main.async { [weak self] in
      guard let grove = GroveManager.shared.grove else { return }

      self?.gardenDetailLabel.text = grove.light0.schedule.printableSchedule()
      self?.seedlingDetailLabel.text = grove.light1.schedule.printableSchedule()
      self?.aquariumDetailLabel.text = grove.light2.schedule.printableSchedule()
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
