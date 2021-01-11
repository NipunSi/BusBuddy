//
//  RoutesTableVC.swift
//  TransportApp
//
//  Created by Nipun Singh on 1/9/21.
//

import UIKit

class RouteCell: UITableViewCell {
    @IBOutlet weak var routeNumberLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var timeRangeLabel: UILabel!
    @IBOutlet weak var fareLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!    
}

class RoutesTableVC: UITableViewController {
    
    var fetchedRoutes: [Route] = []
    weak var delegate: MainVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fetchedRoutes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeCell", for: indexPath) as! RouteCell

        let route = fetchedRoutes[indexPath.row]
        
        let date = Date(timeIntervalSince1970: TimeInterval(route.legs[0].departure_time.value))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let departTimeString = dateFormatter.string(from: date)
        
        cell.routeNumberLabel.text = "#\(indexPath.row + 1)"
        cell.distanceLabel.text = "\(route.legs[0].distance.text)"
        cell.durationLabel.text = "\(route.legs[0].duration.text)"
        cell.fareLabel.text = "\(route.fare.text)"
        cell.stepsLabel.text = "\(route.legs[0].steps.count) steps"
        
        cell.timeRangeLabel.text = "Departs at \(departTimeString)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.updateSelectedRoute(route: fetchedRoutes[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
    
}
