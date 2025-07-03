//
//  EarthquakeDetailFeature.swift
//  QuakeWatch
//
//  Created by Jeff Lacey on 7/3/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct EarthquakeDetailFeature {
    @ObservableState
    struct State: Equatable {
        let earthquake: Earthquake
        var isOpeningURL = false
        
        init(earthquake: Earthquake) {
            self.earthquake = earthquake
        }
    }
    
    enum Action {
        case openUSGSLink
        case urlOpeningComplete
        case dismiss
    }
    
    @Dependency(\.openURL) var openURL
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .openUSGSLink:
                state.isOpeningURL = true
                return .run { [url = state.earthquake.url] send in
                    await openURL(URL(string: url)!)
                    await send(.urlOpeningComplete)
                }
                
            case .urlOpeningComplete:
                state.isOpeningURL = false
                return .none
                
            case .dismiss:
                return .none
            }
        }
    }
}