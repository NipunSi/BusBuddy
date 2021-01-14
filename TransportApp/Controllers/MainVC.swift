//
//  ViewController.swift
//  TransportApp
//
//  Created by Nipun Singh on 1/8/21.
//

import UIKit
import MapKit
import CoreLocation
import Polyline

class MainVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var getRoutesButton: UIButton!
    @IBOutlet weak var routeMap: MKMapView!
    @IBOutlet weak var currentLocationButton: UIButton!
    
    let mapsAPIKey = "AIzaSyCoTMPOTmWZTkgdLVwNwsRb6e07Uz63GYg"
    let busAPIKey = "f914968b-874d-475f-8913-2ef94b00ab2f"
    var locationManager = CLLocationManager()
    var usingCurrentLocation = false
    
    var fetchedRoutes = [Route]()
    
    var selectedRoute: Route?
    
    var requiredBusShortNames = [String]()
    var requiredStops = [BusStop]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup UI
        getRoutesButton.layer.cornerRadius = 10
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        setupMap()
    }
    
    
    @IBAction func currentLocationPressed(_ sender: Any) {
        //Toggle usingCurrentLocation and adjust the map and origin text field accordingly.
        if usingCurrentLocation {
            originTextField.text = ""
            usingCurrentLocation = false
            currentLocationButton.setImage(UIImage(systemName: "location"), for: .normal)
        } else {
            //Use the location manager to try and fetch the user's coordinates
            if let userLocation = locationManager.location?.coordinate {
                let address = CLGeocoder.init()
                //Covert the user's location into an address for the origin textfield.
                address.reverseGeocodeLocation(CLLocation.init(latitude: userLocation.latitude, longitude: userLocation.longitude)) { (places, error) in
                    if error == nil{
                        if let place = places{
                            print("User is at \(place[0].name ?? ""), \(place[0].locality ?? "")")
                            self.originTextField.text = "\(place[0].name ?? ""), \(place[0].locality ?? "")"
                            
                            self.usingCurrentLocation = true
                            self.currentLocationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func getRoutesPressed(_ sender: Any) {
        getRoutes()
    }
    
    func setupMap() {
        routeMap.delegate = self
        routeMap.showsUserLocation = true
        locationManager.delegate = self
        
        //Check for location autorization
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
        
        //Use the locations manager to fetch the user's location
        if let userLocation = locationManager.location?.coordinate {
            usingCurrentLocation = true
            currentLocationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
            
            //Zoom to user location
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 2000, longitudinalMeters: 2000)
            routeMap.setRegion(viewRegion, animated: false)
            
            //Covert the user's location into an address for the origin textfield.
            let address = CLGeocoder.init()
            address.reverseGeocodeLocation(CLLocation.init(latitude: userLocation.latitude, longitude: userLocation.longitude)) { (places, error) in
                if error == nil{
                    if let place = places{
                        print("User is at \(place[0].name ?? ""), \(place[0].locality ?? "")")
                        self.originTextField.text = "\(place[0].name ?? ""), \(place[0].locality ?? "")"
                    }
                }
            }
        } else {
            usingCurrentLocation = false
            currentLocationButton.setImage(UIImage(systemName: "location"), for: .normal)
        }
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func getRoutes() {
        //Contact the Google Routes API using the origin and destination text field entries. Show the found routes on modal presented tableview.
        fetchedRoutes = []
        dismissKeyboard()
        
        let origin = (originTextField.text)?.replacingOccurrences(of: " ", with: "+")
        let destination = (destinationTextField.text)?.replacingOccurrences(of: " ", with: "+")
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin ?? "")&destination=\(destination ?? "")&mode=transit&transit_mode=bus&alternatives=true&key=\(mapsAPIKey)")!
        print("Google Routes API Request URL: \(url)")
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error with fetching routes: \(error)")
                self.showAlert(title: "No routes were found", message: "Please try again with a different origin or destination address.")
                return
            }
            
            if let data = data {
                do {
                    //Decode the received JSON data into the RouteData struct
                    let routeData = try JSONDecoder().decode(RouteData.self, from: data)
                    
                    print("Found \(routeData.routes.count) route(s)")
                    
                    //Check to see if there were any routes found and display them. Otherwise show an error alert.
                    if routeData.routes.count == 0 {
                        self.showAlert(title: "No routes were found", message: "Please try again with a different origin or destination address.")
                    } else {
                        
                        for route in routeData.routes {
                            self.fetchedRoutes.append(route)
                        }
                        
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "showRoutes", sender: self)
                        }
                    }
                    
                } catch {
                    print(error)
                    self.showAlert(title: "No routes were found", message: "Please try again with a different origin or destination address.")
                }
                
            }
        })
        task.resume()
    }
    
    func showAlert(title: String, message: String) {
        //Show action sheet with given title and message
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel , handler:{ (UIAlertAction)in
                print("Alert dismissed")
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func updateSelectedRoute(route: Route) {
        //Display the user's selected route onto the mapview
        selectedRoute = route
        routeMap.removeOverlays(routeMap.overlays)
        routeMap.removeAnnotations(routeMap.annotations)
        
        //Covert the google polyline into an array of coordinates using the Polyline package
        let polylineCoordinates: [CLLocationCoordinate2D]? = decodePolyline(selectedRoute?.overview_polyline.points ?? "")
        
        //Add the polyline to the mapview
        let polyline = MKPolyline(coordinates: polylineCoordinates!, count: polylineCoordinates!.count)
        routeMap.addOverlay(polyline)
        routeMap.setVisibleMapRect(polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0), animated: true)
        
        //Create and add pins for the origin and destination using the retreived coordinates.
        let originPin = MKPointAnnotation()
        originPin.title = "Start"
        originPin.coordinate = CLLocationCoordinate2D(latitude: route.legs[0].start_location.lat, longitude: route.legs[0].start_location.lng)
        routeMap.addAnnotation(originPin)
        
        let destinationPin = MKPointAnnotation()
        destinationPin.title = "Destination"
        destinationPin.subtitle = "Arrival: \(route.legs[0].arrival_time.text)"
        destinationPin.coordinate = CLLocationCoordinate2D(latitude: route.legs[0].end_location.lat, longitude: route.legs[0].end_location.lng)
        routeMap.addAnnotation(destinationPin)
        
        //Loop through each step in the route and find the required bus stops by checking the step's transit mode (WALKING or TRANSIT)
        for step in route.legs[0].steps {
            if step.travel_mode == "TRANSIT" {
                //Add the required bus and stop for each step to the respective arrays
                requiredBusShortNames.append(step.transit_details?.line.short_name ?? "")
                print("Requires bus \(step.transit_details?.line.name ?? "") aka \(step.transit_details?.line.short_name ?? "")")
                
                print("Bus stop location for \(step.transit_details?.line.short_name ?? ""): \(step.start_location.lat), \(step.start_location.lng).  \(step.transit_details?.departure_stop.name ?? "")")
                
                requiredStops.append(BusStop(name: "\(step.transit_details?.departure_stop.name ?? "")", bus: "\(step.transit_details?.line.short_name ?? "")", latitude: step.start_location.lat, longitude: step.start_location.lng))
                
                //Create pins on the map for each stop on the route along with instruction as the subtitle.
                let stopPin = MKPointAnnotation()
                stopPin.title = "\(step.transit_details?.departure_stop.name ?? "Stop")"
                stopPin.subtitle = "Board bus \(step.transit_details?.line.name ?? "") aka \(step.transit_details?.line.short_name ?? "")"
                stopPin.coordinate = CLLocationCoordinate2D(latitude: step.start_location.lat, longitude: step.start_location.lng)
                routeMap.addAnnotation(stopPin)
            }
        }
        
        //Call the getBus functions to find the locations of the required busses.
        getBus()
    }
    
    //Use the 511 API to get all bus activity from the Livermore Amador Valley Transit
    func getBus() {
        let url = URL(string: "http://api.511.org/transit/VehicleMonitoring?api_key=\(busAPIKey)&agency=WH&format=json")!
        print("511 Bus API Request URL: \(url)")
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error with fetching buses: \(error)")
                return
            }
            
            if let data = data {
                do {
                    //Covert the received JSON into the Bus struct
                    let busData = try JSONDecoder().decode(Bus.self, from: data)
                    
                    let buses = busData.data.serviceDelivery.vehicleMonitoringDelivery.vehicleActivity
                    
                    print("Found \(buses.count) buses")
                    
                    for bus in buses {
                        //Check each retrieved bus to against the required buses array
                        if self.requiredBusShortNames.contains(bus.monitoredVehicleJourney.lineRef) {
                            
                            //Check which stop the bus will be boarded at
                            let requiredStop = self.requiredStops.first { (stop) -> Bool in
                                if stop.bus == bus.monitoredVehicleJourney.lineRef {
                                    return true
                                } else {
                                    return false
                                }
                            }
                            
                            //Calculate the distance between the bus' current location and the bus stop's location in miles
                            let busLocation = CLLocation(latitude: Double(bus.monitoredVehicleJourney.vehicleLocation.latitude) ?? 0, longitude: Double(bus.monitoredVehicleJourney.vehicleLocation.longitude) ?? 0)
                            let stopLocation = CLLocation(latitude: requiredStop?.latitude ?? 0, longitude: requiredStop?.longitude ?? 0)
                            let distanceInMeters = busLocation.distance(from: stopLocation)
                            let distanceInMiles = distanceInMeters/1609.344
                            
                            //Add the bus annotation with the full name as the subtitle and the shortname and distance as the title.
                            let busPin = MKPointAnnotation()
                            busPin.subtitle = "\(bus.monitoredVehicleJourney.publishedLineName ?? "Bus")"
                            busPin.title = "Bus \(bus.monitoredVehicleJourney.lineRef) - \(String(format: "%.1f", distanceInMiles)) mi from stop"
                            busPin.coordinate = CLLocationCoordinate2D(latitude: Double(bus.monitoredVehicleJourney.vehicleLocation.latitude) ?? 0, longitude: Double(bus.monitoredVehicleJourney.vehicleLocation.longitude) ?? 0)
                            
                            self.routeMap.addAnnotation(busPin)
                            
                            print("Added annotation for \(bus.monitoredVehicleJourney.publishedLineName ?? "Bus") aka \(bus.monitoredVehicleJourney.lineRef) at \(bus.monitoredVehicleJourney.vehicleLocation.latitude), \(bus.monitoredVehicleJourney.vehicleLocation.longitude)")
                        }
                    }
                } catch {
                    //If the app is unable to get data back from the 511 API, show an error alert
                    print("Bus API may be down: \(error)")
                    self.showAlert(title: "Unable to show buses on map.", message: "The app was unable to reach the buses at the moment. Please try again later.")
                }
                
            }
        })
        task.resume()
    }
    
    //Set the styling of the route polyline
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let routePolyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = UIColor.systemBlue.withAlphaComponent(0.9)
            renderer.lineWidth = 5
            return renderer
        }
        
        return MKOverlayRenderer()
    }
    
    //Customize the styling for the different mapview annotations
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
        annotationView.displayPriority = .required
        annotationView.animatesWhenAdded = true
        
        switch annotation.title! {
        case "Start":
            annotationView.markerTintColor = UIColor.systemGreen
        case "Destination":
            annotationView.markerTintColor = UIColor.systemRed
        case "My Location":
            return nil
        case let str where str!.contains("mi from stop"): //Bus Annotations
            annotationView.glyphImage = UIImage(systemName: "bus")
            annotationView.markerTintColor = UIColor.systemBackground
        default:
            annotationView.markerTintColor = UIColor.systemBlue
            annotationView.glyphImage = UIImage(systemName: "octagon.fill")
        }
        
        return annotationView
    }
    
    //When routes are found, show the modal tableview controller and pass the found routes.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RoutesTableVC {
            vc.delegate = self
            vc.fetchedRoutes = fetchedRoutes
        }
        
    }
    
    //Function to dismiss the keyboard when the getRoutesButton is pressed
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

