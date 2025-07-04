//
//  EarthquakeListFeature.swift
//  QuakeWatch
//
//  Created by Jeff Lacey on 7/3/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct EarthquakeListFeature {
    @ObservableState
    struct State: Equatable {
        var earthquakes: [Earthquake] = []
        var isLoading = false
        var errorMessage: String?
        var lastUpdated: Date?
        var isOnline = true
        var isUsingCachedData = false
        @Presents var selectedEarthquake: EarthquakeDetailFeature.State?
        var filterState = FilterState()
        
        struct FilterState: Equatable {
            var isActive = false
            var magnitudeRange: ClosedRange<Double> = 0.0...10.0
            var timeFilter: TimeFilter = .all
            var locationSearch: String = ""
            
            enum TimeFilter: String, CaseIterable {
                case all = "All Time"
                case pastHour = "Past Hour"
                case pastDay = "Past Day"
                case pastWeek = "Past Week"
                case pastMonth = "Past Month"
                
                var timeInterval: TimeInterval? {
                    switch self {
                    case .all: return nil
                    case .pastHour: return 3600
                    case .pastDay: return 86400
                    case .pastWeek: return 604800
                    case .pastMonth: return 2592000
                    }
                }
            }
        }
    }
    
    enum Action {
        case onAppear
        case refresh
        case earthquakesResponse(Result<[Earthquake], Error>)
        case earthquakeSelected(Earthquake)
        case earthquakeDetail(PresentationAction<EarthquakeDetailFeature.Action>)
        case toggleFilter
        case setMagnitudeRange(ClosedRange<Double>)
        case setTimeFilter(State.FilterState.TimeFilter)
        case setLocationSearch(String)
        case clearFilters
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
                
                return .none
                
            case let .earthquakesResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = "Failed to load earthquakes: \(error.localizedDescription)"
                return .none
                
            case let .earthquakeSelected(earthquake):
                state.selectedEarthquake = EarthquakeDetailFeature.State(earthquake: earthquake)
                return .none
                
            case .earthquakeDetail:
                return .none
                
            case .toggleFilter:
                state.filterState.isActive.toggle()
                return .none
                
            case let .setMagnitudeRange(range):
                state.filterState.magnitudeRange = range
                return .none
                
            case let .setTimeFilter(timeFilter):
                state.filterState.timeFilter = timeFilter
                return .none
                
            case let .setLocationSearch(search):
                state.filterState.locationSearch = search
                return .none
                
            case .clearFilters:
                state.filterState = State.FilterState()
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
        .ifLet(\.$selectedEarthquake, action: \.earthquakeDetail) {
            EarthquakeDetailFeature()
        }
    }
}

extension EarthquakeListFeature.State {
    var sortedEarthquakes: [Earthquake] {
        let filtered = filteredEarthquakes
        return filtered.sorted { $0.time > $1.time }
    }
    
    var filteredEarthquakes: [Earthquake] {
        guard filterState.isActive else {
            return earthquakes
        }
        
        return earthquakes.filter { earthquake in
            // Magnitude filter
            let magnitudeMatch = filterState.magnitudeRange.contains(earthquake.magnitude)
            
            // Time filter
            let timeMatch: Bool
            if let timeInterval = filterState.timeFilter.timeInterval {
                let cutoffDate = Date().addingTimeInterval(-timeInterval)
                timeMatch = earthquake.time >= cutoffDate
            } else {
                timeMatch = true
            }
            
            // Location filter
            let locationMatch = filterState.locationSearch.isEmpty ||
                earthquake.location.localizedCaseInsensitiveContains(filterState.locationSearch)
            
            return magnitudeMatch && timeMatch && locationMatch
        }
    }
    
    var hasActiveFilters: Bool {
        filterState.isActive && (
            filterState.magnitudeRange != 0.0...10.0 ||
            filterState.timeFilter != .all ||
            !filterState.locationSearch.isEmpty
        )
    }
    
    var lastUpdatedText: String {
        guard let lastUpdated = lastUpdated else { return "Never" }
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: lastUpdated, relativeTo: Date())
    }
}