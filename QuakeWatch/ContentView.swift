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
        NavigationView {
            EarthquakeListView(
                store: Store(initialState: EarthquakeListFeature.State()) {
                    EarthquakeListFeature()
                }
            )
        }
    }
}

struct EarthquakeListView: View {
    let store: StoreOf<EarthquakeListFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
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
                        EarthquakeRowView(earthquake: earthquake)
                    }
                    .refreshable {
                        viewStore.send(.refresh)
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        viewStore.send(.refresh)
                    }
                    .disabled(viewStore.isLoading)
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
