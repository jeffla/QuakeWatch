//
//  QuakeWatchTests.swift
//  QuakeWatchTests
//
//  Created by Jeff Lacey on 7/3/25.
//

import Testing
import ComposableArchitecture
@testable import QuakeWatch

@MainActor
struct QuakeWatchTests {
    
    @Test func earthquakeListFeatureOnAppear() async throws {
        let store = TestStore(initialState: EarthquakeListFeature.State()) {
            EarthquakeListFeature()
        } withDependencies: {
            $0.earthquakeClient = .testValue
        }
        
        await store.send(.onAppear) {
            $0.isLoading = true
        }
        
        await store.receive(\.earthquakesResponse.success) {
            $0.isLoading = false
            $0.earthquakes = [
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
            $0.lastUpdated = Date()
        }
    }
    
    @Test func earthquakeListFeatureRefresh() async throws {
        let store = TestStore(initialState: EarthquakeListFeature.State()) {
            EarthquakeListFeature()
        } withDependencies: {
            $0.earthquakeClient = .testValue
        }
        
        await store.send(.refresh) {
            $0.isLoading = true
        }
        
        await store.receive(\.earthquakesResponse.success) {
            $0.isLoading = false
            $0.earthquakes = [
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
            $0.lastUpdated = Date()
        }
    }
    
    @Test func earthquakeListFeatureError() async throws {
        struct TestError: Error, Equatable {
            let message = "Test error"
        }
        
        let store = TestStore(initialState: EarthquakeListFeature.State()) {
            EarthquakeListFeature()
        } withDependencies: {
            $0.earthquakeClient.fetchEarthquakes = { throw TestError() }
        }
        
        await store.send(.refresh) {
            $0.isLoading = true
        }
        
        await store.receive(\.earthquakesResponse.failure) {
            $0.isLoading = false
            $0.errorMessage = "Failed to load earthquakes: Test error"
        }
    }
    
    @Test func earthquakeModelInitialization() async throws {
        let feature = EarthquakeFeature(
            type: "Feature",
            properties: EarthquakeProperties(
                mag: 4.5,
                place: "10 km N of Ridgecrest, CA",
                time: 1625097600000, // July 1, 2021 at 00:00:00 UTC
                updated: 1625097600000,
                tz: nil,
                url: "https://earthquake.usgs.gov/earthquakes/eventpage/test",
                detail: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/detail/test.geojson",
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
        )
        
        let earthquake = Earthquake(from: feature)
        
        #expect(earthquake.id == "ci12345")
        #expect(earthquake.magnitude == 4.5)
        #expect(earthquake.location == "10 km N of Ridgecrest, CA")
        #expect(earthquake.latitude == 35.8721)
        #expect(earthquake.longitude == -117.6748)
        #expect(earthquake.depth == 8.21)
        #expect(earthquake.url == "https://earthquake.usgs.gov/earthquakes/eventpage/test")
    }
    
    @Test func earthquakeMagnitudeCategories() async throws {
        let minorEarthquake = Earthquake(from: createTestFeature(magnitude: 1.5))
        let lightEarthquake = Earthquake(from: createTestFeature(magnitude: 3.0))
        let moderateEarthquake = Earthquake(from: createTestFeature(magnitude: 5.0))
        let strongEarthquake = Earthquake(from: createTestFeature(magnitude: 6.5))
        let majorEarthquake = Earthquake(from: createTestFeature(magnitude: 7.5))
        let greatEarthquake = Earthquake(from: createTestFeature(magnitude: 8.5))
        
        #expect(minorEarthquake.magnitudeCategory == .minor)
        #expect(lightEarthquake.magnitudeCategory == .light)
        #expect(moderateEarthquake.magnitudeCategory == .moderate)
        #expect(strongEarthquake.magnitudeCategory == .strong)
        #expect(majorEarthquake.magnitudeCategory == .major)
        #expect(greatEarthquake.magnitudeCategory == .great)
    }
    
    private func createTestFeature(magnitude: Double) -> EarthquakeFeature {
        EarthquakeFeature(
            type: "Feature",
            properties: EarthquakeProperties(
                mag: magnitude,
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
            id: "test-earthquake-\(magnitude)"
        )
    }
}
