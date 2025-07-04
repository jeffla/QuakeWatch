//
//  EarthquakeClient.swift
//  QuakeWatch
//
//  Created by Jeff Lacey on 7/3/25.
//

import Foundation
import ComposableArchitecture

@DependencyClient
struct EarthquakeClient {
    var fetchEarthquakes: @Sendable () async throws -> [Earthquake]
    var isOnline: @Sendable () async -> Bool = { false }
}

extension EarthquakeClient: DependencyKey {
    static let liveValue = EarthquakeClient(
        fetchEarthquakes: {
            @Dependency(\.cacheManager) var cacheManager
            
            let cacheValidDuration: TimeInterval = 300 // 5 minutes
            
            // Check if we have valid cached data
            if await cacheManager.isCacheValid(cacheValidDuration) {
                let cachedEarthquakes = try await cacheManager.loadEarthquakes()
                if !cachedEarthquakes.isEmpty {
                    return cachedEarthquakes
                }
            }
            
            do {
                // Try to fetch fresh data from the API
                let url = URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson")!
                let (data, _) = try await URLSession.shared.data(from: url)
                let response = try JSONDecoder().decode(EarthquakeResponse.self, from: data)
                let earthquakes = response.features.map(Earthquake.init)
                
                // Cache the fresh data
                try await cacheManager.saveEarthquakes(earthquakes)
                
                return earthquakes
            } catch {
                // If network fails, try to load from cache regardless of age
                let cachedEarthquakes = try await cacheManager.loadEarthquakes()
                if !cachedEarthquakes.isEmpty {
                    return cachedEarthquakes
                }
                
                // If no cached data exists, rethrow the original error
                throw error
            }
        },
        isOnline: {
            guard let url = URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson") else {
                return false
            }
            
            do {
                let (_, response) = try await URLSession.shared.data(from: url)
                return (response as? HTTPURLResponse)?.statusCode == 200
            } catch {
                return false
            }
        }
    )
    
    static let testValue = EarthquakeClient(
        fetchEarthquakes: {
            [
                Earthquake(from: EarthquakeFeature(
                    type: "Feature",
                    properties: EarthquakeProperties(
                        mag: 4.5,
                        place: "Test Location",
                        time: Int(Date().timeIntervalSince1970 * 1000),
                        updated: Int(Date().timeIntervalSince1970 * 1000),
                        tz: nil,
                        url: "https://test.com",
                        detail: "https://test.com/detail",
                        felt: nil,
                        cdi: nil,
                        mmi: nil,
                        alert: nil,
                        status: "reviewed",
                        tsunami: 0,
                        sig: 314,
                        net: "ci",
                        code: "12345",
                        ids: ",ci12345,",
                        sources: ",ci,",
                        types: ",general-link,origin,phase-data,",
                        nst: nil,
                        dmin: nil,
                        rms: nil,
                        gap: nil,
                        magType: "ml",
                        type: "earthquake",
                        title: "Test Earthquake"
                    ),
                    geometry: EarthquakeGeometry(
                        type: "Point",
                        coordinates: [-118.123, 34.123, 10.0]
                    ),
                    id: "test-earthquake-1"
                ))
            ]
        },
        isOnline: { true }
    )
    
    static let previewValue = EarthquakeClient(
        fetchEarthquakes: {
            [
                Earthquake(from: EarthquakeFeature(
                    type: "Feature",
                    properties: EarthquakeProperties(
                        mag: 4.5,
                        place: "10 km N of Ridgecrest, CA",
                        time: Int(Date().addingTimeInterval(-7200).timeIntervalSince1970 * 1000),
                        updated: Int(Date().timeIntervalSince1970 * 1000),
                        tz: nil,
                        url: "https://earthquake.usgs.gov/earthquakes/eventpage/preview1",
                        detail: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/detail/preview1.geojson",
                        felt: nil,
                        cdi: nil,
                        mmi: nil,
                        alert: nil,
                        status: "reviewed",
                        tsunami: 0,
                        sig: 314,
                        net: "ci",
                        code: "12345",
                        ids: ",ci12345,",
                        sources: ",ci,",
                        types: ",general-link,origin,phase-data,",
                        nst: nil,
                        dmin: nil,
                        rms: nil,
                        gap: nil,
                        magType: "ml",
                        type: "earthquake",
                        title: "M 4.5 - 10 km N of Ridgecrest, CA"
                    ),
                    geometry: EarthquakeGeometry(
                        type: "Point",
                        coordinates: [-117.6748, 35.8721, 8.21]
                    ),
                    id: "ci12345"
                )),
                Earthquake(from: EarthquakeFeature(
                    type: "Feature",
                    properties: EarthquakeProperties(
                        mag: 2.8,
                        place: "15 km SW of Mammoth Lakes, CA",
                        time: Int(Date().addingTimeInterval(-14400).timeIntervalSince1970 * 1000),
                        updated: Int(Date().timeIntervalSince1970 * 1000),
                        tz: nil,
                        url: "https://earthquake.usgs.gov/earthquakes/eventpage/preview2",
                        detail: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/detail/preview2.geojson",
                        felt: nil,
                        cdi: nil,
                        mmi: nil,
                        alert: nil,
                        status: "reviewed",
                        tsunami: 0,
                        sig: 119,
                        net: "nc",
                        code: "67890",
                        ids: ",nc67890,",
                        sources: ",nc,",
                        types: ",general-link,origin,phase-data,",
                        nst: nil,
                        dmin: nil,
                        rms: nil,
                        gap: nil,
                        magType: "md",
                        type: "earthquake",
                        title: "M 2.8 - 15 km SW of Mammoth Lakes, CA"
                    ),
                    geometry: EarthquakeGeometry(
                        type: "Point",
                        coordinates: [-118.9721, 37.6248, 12.45]
                    ),
                    id: "nc67890"
                )),
                Earthquake(from: EarthquakeFeature(
                    type: "Feature",
                    properties: EarthquakeProperties(
                        mag: 5.1,
                        place: "25 km NE of Eureka, CA",
                        time: Int(Date().addingTimeInterval(-28800).timeIntervalSince1970 * 1000),
                        updated: Int(Date().timeIntervalSince1970 * 1000),
                        tz: nil,
                        url: "https://earthquake.usgs.gov/earthquakes/eventpage/preview3",
                        detail: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/detail/preview3.geojson",
                        felt: nil,
                        cdi: nil,
                        mmi: nil,
                        alert: nil,
                        status: "reviewed",
                        tsunami: 0,
                        sig: 400,
                        net: "nc",
                        code: "11223",
                        ids: ",nc11223,",
                        sources: ",nc,",
                        types: ",general-link,origin,phase-data,",
                        nst: nil,
                        dmin: nil,
                        rms: nil,
                        gap: nil,
                        magType: "mw",
                        type: "earthquake",
                        title: "M 5.1 - 25 km NE of Eureka, CA"
                    ),
                    geometry: EarthquakeGeometry(
                        type: "Point",
                        coordinates: [-123.9721, 40.9248, 15.2]
                    ),
                    id: "nc11223"
                ))
            ]
        },
        isOnline: { true }
    )
}

extension DependencyValues {
    var earthquakeClient: EarthquakeClient {
        get { self[EarthquakeClient.self] }
        set { self[EarthquakeClient.self] = newValue }
    }
}