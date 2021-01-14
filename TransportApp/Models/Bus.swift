//
//  Bus.swift
//  TransportApp
//
//  Created by Nipun Singh on 1/10/21.
//
//   let bus = try? newJSONDecoder().decode(Bus.self, from: jsonData)

import Foundation

// MARK: - Bus
struct Bus: Codable {
    let data: Siri

    enum CodingKeys: String, CodingKey {
        case data = "Siri"
    }
}

// MARK: - Siri
struct Siri: Codable {
    let serviceDelivery: ServiceDelivery

    enum CodingKeys: String, CodingKey {
        case serviceDelivery = "ServiceDelivery"
    }
}

// MARK: - ServiceDelivery
struct ServiceDelivery: Codable {
    let status: Bool
    let vehicleMonitoringDelivery: VehicleMonitoringDelivery

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case vehicleMonitoringDelivery = "VehicleMonitoringDelivery"
    }
}

// MARK: - VehicleMonitoringDelivery
struct VehicleMonitoringDelivery: Codable {
    let version: String
    let vehicleActivity: [VehicleActivity]

    enum CodingKeys: String, CodingKey {
        case version
        case vehicleActivity = "VehicleActivity"
    }
}

// MARK: - VehicleActivity
struct VehicleActivity: Codable {
    let validUntilTime: String
    let monitoredVehicleJourney: MonitoredVehicleJourney

    enum CodingKeys: String, CodingKey {
        case validUntilTime = "ValidUntilTime"
        case monitoredVehicleJourney = "MonitoredVehicleJourney"
    }
}

// MARK: - MonitoredVehicleJourney
struct MonitoredVehicleJourney: Codable {
    let lineRef: String
    let publishedLineName: String?
    let originRef, originName, destinationRef, destinationName: String?
    let vehicleLocation: VehicleLocation
    let vehicleRef: String
    let monitoredCall: DCall?
    let onwardCalls: OnwardCalls?

    enum CodingKeys: String, CodingKey {
        case lineRef = "LineRef"
        case publishedLineName = "PublishedLineName"
        case originRef = "OriginRef"
        case originName = "OriginName"
        case destinationRef = "DestinationRef"
        case destinationName = "DestinationName"
        case vehicleLocation = "VehicleLocation"
        case vehicleRef = "VehicleRef"
        case monitoredCall = "MonitoredCall"
        case onwardCalls = "OnwardCalls"
    }
}

// MARK: - FramedVehicleJourneyRef
struct FramedVehicleJourneyRef: Codable {
    let dataFrameRef, datedVehicleJourneyRef: String

    enum CodingKeys: String, CodingKey {
        case dataFrameRef = "DataFrameRef"
        case datedVehicleJourneyRef = "DatedVehicleJourneyRef"
    }
}

// MARK: - DCall
struct DCall: Codable {
    let stopPointRef, stopPointName: String
    let vehicleLocationAtStop, vehicleAtStop: String?
    let aimedArrivalTime: String
    
    enum CodingKeys: String, CodingKey {
        case stopPointRef = "StopPointRef"
        case stopPointName = "StopPointName"
        case vehicleLocationAtStop = "VehicleLocationAtStop"
        case vehicleAtStop = "VehicleAtStop"
        case aimedArrivalTime = "AimedArrivalTime"
    }
}


// MARK: - OnwardCalls
struct OnwardCalls: Codable {
    let onwardCall: [DCall]

    enum CodingKeys: String, CodingKey {
        case onwardCall = "OnwardCall"
    }
}

// MARK: - VehicleLocation
struct VehicleLocation: Codable {
    let longitude, latitude: String

    enum CodingKeys: String, CodingKey {
        case longitude = "Longitude"
        case latitude = "Latitude"
    }
}

//MARK: - BusStop
struct BusStop {
    var name: String
    var bus: String
    var latitude: Double
    var longitude: Double
}
