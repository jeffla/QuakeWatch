//
//  RootFeature.swift
//  QuakeWatch
//
//  Created by Jeff Lacey on 7/3/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct RootFeature {
    @ObservableState
    struct State: Equatable {
        var selectedTab: Tab = .list
        var earthquakeList = EarthquakeListFeature.State()
        var earthquakeMap = EarthquakeMapFeature.State()
        var settings = SettingsFeature.State()
        
        enum Tab: String, CaseIterable {
            case list = "List"
            case map = "Map"
            case settings = "Settings"
        }
    }
    
    enum Action {
        case tabSelected(State.Tab)
        case earthquakeList(EarthquakeListFeature.Action)
        case earthquakeMap(EarthquakeMapFeature.Action)
        case settings(SettingsFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.earthquakeList, action: \.earthquakeList) {
            EarthquakeListFeature()
        }
        
        Scope(state: \.earthquakeMap, action: \.earthquakeMap) {
            EarthquakeMapFeature()
        }
        
        Scope(state: \.settings, action: \.settings) {
            SettingsFeature()
        }
        
        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
                
            case .earthquakeList:
                return .none
                
            case .earthquakeMap:
                return .none
                
            case .settings:
                return .none
            }
        }
    }
}