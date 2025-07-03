//
//  SettingsFeature.swift
//  QuakeWatch
//
//  Created by Jeff Lacey on 7/3/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SettingsFeature {
    @ObservableState
    struct State: Equatable {
        var refreshInterval: RefreshInterval = .fiveMinutes
        var notificationThreshold: Double = 5.0
        var showMagnitudeLabels: Bool = true
        var useMetricUnits: Bool = false
        var showMinorEarthquakes: Bool = true
        var autoRefresh: Bool = true
        
        enum RefreshInterval: String, CaseIterable, Identifiable {
            case oneMinute = "1 minute"
            case fiveMinutes = "5 minutes"
            case tenMinutes = "10 minutes"
            case thirtyMinutes = "30 minutes"
            case oneHour = "1 hour"
            
            var id: String { rawValue }
            
            var timeInterval: TimeInterval {
                switch self {
                case .oneMinute:
                    return 60
                case .fiveMinutes:
                    return 300
                case .tenMinutes:
                    return 600
                case .thirtyMinutes:
                    return 1800
                case .oneHour:
                    return 3600
                }
            }
        }
    }
    
    enum Action {
        case setRefreshInterval(State.RefreshInterval)
        case setNotificationThreshold(Double)
        case toggleMagnitudeLabels
        case toggleMetricUnits
        case toggleMinorEarthquakes
        case toggleAutoRefresh
        case resetToDefaults
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .setRefreshInterval(interval):
                state.refreshInterval = interval
                return .none
                
            case let .setNotificationThreshold(threshold):
                state.notificationThreshold = threshold
                return .none
                
            case .toggleMagnitudeLabels:
                state.showMagnitudeLabels.toggle()
                return .none
                
            case .toggleMetricUnits:
                state.useMetricUnits.toggle()
                return .none
                
            case .toggleMinorEarthquakes:
                state.showMinorEarthquakes.toggle()
                return .none
                
            case .toggleAutoRefresh:
                state.autoRefresh.toggle()
                return .none
                
            case .resetToDefaults:
                state = State()
                return .none
            }
        }
    }
}