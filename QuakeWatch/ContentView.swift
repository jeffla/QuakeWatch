//
//  ContentView.swift
//  QuakeWatch
//
//  Created by Jeff Lacey on 7/3/25.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    var body: some View {
        RootView(
            store: Store(initialState: RootFeature.State()) {
                RootFeature()
            }
        )
    }
}

struct RootView: View {
    let store: StoreOf<RootFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            TabView(selection: Binding(
                get: { viewStore.selectedTab },
                set: { viewStore.send(.tabSelected($0)) }
            )) {
                NavigationView {
                    EarthquakeListView(
                        store: store.scope(state: \.earthquakeList, action: \.earthquakeList)
                    )
                }
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("List")
                }
                .tag(RootFeature.State.Tab.list)
                
                NavigationView {
                    EarthquakeMapView(
                        store: store.scope(state: \.earthquakeMap, action: \.earthquakeMap)
                    )
                }
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
                .tag(RootFeature.State.Tab.map)
            }
        }
    }
}

struct EarthquakeListView: View {
    let store: StoreOf<EarthquakeListFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                // Filter Panel
                if viewStore.filterState.isActive {
                    EarthquakeFilterView(store: store)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Main Content
                Group {
                    if viewStore.isLoading && viewStore.earthquakes.isEmpty {
                    VStack {
                        ProgressView()
                        Text("Loading earthquakes...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else if viewStore.earthquakes.isEmpty {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No earthquakes found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        if let errorMessage = viewStore.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                    }
                } else {
                    List(viewStore.sortedEarthquakes) { earthquake in
                        Button(action: { viewStore.send(.earthquakeSelected(earthquake)) }) {
                            EarthquakeRowView(earthquake: earthquake)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .refreshable {
                        viewStore.send(.refresh)
                    }
                }
            }
            }
            .navigationTitle("Recent Earthquakes")
            .onAppear {
                viewStore.send(.onAppear)
            }
            .overlay(alignment: .bottom) {
                if viewStore.isLoading && !viewStore.earthquakes.isEmpty {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Updating...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .shadow(radius: 2)
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { viewStore.send(.toggleFilter) }) {
                        Image(systemName: viewStore.hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .foregroundColor(viewStore.hasActiveFilters ? .blue : .primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        viewStore.send(.refresh)
                    }
                    .disabled(viewStore.isLoading)
                }
            }
            .sheet(
                store: store.scope(state: \.$selectedEarthquake, action: \.earthquakeDetail)
            ) { detailStore in
                NavigationView {
                    EarthquakeDetailView(store: detailStore)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    viewStore.send(.earthquakeDetail(.dismiss))
                                }
                            }
                        }
                }
            }
        }
    }
}

struct EarthquakeRowView: View {
    let earthquake: Earthquake
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(earthquake.location)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(earthquake.formattedTime)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack {
                Text(String(format: "%.1f", earthquake.magnitude))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(magnitudeColor(for: earthquake.magnitude))
                
                Text("mag")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 50)
        }
        .padding(.vertical, 4)
    }
    
    private func magnitudeColor(for magnitude: Double) -> Color {
        switch magnitude {
        case 0..<2.5:
            return .green
        case 2.5..<4.5:
            return .yellow
        case 4.5..<6.0:
            return .orange
        case 6.0...:
            return .red
        default:
            return .gray
        }
    }
}

struct EarthquakeFilterView: View {
    let store: StoreOf<EarthquakeListFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("Filters")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button("Clear All") {
                        viewStore.send(.clearFilters)
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                
                // Magnitude Range
                VStack(alignment: .leading, spacing: 8) {
                    Text("Magnitude Range: \(String(format: "%.1f", viewStore.filterState.magnitudeRange.lowerBound)) - \(String(format: "%.1f", viewStore.filterState.magnitudeRange.upperBound))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        RangeSlider(
                            range: Binding(
                                get: { viewStore.filterState.magnitudeRange },
                                set: { viewStore.send(.setMagnitudeRange($0)) }
                            ),
                            bounds: 0.0...10.0
                        )
                        
                        Text("10")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Time Filter
                VStack(alignment: .leading, spacing: 8) {
                    Text("Time Period")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Time Period", selection: Binding(
                        get: { viewStore.filterState.timeFilter },
                        set: { viewStore.send(.setTimeFilter($0)) }
                    )) {
                        ForEach(EarthquakeListFeature.State.FilterState.TimeFilter.allCases, id: \.self) { timeFilter in
                            Text(timeFilter.rawValue).tag(timeFilter)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Location Search
                VStack(alignment: .leading, spacing: 8) {
                    Text("Location Search")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("Enter location keywords...", text: Binding(
                        get: { viewStore.filterState.locationSearch },
                        set: { viewStore.send(.setLocationSearch($0)) }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Results count
                if viewStore.filterState.isActive {
                    Text("\(viewStore.filteredEarthquakes.count) of \(viewStore.earthquakes.count) earthquakes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .animation(.easeInOut(duration: 0.3), value: viewStore.filterState.isActive)
        }
    }
}

struct RangeSlider: View {
    @Binding var range: ClosedRange<Double>
    let bounds: ClosedRange<Double>
    
    var body: some View {
        HStack {
            Slider(
                value: Binding(
                    get: { range.lowerBound },
                    set: { newValue in
                        range = newValue...max(newValue, range.upperBound)
                    }
                ),
                in: bounds
            )
            
            Slider(
                value: Binding(
                    get: { range.upperBound },
                    set: { newValue in
                        range = min(range.lowerBound, newValue)...newValue
                    }
                ),
                in: bounds
            )
        }
    }
}

#Preview {
    NavigationView {
        EarthquakeListView(
            store: Store(initialState: EarthquakeListFeature.State()) {
                EarthquakeListFeature()
            } withDependencies: {
                $0.earthquakeClient = .previewValue
            }
        )
    }
}
