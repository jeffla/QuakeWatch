//
//  QuakeWatchTests.swift
//  QuakeWatchTests
//
//  Created by Jeff Lacey on 7/3/25.
//

import Testing
import ComposableArchitecture
import Foundation
import MapKit
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
    
    @Test func earthquakeDetailFeatureInitialization() async throws {
        let earthquake = Earthquake(from: createTestFeature(magnitude: 4.5))
        let state = EarthquakeDetailFeature.State(earthquake: earthquake)
        
        #expect(state.earthquake.id == earthquake.id)
        #expect(state.earthquake.magnitude == 4.5)
        #expect(state.isOpeningURL == false)
    }
    
    @Test func earthquakeDetailFeatureOpenUSGSLink() async throws {
        let earthquake = Earthquake(from: createTestFeature(magnitude: 4.5))
        let store = TestStore(initialState: EarthquakeDetailFeature.State(earthquake: earthquake)) {
            EarthquakeDetailFeature()
        } withDependencies: {
            $0.openURL = OpenURLEffect { _ in return true }
        }
        
        await store.send(.openUSGSLink) {
            $0.isOpeningURL = true
        }
        
        await store.receive(\.urlOpeningComplete) {
            $0.isOpeningURL = false
        }
    }
    
    @Test func earthquakeListFeatureNavigation() async throws {
        let earthquake = Earthquake(from: createTestFeature(magnitude: 4.5))
        let store = TestStore(initialState: EarthquakeListFeature.State()) {
            EarthquakeListFeature()
        } withDependencies: {
            $0.earthquakeClient = .testValue
        }
        
        await store.send(.earthquakeSelected(earthquake)) {
            $0.selectedEarthquake = EarthquakeDetailFeature.State(earthquake: earthquake)
        }
    }
    
    @Test func earthquakeListFeatureToggleFilter() async throws {
        let store = TestStore(initialState: EarthquakeListFeature.State()) {
            EarthquakeListFeature()
        }
        
        #expect(store.state.filterState.isActive == false)
        
        await store.send(.toggleFilter) {
            $0.filterState.isActive = true
        }
        
        await store.send(.toggleFilter) {
            $0.filterState.isActive = false
        }
    }
    
    @Test func earthquakeListFeatureSetMagnitudeRange() async throws {
        let store = TestStore(initialState: EarthquakeListFeature.State()) {
            EarthquakeListFeature()
        }
        
        let newRange = 2.0...6.0
        await store.send(.setMagnitudeRange(newRange)) {
            $0.filterState.magnitudeRange = newRange
        }
    }
    
    @Test func earthquakeListFeatureSetTimeFilter() async throws {
        let store = TestStore(initialState: EarthquakeListFeature.State()) {
            EarthquakeListFeature()
        }
        
        await store.send(.setTimeFilter(.pastDay)) {
            $0.filterState.timeFilter = .pastDay
        }
    }
    
    @Test func earthquakeListFeatureSetLocationSearch() async throws {
        let store = TestStore(initialState: EarthquakeListFeature.State()) {
            EarthquakeListFeature()
        }
        
        await store.send(.setLocationSearch("California")) {
            $0.filterState.locationSearch = "California"
        }
    }
    
    @Test func earthquakeListFeatureClearFilters() async throws {
        var initialState = EarthquakeListFeature.State()
        initialState.filterState.isActive = true
        initialState.filterState.magnitudeRange = 2.0...6.0
        initialState.filterState.timeFilter = .pastDay
        initialState.filterState.locationSearch = "California"
        
        let store = TestStore(initialState: initialState) {
            EarthquakeListFeature()
        }
        
        await store.send(.clearFilters) {
            $0.filterState = EarthquakeListFeature.State.FilterState()
        }
    }
    
    @Test func earthquakeFilteringLogic() async throws {
        var state = EarthquakeListFeature.State()
        
        // Add test earthquakes with different magnitudes and times
        let now = Date()
        let oneHourAgo = now.addingTimeInterval(-3600)
        let oneDayAgo = now.addingTimeInterval(-86400)
        
        state.earthquakes = [
            Earthquake(from: createTestFeatureWithDetails(magnitude: 2.0, location: "California", time: oneHourAgo)),
            Earthquake(from: createTestFeatureWithDetails(magnitude: 5.0, location: "Alaska", time: oneDayAgo)),
            Earthquake(from: createTestFeatureWithDetails(magnitude: 7.0, location: "Japan", time: now))
        ]
        
        // Test no filtering (isActive = false)
        #expect(state.filteredEarthquakes.count == 3)
        
        // Test magnitude filtering
        state.filterState.isActive = true
        state.filterState.magnitudeRange = 4.0...8.0
        let magnitudeFiltered = state.filteredEarthquakes
        #expect(magnitudeFiltered.count == 2) // 5.0 and 7.0 magnitude
        
        // Test time filtering
        state.filterState.magnitudeRange = 0.0...10.0 // Reset magnitude filter
        state.filterState.timeFilter = .pastHour
        let timeFiltered = state.filteredEarthquakes
        #expect(timeFiltered.count == 2) // earthquakes from now and one hour ago
        
        // Test location filtering
        state.filterState.timeFilter = .all // Reset time filter
        state.filterState.locationSearch = "California"
        let locationFiltered = state.filteredEarthquakes
        #expect(locationFiltered.count == 1) // Only California earthquake
    }
    
    @Test func hasActiveFiltersLogic() async throws {
        var state = EarthquakeListFeature.State()
        
        // No active filters
        #expect(state.hasActiveFilters == false)
        
        // Active but no changes
        state.filterState.isActive = true
        #expect(state.hasActiveFilters == false)
        
        // Active with magnitude change
        state.filterState.magnitudeRange = 2.0...6.0
        #expect(state.hasActiveFilters == true)
        
        // Reset and test time filter
        state.filterState.magnitudeRange = 0.0...10.0
        state.filterState.timeFilter = .pastDay
        #expect(state.hasActiveFilters == true)
        
        // Reset and test location search
        state.filterState.timeFilter = .all
        state.filterState.locationSearch = "California"
        #expect(state.hasActiveFilters == true)
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
    
    private func createTestFeatureWithDetails(magnitude: Double, location: String, time: Date) -> EarthquakeFeature {
        EarthquakeFeature(
            type: "Feature",
            properties: EarthquakeProperties(
                mag: magnitude,
                place: location,
                time: Int(time.timeIntervalSince1970 * 1000),
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
            id: "test-earthquake-\(magnitude)-\(location.replacingOccurrences(of: " ", with: "-"))"
        )
    }
    
    // MARK: - Map Feature Tests
    
    @Test func earthquakeMapFeatureOnAppear() async throws {
        let store = TestStore(initialState: EarthquakeMapFeature.State()) {
            EarthquakeMapFeature()
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
            // Map region should be updated to show the earthquake
            $0.mapRegion.center.latitude = 34.123
            $0.mapRegion.center.longitude = -118.123
        }
    }
    
    @Test func earthquakeMapFeatureRefresh() async throws {
        let store = TestStore(initialState: EarthquakeMapFeature.State()) {
            EarthquakeMapFeature()
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
            $0.mapRegion.center.latitude = 34.123
            $0.mapRegion.center.longitude = -118.123
        }
    }
    
    @Test func earthquakeMapFeatureError() async throws {
        struct TestError: Error, Equatable {
            let message = "Test error"
        }
        
        let store = TestStore(initialState: EarthquakeMapFeature.State()) {
            EarthquakeMapFeature()
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
    
    @Test func earthquakeMapFeatureEarthquakeSelection() async throws {
        let earthquake = Earthquake(from: createTestFeature(magnitude: 4.5))
        let store = TestStore(initialState: EarthquakeMapFeature.State()) {
            EarthquakeMapFeature()
        } withDependencies: {
            $0.earthquakeClient = .testValue
        }
        
        await store.send(.earthquakeSelected(earthquake)) {
            $0.selectedEarthquake = earthquake
            $0.earthquakeDetail = EarthquakeDetailFeature.State(earthquake: earthquake)
        }
    }
    
    
    // MARK: - Root Feature Tests
    
    @Test func rootFeatureTabSelection() async throws {
        let store = TestStore(initialState: RootFeature.State()) {
            RootFeature()
        }
        
        #expect(store.state.selectedTab == .list)
        
        await store.send(.tabSelected(.map)) {
            $0.selectedTab = .map
        }
        
        await store.send(.tabSelected(.list)) {
            $0.selectedTab = .list
        }
    }
    
    @Test func rootFeatureInitialState() async throws {
        let state = RootFeature.State()
        
        #expect(state.selectedTab == .list)
        #expect(state.earthquakeList.earthquakes.isEmpty)
        #expect(state.earthquakeMap.earthquakes.isEmpty)
        #expect(state.earthquakeList.isLoading == false)
        #expect(state.earthquakeMap.isLoading == false)
    }
    
    // MARK: - Settings Feature Tests
    
    @Test func settingsFeatureInitialState() async throws {
        let state = SettingsFeature.State()
        
        #expect(state.refreshInterval == .fiveMinutes)
        #expect(state.notificationThreshold == 5.0)
        #expect(state.showMagnitudeLabels == true)
        #expect(state.useMetricUnits == false)
        #expect(state.showMinorEarthquakes == true)
        #expect(state.autoRefresh == true)
    }
    
    @Test func settingsFeatureSetRefreshInterval() async throws {
        let store = TestStore(initialState: SettingsFeature.State()) {
            SettingsFeature()
        }
        
        await store.send(.setRefreshInterval(.tenMinutes)) {
            $0.refreshInterval = .tenMinutes
        }
        
        await store.send(.setRefreshInterval(.oneHour)) {
            $0.refreshInterval = .oneHour
        }
    }
    
    @Test func settingsFeatureSetNotificationThreshold() async throws {
        let store = TestStore(initialState: SettingsFeature.State()) {
            SettingsFeature()
        }
        
        await store.send(.setNotificationThreshold(6.5)) {
            $0.notificationThreshold = 6.5
        }
        
        await store.send(.setNotificationThreshold(2.0)) {
            $0.notificationThreshold = 2.0
        }
    }
    
    @Test func settingsFeatureToggleActions() async throws {
        let store = TestStore(initialState: SettingsFeature.State()) {
            SettingsFeature()
        }
        
        await store.send(.toggleMagnitudeLabels) {
            $0.showMagnitudeLabels = false
        }
        
        await store.send(.toggleMagnitudeLabels) {
            $0.showMagnitudeLabels = true
        }
        
        await store.send(.toggleMetricUnits) {
            $0.useMetricUnits = true
        }
        
        await store.send(.toggleMinorEarthquakes) {
            $0.showMinorEarthquakes = false
        }
        
        await store.send(.toggleAutoRefresh) {
            $0.autoRefresh = false
        }
    }
    
    @Test func settingsFeatureResetToDefaults() async throws {
        var initialState = SettingsFeature.State()
        initialState.refreshInterval = .oneHour
        initialState.notificationThreshold = 7.0
        initialState.showMagnitudeLabels = false
        initialState.useMetricUnits = true
        initialState.showMinorEarthquakes = false
        initialState.autoRefresh = false
        
        let store = TestStore(initialState: initialState) {
            SettingsFeature()
        }
        
        await store.send(.resetToDefaults) {
            $0 = SettingsFeature.State()
        }
    }
    
    @Test func settingsRefreshIntervalTimeValues() async throws {
        #expect(SettingsFeature.State.RefreshInterval.oneMinute.timeInterval == 60)
        #expect(SettingsFeature.State.RefreshInterval.fiveMinutes.timeInterval == 300)
        #expect(SettingsFeature.State.RefreshInterval.tenMinutes.timeInterval == 600)
        #expect(SettingsFeature.State.RefreshInterval.thirtyMinutes.timeInterval == 1800)
        #expect(SettingsFeature.State.RefreshInterval.oneHour.timeInterval == 3600)
    }
    
    @Test func rootFeatureSettingsTabSelection() async throws {
        let store = TestStore(initialState: RootFeature.State()) {
            RootFeature()
        }
        
        #expect(store.state.selectedTab == .list)
        
        await store.send(.tabSelected(.settings)) {
            $0.selectedTab = .settings
        }
        
        await store.send(.tabSelected(.map)) {
            $0.selectedTab = .map
        }
        
        await store.send(.tabSelected(.list)) {
            $0.selectedTab = .list
        }
    }
    
    // MARK: - Cache and Offline Tests
    
    @Test func earthquakeListFeatureOnlineStatusCheck() async throws {
        let store = TestStore(initialState: EarthquakeListFeature.State()) {
            EarthquakeListFeature()
        } withDependencies: {
            $0.earthquakeClient.isOnline = { true }
        }
        
        await store.send(.checkOnlineStatus)
        
        await store.receive(\.onlineStatusResponse) {
            $0.isOnline = true
        }
    }
    
    @Test func earthquakeListFeatureOfflineStatusCheck() async throws {
        let store = TestStore(initialState: EarthquakeListFeature.State()) {
            EarthquakeListFeature()
        } withDependencies: {
            $0.earthquakeClient.isOnline = { false }
        }
        
        await store.send(.checkOnlineStatus)
        
        await store.receive(\.onlineStatusResponse) {
            $0.isOnline = false
        }
    }
    
    @Test func earthquakeListFeatureOfflineWithCache() async throws {
        let cachedEarthquake = Earthquake(from: createTestFeature(magnitude: 3.2))
        
        let store = TestStore(initialState: EarthquakeListFeature.State()) {
            EarthquakeListFeature()
        } withDependencies: {
            $0.earthquakeClient.fetchEarthquakes = { [cachedEarthquake] }
            $0.earthquakeClient.isOnline = { false }
            $0.cacheManager = .testValue
        }
        
        await store.send(.refresh) {
            $0.isLoading = true
            $0.errorMessage = nil
        }
        
        await store.receive(\.checkOnlineStatus)
        
        await store.receive(\.onlineStatusResponse) {
            $0.isOnline = false
        }
        
        await store.receive(\.earthquakesResponse.success) {
            $0.isLoading = false
            $0.earthquakes = [cachedEarthquake]
            $0.lastUpdated = Date()
            $0.isUsingCachedData = true
        }
    }
    
    @Test func earthquakeMapFeatureOnlineStatusCheck() async throws {
        let store = TestStore(initialState: EarthquakeMapFeature.State()) {
            EarthquakeMapFeature()
        } withDependencies: {
            $0.earthquakeClient.isOnline = { true }
        }
        
        await store.send(.checkOnlineStatus)
        
        await store.receive(\.onlineStatusResponse) {
            $0.isOnline = true
        }
    }
    
    @Test func earthquakeMapFeatureOfflineWithCache() async throws {
        let cachedEarthquake = Earthquake(from: createTestFeature(magnitude: 4.1))
        
        let store = TestStore(initialState: EarthquakeMapFeature.State()) {
            EarthquakeMapFeature()
        } withDependencies: {
            $0.earthquakeClient.fetchEarthquakes = { [cachedEarthquake] }
            $0.earthquakeClient.isOnline = { false }
            $0.cacheManager = .testValue
        }
        
        await store.send(.refresh) {
            $0.isLoading = true
            $0.errorMessage = nil
        }
        
        await store.receive(\.checkOnlineStatus)
        
        await store.receive(\.onlineStatusResponse) {
            $0.isOnline = false
        }
        
        await store.receive(\.earthquakesResponse.success) {
            $0.isLoading = false
            $0.earthquakes = [cachedEarthquake]
            $0.lastUpdated = Date()
            $0.isUsingCachedData = true
            $0.mapRegion.center.latitude = cachedEarthquake.latitude
            $0.mapRegion.center.longitude = cachedEarthquake.longitude
        }
    }
    
    @Test func cacheManagerSaveAndLoad() async throws {
        let testEarthquakes = [
            Earthquake(from: createTestFeature(magnitude: 5.2)),
            Earthquake(from: createTestFeature(magnitude: 3.8))
        ]
        
        // Test that cache manager can save and load earthquakes
        let cacheManager = CacheManager.liveValue
        
        try await cacheManager.saveEarthquakes(testEarthquakes)
        let loadedEarthquakes = try await cacheManager.loadEarthquakes()
        
        #expect(loadedEarthquakes.count == testEarthquakes.count)
        #expect(loadedEarthquakes[0].magnitude == testEarthquakes[0].magnitude)
        #expect(loadedEarthquakes[1].magnitude == testEarthquakes[1].magnitude)
        
        // Clean up
        try await cacheManager.clearCache()
    }
    
    @Test func cacheManagerTimestamp() async throws {
        let cacheManager = CacheManager.liveValue
        
        // Initially no timestamp should exist
        let initialTimestamp = await cacheManager.getCacheTimestamp()
        #expect(initialTimestamp == nil)
        
        // Save some data
        let testEarthquakes = [Earthquake(from: createTestFeature(magnitude: 2.5))]
        try await cacheManager.saveEarthquakes(testEarthquakes)
        
        // Now timestamp should exist
        let savedTimestamp = await cacheManager.getCacheTimestamp()
        #expect(savedTimestamp != nil)
        
        // Clean up
        try await cacheManager.clearCache()
        
        // After clearing, timestamp should be gone
        let clearedTimestamp = await cacheManager.getCacheTimestamp()
        #expect(clearedTimestamp == nil)
    }
    
    @Test func cacheManagerValidityCheck() async throws {
        let cacheManager = CacheManager.liveValue
        
        // Initially cache should not be valid
        let initialValid = await cacheManager.isCacheValid(300) // 5 minutes
        #expect(initialValid == false)
        
        // Save some data
        let testEarthquakes = [Earthquake(from: createTestFeature(magnitude: 6.1))]
        try await cacheManager.saveEarthquakes(testEarthquakes)
        
        // Immediately after saving, should be valid
        let validAfterSave = await cacheManager.isCacheValid(300)
        #expect(validAfterSave == true)
        
        // Should not be valid for very short duration (simulating expired cache)
        let expiredCache = await cacheManager.isCacheValid(0.001) // 1 millisecond
        #expect(expiredCache == false)
        
        // Clean up
        try await cacheManager.clearCache()
    }
}
