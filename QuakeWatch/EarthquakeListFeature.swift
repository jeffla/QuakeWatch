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
    }
    
    enum Action {
        case onAppear
        case refresh
        case earthquakesResponse(Result<[Earthquake], Error>)
    }
    
    @Dependency(\.earthquakeClient) var earthquakeClient
    
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
                    await send(.earthquakesResponse(
                        Result { try await earthquakeClient.fetchEarthquakes() }
                    ))
                }
                
            case let .earthquakesResponse(.success(earthquakes)):
                state.isLoading = false
                state.earthquakes = earthquakes.sorted { $0.time > $1.time }
                state.lastUpdated = Date()
                state.errorMessage = nil
                return .none
                
            case let .earthquakesResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = "Failed to load earthquakes: \(error.localizedDescription)"
                return .none
            }
        }
    }
}

extension EarthquakeListFeature.State {
    var sortedEarthquakes: [Earthquake] {
        earthquakes.sorted { $0.time > $1.time }
    }
    
    var lastUpdatedText: String {
        guard let lastUpdated = lastUpdated else { return "Never" }
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: lastUpdated, relativeTo: Date())
    }
}