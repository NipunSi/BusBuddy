//
//  ViewController.swift
//  TransportApp
//
//  Created by Nipun Singh on 1/8/21.
//

//GoogleMaps API Key: AIzaSyCoTMPOTmWZTkgdLVwNwsRb6e07Uz63GYg
//511 API Key: 355d7ec7-4df9-4a4d-af48-2fe270311f2d
//Livermore Amador Transit ID: WH


import UIKit
import MapKit
import CoreLocation
import Polyline

class MainVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var getRoutesButton: UIButton!
    @IBOutlet weak var routeMap: MKMapView!
    
    let mapsAPIKey = "AIzaSyCoTMPOTmWZTkgdLVwNwsRb6e07Uz63GYg"
    let busAPIKey = "355d7ec7-4df9-4a4d-af48-2fe270311f2d"
    
    var fetchedRoutes = [Route]()
    
    var selectedRoute: Route?
    
    var requiredBusShortNames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        routeMap.delegate = self
        routeMap.showsUserLocation = true
        routeMap.userTrackingMode = .follow
        
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
        
        //getRoutes()
        originTextField.text = "Tacobar Livermore"
        destinationTextField.text = "Dublin Bart"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @IBAction func getRoutesPressed(_ sender: Any) {
        getRoutes()
    }
    
    func getRoutes() {
        fetchedRoutes = []
        
        let origin = (originTextField.text)?.replacingOccurrences(of: " ", with: "+")
        let destination = (destinationTextField.text)?.replacingOccurrences(of: " ", with: "+")
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin ?? "")&destination=\(destination ?? "")&mode=transit&transit_mode=bus&alternatives=true&key=\(mapsAPIKey)")!
        print(url)
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error with fetching routes: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error with the response, unexpected status code: \(String(describing: response))")
                return
            }
            
            if let data = data {
                
                do {
                    let routeData = try JSONDecoder().decode(RouteData.self, from: data)
                    
                    print("Found \(routeData.routes.count) route(s)!")
                    
                    for route in routeData.routes {
                        self.fetchedRoutes.append(route)
                    }
                    
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "showRoutes", sender: self)
                    }
                    
                } catch {
                    print(error)
                }
                
            }
        })
        task.resume()
    }
    
    func updateSelectedRoute(route: Route) {
        selectedRoute = route
        routeMap.removeOverlays(routeMap.overlays)
        routeMap.removeAnnotations(routeMap.annotations)
        
        let polylineCoordinates: [CLLocationCoordinate2D]? = decodePolyline(selectedRoute?.overview_polyline.points ?? "")
        print("Got Coordinates: \(polylineCoordinates?.count ?? 0) points")
        
        let polyline = MKPolyline(coordinates: polylineCoordinates!, count: polylineCoordinates!.count)
        routeMap.addOverlay(polyline)
        routeMap.setVisibleMapRect(polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0), animated: true)
        
        let originPin = MKPointAnnotation()
        originPin.title = "Start"
        originPin.coordinate = CLLocationCoordinate2D(latitude: route.legs[0].start_location.lat, longitude: route.legs[0].start_location.lng)
        let destinationPin = MKPointAnnotation()
        destinationPin.title = "Destination"
        destinationPin.coordinate = CLLocationCoordinate2D(latitude: route.legs[0].end_location.lat, longitude: route.legs[0].end_location.lng)
        //routeMap.addAnnotations([originPin, destinationPin])
        routeMap.addAnnotation(originPin)
        routeMap.addAnnotation(destinationPin)
        
        print("This route has \(route.legs.count) leg(s).")
        
        for step in route.legs[0].steps {
            if step.travel_mode == "TRANSIT" {
                print("Requires bus \(step.transit_details?.line.name ?? "") aka \(step.transit_details?.line.short_name ?? "")")
                requiredBusShortNames.append(step.transit_details?.line.short_name ?? "")
            }
        }
        
        getBus()
    }
    
    func getBus() {
        let url = URL(string: "http://api.511.org/transit/VehicleMonitoring?api_key=\(busAPIKey)&agency=WH&format=json")!
        print(url)
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error with fetching busses: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error with the response, unexpected status code: \(String(describing: response))")
                return
            }
            
            if let data = data {
                
                do {
                    let busData = try JSONDecoder().decode(Bus.self, from: data)
                    
                    let busses = busData.data.serviceDelivery.vehicleMonitoringDelivery.vehicleActivity
                    
                    print("Found \(busses.count) busses")
                    for bus in busses {
                                                
                        if self.requiredBusShortNames.contains(bus.monitoredVehicleJourney.lineRef) {
                            let busPin = MKPointAnnotation()
                            busPin.title = "\(bus.monitoredVehicleJourney.publishedLineName)"
                            busPin.coordinate = CLLocationCoordinate2D(latitude: Double(bus.monitoredVehicleJourney.vehicleLocation.latitude) ?? 0, longitude: Double(bus.monitoredVehicleJourney.vehicleLocation.longitude) ?? 0)
                            
                            self.routeMap.addAnnotation(busPin)
                            
                            print("Added annotation for \(bus.monitoredVehicleJourney.publishedLineName) aka \(bus.monitoredVehicleJourney.lineRef) at \(bus.monitoredVehicleJourney.vehicleLocation.latitude), \(bus.monitoredVehicleJourney.vehicleLocation.longitude)")
                        }
                    }
                    
                    
                    
                } catch {
                    print(error)
                }
                
            }
        })
        task.resume()
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let routePolyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = UIColor.systemGreen //UIColor.mySpecialBlue().withAlphaComponent(0.9)
            renderer.lineWidth = 5
            return renderer
        }
        
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        mapView.setCenter(userLocation.coordinate, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
        
        switch annotation.title! {
        case "Start":
            annotationView.markerTintColor = UIColor.systemGreen
        case "Destination":
            annotationView.markerTintColor = UIColor.systemRed
        default:
            annotationView.glyphImage = UIImage(systemName: "bus")
            annotationView.markerTintColor = UIColor.black
        }

        return annotationView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? RoutesTableVC
        {
            vc.delegate = self
            vc.fetchedRoutes = fetchedRoutes
        }
        
    }
    
}

