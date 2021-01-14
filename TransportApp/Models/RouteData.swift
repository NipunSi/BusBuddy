//
//  Route.swift
//  TransportApp
//
//  Created by Nipun Singh on 1/8/21.
//

//   let routeData = try? newJSONDecoder().decode(RouteData.self, from: jsonData)

import Foundation

// MARK: - RouteData
struct RouteData: Codable {
    let routes: [Route]
}

// MARK: - GeocodedWaypoint
struct GeocodedWaypoint: Codable {
    let geocoderStatus, placeID: String
    let types: [String]
}

// MARK: - Route
struct Route: Codable {
    let bounds: Bounds
    let fare: Fare
    let legs: [Leg]
    let overview_polyline: Polyline
}

// MARK: - Bounds
struct Bounds: Codable {
    let northeast, southwest: Northeast
}

// MARK: - Northeast
struct Northeast: Codable {
    let lat, lng: Double
}

struct Coordinates: Codable {
    let lat, lng: Double
}

// MARK: - Fare
struct Fare: Codable {
    let currency, text: String
    let value: Float
}

// MARK: - Leg
struct Leg: Codable {
    let arrival_time, departure_time: Time
    let distance, duration: Distance
    let end_address: String
    let end_location: Northeast
    let start_address: String
    let start_location: Northeast
    let steps: [Step]
}

// MARK: - Time
struct Time: Codable {
    let text, time_zone: String
    let value: Int
}

// MARK: - Distance
struct Distance: Codable {
    let text: String
    let value: Int
}

// MARK: - Step
struct Step: Codable {
    let distance, duration: Distance
    let end_location: Northeast
    let polyline: Polyline
    let start_location: Northeast
    let steps: [Step]?
    let travel_mode: String
    let transit_details: TransitDetails?
}

// MARK: - Polyline
struct Polyline: Codable {
    let points: String
}

// MARK: - TransitDetails
struct TransitDetails: Codable {
    let arrival_stop: Stop
    let arrival_time: Time
    let departure_stop: Stop
    let departure_time: Time
    let line: Line
}

// MARK: - Stop
struct Stop: Codable {
    let location: Northeast
    let name: String
}

// MARK: - Line
struct Line: Codable {
    let agencies: [Agency]
    let name, short_name: String
    let vehicle: Vehicle
}

// MARK: - Agency
struct Agency: Codable {
    let name, phone: String
    let url: String
}

// MARK: - Vehicle
struct Vehicle: Codable {
    let icon, name, type: String
}

enum TravelMode {
    case transit
    case walking
    case driving
}

