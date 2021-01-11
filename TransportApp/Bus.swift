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
    //let responseTimestamp: Date
    let producerRef: RRef
    let status: Bool
    let vehicleMonitoringDelivery: VehicleMonitoringDelivery

    enum CodingKeys: String, CodingKey {
        //case responseTimestamp = "ResponseTimestamp"
        case producerRef = "ProducerRef"
        case status = "Status"
        case vehicleMonitoringDelivery = "VehicleMonitoringDelivery"
    }
}

enum RRef: String, Codable {
    case wh = "WH"
}

// MARK: - VehicleMonitoringDelivery
struct VehicleMonitoringDelivery: Codable {
    let version: String
    //let responseTimestamp: Date
    let vehicleActivity: [VehicleActivity]

    enum CodingKeys: String, CodingKey {
        case version
        //case responseTimestamp = "ResponseTimestamp"
        case vehicleActivity = "VehicleActivity"
    }
}

// MARK: - VehicleActivity
struct VehicleActivity: Codable {
    //let recordedAtTime: Date
    let validUntilTime: String
    let monitoredVehicleJourney: MonitoredVehicleJourney

    enum CodingKeys: String, CodingKey {
        //case recordedAtTime = "RecordedAtTime"
        case validUntilTime = "ValidUntilTime"
        case monitoredVehicleJourney = "MonitoredVehicleJourney"
    }
}

// MARK: - MonitoredVehicleJourney
struct MonitoredVehicleJourney: Codable {
    let lineRef: String
    let directionRef: DirectionRef
    let framedVehicleJourneyRef: FramedVehicleJourneyRef
    let publishedLineName: String
    let operatorRef: RRef
    let originRef, originName, destinationRef, destinationName: String
    let monitored: Bool
    //let inCongestion: JSONNull?
    let vehicleLocation: VehicleLocation
    let bearing: String?
    let occupancy: Occupancy
    let vehicleRef: String
    let monitoredCall: DCall?
    let onwardCalls: OnwardCalls?

    enum CodingKeys: String, CodingKey {
        case lineRef = "LineRef"
        case directionRef = "DirectionRef"
        case framedVehicleJourneyRef = "FramedVehicleJourneyRef"
        case publishedLineName = "PublishedLineName"
        case operatorRef = "OperatorRef"
        case originRef = "OriginRef"
        case originName = "OriginName"
        case destinationRef = "DestinationRef"
        case destinationName = "DestinationName"
        case monitored = "Monitored"
        //case inCongestion = "InCongestion"
        case vehicleLocation = "VehicleLocation"
        case bearing = "Bearing"
        case occupancy = "Occupancy"
        case vehicleRef = "VehicleRef"
        case monitoredCall = "MonitoredCall"
        case onwardCalls = "OnwardCalls"
    }
}

enum DirectionRef: String, Codable {
    case e = "E"
    case lp = "LP"
    case w = "W"
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
    //let aimedArrivalTime: Date
    //let expectedArrivalTime: Date?
    //let aimedDepartureTime: Date
    //let expectedDepartureTime: Date?

    enum CodingKeys: String, CodingKey {
        case stopPointRef = "StopPointRef"
        case stopPointName = "StopPointName"
        case vehicleLocationAtStop = "VehicleLocationAtStop"
        case vehicleAtStop = "VehicleAtStop"
        //case aimedArrivalTime = "AimedArrivalTime"
        //case expectedArrivalTime = "ExpectedArrivalTime"
        //case aimedDepartureTime = "AimedDepartureTime"
        //case expectedDepartureTime = "ExpectedDepartureTime"
    }
}

enum Occupancy: String, Codable {
    case seatsAvailable = "seatsAvailable"
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
