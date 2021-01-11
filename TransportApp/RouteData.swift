//
//  Route.swift
//  TransportApp
//
//  Created by Nipun Singh on 1/8/21.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let routeData = try? newJSONDecoder().decode(RouteData.self, from: jsonData)

import Foundation

// MARK: - RouteData
struct RouteData: Codable {
   // let geocodedWaypoints: [GeocodedWaypoint]
    let routes: [Route]
    //let status: String
}

// MARK: - GeocodedWaypoint
struct GeocodedWaypoint: Codable {
    let geocoderStatus, placeID: String
    let types: [String]
}

// MARK: - Route
struct Route: Codable {
    let bounds: Bounds
    let copyrights: String
    let fare: Fare
    let legs: [Leg]
    let overview_polyline: Polyline
    let summary: String
    let warnings: [String]
    //let waypointOrder: [Any?]
}

// MARK: - Bounds
struct Bounds: Codable {
    let northeast, southwest: Northeast
}

// MARK: - Northeast
struct Northeast: Codable {
    let lat, lng: Double
    //let coordinates: Coordinates
}

struct Coordinates: Codable {
    let lat, lng: Double
}

// MARK: - Fare
struct Fare: Codable {
    let currency, text: String
    let value: Int
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
    //let trafficSpeedEntry, viaWaypoint: [Any?]
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
    let html_instructions: String?
    let polyline: Polyline
    let start_location: Northeast
    let steps: [Step]?
    let travel_mode: String
    let transit_details: TransitDetails?
    let maneuver: String?
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
    let headsign: String
    let line: Line
    let num_stops: Int
}

// MARK: - Stop
struct Stop: Codable {
    let location: Northeast
    let name: String
}

// MARK: - Line
struct Line: Codable {
    let agencies: [Agency]
    let color, name, short_name, text_color: String
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
}

