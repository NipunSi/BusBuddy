//
//  RoutesTableVC.swift
//  TransportApp
//
//  Created by Nipun Singh on 1/9/21.
//

import UIKit

//Create a custom cell to display information about each route
class RouteCell: UITableViewCell {
    @IBOutlet weak var routeStepsLabel: UILabel!
    @IBOutlet weak var departsLabel: UILabel!
    @IBOutlet weak var arrivesLabel: UILabel!
    @IBOutlet weak var fareLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!    
}

class RoutesTableVC: UITableViewController {
    
    var fetchedRoutes: [Route] = []
    weak var delegate: MainVC!
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "h:mm a"
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedRoutes.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Route #\(section + 1)"
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeCell", for: indexPath) as! RouteCell
        
        let route = fetchedRoutes[indexPath.section]
        
        //Convert the date strings from the API into time strings.
        let departTime = Date(timeIntervalSince1970: TimeInterval(route.legs[0].departure_time.value))
        let arriveTime = Date(timeIntervalSince1970: TimeInterval(route.legs[0].arrival_time.value))
        
        let departTimeString = dateFormatter.string(from: departTime)
        let arriveTimeString = dateFormatter.string(from: arriveTime)
        
        //Fill each of the labels with the relevant route information
        cell.routeStepsLabel.text = "\(route.legs[0].steps.count) steps"
        cell.distanceLabel.text = "\(route.legs[0].distance.text)"
        cell.durationLabel.text = "\(route.legs[0].duration.text)"
        cell.fareLabel.text = "\(route.fare.text)"
        cell.departsLabel.text = "Departs: \(departTimeString)"
        cell.arrivesLabel.text = "Arrives: \(arriveTimeString)"
        
        return cell
    }
    
    //When a cell is tapped, use the delegate to pass the selected route back to the main view 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.updateSelectedRoute(route: fetchedRoutes[indexPath.section])
        dismiss(animated: true, completion: nil)
    }
    
}
