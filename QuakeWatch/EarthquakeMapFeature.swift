//
//  EarthquakeMapFeature.swift
//  QuakeWatch
//
//  Created by Jeff Lacey on 7/3/25.
//

import Foundation
import ComposableArchitecture
import MapKit

@Reducer
struct EarthquakeMapFeature {
    @ObservableState
    struct State: Equatable {
        var earthquakes: [Earthquake] = []
        var isLoading = false
        var errorMessage: String?
        var lastUpdated: Date?
        var isOnline = true
        var isUsingCachedData = false
        var selectedEarthquake: Earthquake?
        @Presents var earthquakeDetail: EarthquakeDetailFeature.State?
        var mapRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 40.0, longitudeDelta: 40.0)
        )
        
        static func == (lhs: State, rhs: State) -> Bool {
            lhs.earthquakes == rhs.earthquakes &&
            lhs.isLoading == rhs.isLoading &&
            lhs.errorMessage == rhs.errorMessage &&
            lhs.lastUpdated == rhs.lastUpdated &&
            lhs.isOnline == rhs.isOnline &&
            lhs.isUsingCachedData == rhs.isUsingCachedData &&
            lhs.selectedEarthquake == rhs.selectedEarthquake &&
            lhs.$earthquakeDetail == rhs.$earthquakeDetail &&
            lhs.mapRegion.center.latitude == rhs.mapRegion.center.latitude &&
            lhs.mapRegion.center.longitude == rhs.mapRegion.center.longitude &&
            lhs.mapRegion.span.latitudeDelta == rhs.mapRegion.span.latitudeDelta &&
            lhs.mapRegion.span.longitudeDelta == rhs.mapRegion.span.longitudeDelta
        }
    }
    
    enum Action {
        case onAppear
        case refresh
        case earthquakesResponse(Result<[Earthquake], Error>)
        case earthquakeSelected(Earthquake)
        case earthquakeDetail(PresentationAction<EarthquakeDetailFeature.Action>)
        case checkOnlineStatus
        case onlineStatusResponse(Bool)
    }
    
    @Dependency(\.earthquakeClient) var earthquakeClient
    @Dependency(\.cacheManager) var cacheManager
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard state.earthquakes.isEmpty else { return .none }
                return .send(.refresh)
                
            case .refresh:
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    // Check online status first
                    await send(.checkOnlineStatus)
                    
                    // Fetch earthquakes (will use cache if offline)
                    await send(.earthquakesResponse(
                        Result { try await earthquakeClient.fetchEarthquakes() }
                    ))
                }
                
            case let .earthquakesResponse(.success(earthquakes)):
                state.isLoading = false
                state.earthquakes = earthquakes.sorted { $0.time > $1.time }
                state.lastUpdated = Date()
                state.errorMessage = nil
                
                // Detect if we're using cached data (when offline and we have cached data)
                state.isUsingCachedData = !state.isOnline && !earthquakes.isEmpty
                
                // Update map region to show all earthquakes
                if !earthquakes.isEmpty {
                    let coordinates = earthquakes.map { 
                        CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) 
                    }
                    state.mapRegion = calculateMapRegion(for: coordinates)
                }
                
                return .none
                
            case let .earthquakesResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = "Failed to load earthquakes: \(error.localizedDescription)"
                return .none
                
            case let .earthquakeSelected(earthquake):
                state.selectedEarthquake = earthquake
                state.earthquakeDetail = EarthquakeDetailFeature.State(earthquake: earthquake)
                return .none
                
            case .earthquakeDetail:
                return .none
                
            case .checkOnlineStatus:
                return .run { send in
                    let isOnline = await earthquakeClient.isOnline()
                    await send(.onlineStatusResponse(isOnline))
                }
                
            case let .onlineStatusResponse(isOnline):
                state.isOnline = isOnline
                return .none
            }
        }
        .ifLet(\.$earthquakeDetail, action: \.earthquakeDetail) {
            EarthquakeDetailFeature()
        }
    }
}

// MARK: - Private Helpers

private func calculateMapRegion(for coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
    guard !coordinates.isEmpty else {
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 40.0, longitudeDelta: 40.0)
        )
    }
    
    // Filter out invalid coordinates
    let validCoordinates = coordinates.filter { coordinate in
        coordinate.latitude >= -90 && coordinate.latitude <= 90 &&
        coordinate.longitude >= -180 && coordinate.longitude <= 180
    }
    
    guard !validCoordinates.isEmpty else {
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 40.0, longitudeDelta: 40.0)
        )
    }
    
    let minLatitude = validCoordinates.map { $0.latitude }.min() ?? 0
    let maxLatitude = validCoordinates.map { $0.latitude }.max() ?? 0
    let minLongitude = validCoordinates.map { $0.longitude }.min() ?? 0
    let maxLongitude = validCoordinates.map { $0.longitude }.max() ?? 0
    
    let center = CLLocationCoordinate2D(
        latitude: (minLatitude + maxLatitude) / 2,
        longitude: (minLongitude + maxLongitude) / 2
    )
    
    // Calculate spans with reasonable bounds
    let latitudeDelta = max(maxLatitude - minLatitude, 0.1) * 1.3
    let longitudeDelta = max(maxLongitude - minLongitude, 0.1) * 1.3
    
    // Clamp deltas to reasonable values
    let clampedLatitudeDelta = min(max(latitudeDelta, 0.1), 180.0)
    let clampedLongitudeDelta = min(max(longitudeDelta, 0.1), 360.0)
    
    let span = MKCoordinateSpan(
        latitudeDelta: clampedLatitudeDelta,
        longitudeDelta: clampedLongitudeDelta
    )
    
    return MKCoordinateRegion(center: center, span: span)
}