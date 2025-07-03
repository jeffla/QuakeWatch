//
//  Earthquake.swift
//  QuakeWatch
//
//  Created by Jeff Lacey on 7/3/25.
//

import Foundation

struct EarthquakeResponse: Codable {
    let type: String
    let metadata: Metadata
    let features: [EarthquakeFeature]
}

struct Metadata: Codable {
    let generated: Int
    let url: String
    let title: String
    let status: Int
    let api: String
    let count: Int
}

struct EarthquakeFeature: Codable {
    let type: String
    let properties: EarthquakeProperties
    let geometry: EarthquakeGeometry
    let id: String
}

struct EarthquakeProperties: Codable {
    let mag: Double?
    let place: String?
    let time: Int
    let updated: Int
    let tz: Int?
    let url: String
    let detail: String
    let felt: Int?
    let cdi: Double?
    let mmi: Double?
    let alert: String?
    let status: String
    let tsunami: Int
    let sig: Int
    let net: String
    let code: String
    let ids: String
    let sources: String
    let types: String
    let nst: Int?
    let dmin: Double?
    let rms: Double?
    let gap: Double?
    let magType: String?
    let type: String?
    let title: String?
}

struct EarthquakeGeometry: Codable {
    let type: String
    let coordinates: [Double]
}

struct Earthquake: Identifiable, Equatable {
    let id: String
    let magnitude: Double
    let location: String
    let time: Date
    let latitude: Double
    let longitude: Double
    let depth: Double
    let url: String
    
    init(from feature: EarthquakeFeature) {
        self.id = feature.id
        self.magnitude = feature.properties.mag ?? 0.0
        self.location = feature.properties.place ?? "Unknown Location"
        self.time = Date(timeIntervalSince1970: TimeInterval(feature.properties.time) / 1000)
        self.latitude = feature.geometry.coordinates.count > 1 ? feature.geometry.coordinates[1] : 0.0
        self.longitude = feature.geometry.coordinates.count > 0 ? feature.geometry.coordinates[0] : 0.0
        self.depth = feature.geometry.coordinates.count > 2 ? feature.geometry.coordinates[2] : 0.0
        self.url = feature.properties.url
    }
}

extension Earthquake {
    var formattedTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: time, relativeTo: Date())
    }
    
    var magnitudeCategory: MagnitudeCategory {
        switch magnitude {
        case 0..<2.5:
            return .minor
        case 2.5..<4.5:
            return .light
        case 4.5..<6.0:
            return .moderate
        case 6.0..<7.0:
            return .strong
        case 7.0..<8.0:
            return .major
        case 8.0...:
            return .great
        default:
            return .unknown
        }
    }
}

enum MagnitudeCategory: String, CaseIterable {
    case minor = "Minor"
    case light = "Light"
    case moderate = "Moderate"
    case strong = "Strong"
    case major = "Major"
    case great = "Great"
    case unknown = "Unknown"
}