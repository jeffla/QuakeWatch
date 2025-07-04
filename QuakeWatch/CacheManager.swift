//
//  CacheManager.swift
//  QuakeWatch
//
//  Created by Jeff Lacey on 7/3/25.
//

import Foundation
import ComposableArchitecture

@DependencyClient
struct CacheManager {
    var saveEarthquakes: @Sendable ([Earthquake]) async throws -> Void = { _ in }
    var loadEarthquakes: @Sendable () async throws -> [Earthquake] = { [] }
    var clearCache: @Sendable () async throws -> Void = { }
    var getCacheTimestamp: @Sendable () async -> Date? = { nil }
    var isCacheValid: @Sendable (TimeInterval) async -> Bool = { _ in false }
}

extension CacheManager: DependencyKey {
    static let liveValue = CacheManager(
        saveEarthquakes: { earthquakes in
            let encoder = JSONEncoder()
            let data = try encoder.encode(earthquakes)
            let url = getCacheURL()
            try data.write(to: url)
            
            // Save timestamp
            let timestampURL = getTimestampURL()
            let timestamp = Date()
            let timestampData = try encoder.encode(timestamp)
            try timestampData.write(to: timestampURL)
        },
        loadEarthquakes: {
            let url = getCacheURL()
            guard FileManager.default.fileExists(atPath: url.path) else {
                return []
            }
            
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode([Earthquake].self, from: data)
        },
        clearCache: {
            let cacheURL = getCacheURL()
            let timestampURL = getTimestampURL()
            
            try? FileManager.default.removeItem(at: cacheURL)
            try? FileManager.default.removeItem(at: timestampURL)
        },
        getCacheTimestamp: {
            let url = getTimestampURL()
            guard FileManager.default.fileExists(atPath: url.path) else {
                return nil
            }
            
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                return try decoder.decode(Date.self, from: data)
            } catch {
                return nil
            }
        },
        isCacheValid: { maxAge in
            let url = getTimestampURL()
            guard FileManager.default.fileExists(atPath: url.path) else {
                return false
            }
            
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let timestamp = try decoder.decode(Date.self, from: data)
                
                return Date().timeIntervalSince(timestamp) < maxAge
            } catch {
                return false
            }
        }
    )
    
    static let testValue = CacheManager(
        saveEarthquakes: { _ in },
        loadEarthquakes: { [] },
        clearCache: { },
        getCacheTimestamp: { nil },
        isCacheValid: { _ in false }
    )
    
    static let previewValue = CacheManager(
        saveEarthquakes: { _ in },
        loadEarthquakes: { [] },
        clearCache: { },
        getCacheTimestamp: { Date() },
        isCacheValid: { _ in true }
    )
}

private func getCacheURL() -> URL {
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    return documentsPath.appendingPathComponent("earthquakes_cache.json")
}

private func getTimestampURL() -> URL {
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    return documentsPath.appendingPathComponent("earthquakes_timestamp.json")
}

extension DependencyValues {
    var cacheManager: CacheManager {
        get { self[CacheManager.self] }
        set { self[CacheManager.self] = newValue }
    }
}