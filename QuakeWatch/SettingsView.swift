//
//  SettingsView.swift
//  QuakeWatch
//
//  Created by Jeff Lacey on 7/3/25.
//

import SwiftUI
import ComposableArchitecture

struct SettingsView: View {
    let store: StoreOf<SettingsFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section(header: Text("Data Refresh")) {
                    HStack {
                        Text("Auto Refresh")
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { viewStore.autoRefresh },
                            set: { _ in viewStore.send(.toggleAutoRefresh) }
                        ))
                    }
                    
                    if viewStore.autoRefresh {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Refresh Interval")
                                .foregroundColor(.secondary)
                            
                            Picker("Refresh Interval", selection: Binding(
                                get: { viewStore.refreshInterval },
                                set: { viewStore.send(.setRefreshInterval($0)) }
                            )) {
                                ForEach(SettingsFeature.State.RefreshInterval.allCases) { interval in
                                    Text(interval.rawValue).tag(interval)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
                }
                
                Section(header: Text("Notifications")) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Magnitude Threshold")
                            Spacer()
                            Text(String(format: "%.1f", viewStore.notificationThreshold))
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(
                            value: Binding(
                                get: { viewStore.notificationThreshold },
                                set: { viewStore.send(.setNotificationThreshold($0)) }
                            ),
                            in: 1.0...9.0,
                            step: 0.1
                        )
                        
                        Text("Notify when earthquakes of this magnitude or higher occur")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Display Options")) {
                    HStack {
                        Text("Show Magnitude Labels")
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { viewStore.showMagnitudeLabels },
                            set: { _ in viewStore.send(.toggleMagnitudeLabels) }
                        ))
                    }
                    
                    HStack {
                        Text("Use Metric Units")
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { viewStore.useMetricUnits },
                            set: { _ in viewStore.send(.toggleMetricUnits) }
                        ))
                    }
                    
                    HStack {
                        Text("Show Minor Earthquakes")
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { viewStore.showMinorEarthquakes },
                            set: { _ in viewStore.send(.toggleMinorEarthquakes) }
                        ))
                    }
                }
                
                Section(header: Text("Information")) {
                    HStack {
                        Text("Data Source")
                        Spacer()
                        Text("USGS Earthquake Hazards Program")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button("Reset to Defaults") {
                        viewStore.send(.resetToDefaults)
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    NavigationView {
        SettingsView(
            store: Store(initialState: SettingsFeature.State()) {
                SettingsFeature()
            }
        )
    }
}