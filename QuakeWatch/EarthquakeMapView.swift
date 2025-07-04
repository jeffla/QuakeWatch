//
//  EarthquakeMapView.swift
//  QuakeWatch
//
//  Created by Jeff Lacey on 7/3/25.
//

import SwiftUI
import ComposableArchitecture
import MapKit

struct EarthquakeMapView: View {
    let store: StoreOf<EarthquakeMapFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                Map(coordinateRegion: .constant(viewStore.mapRegion), annotationItems: viewStore.earthquakes.filter { earthquake in
                    earthquake.latitude >= -90 && earthquake.latitude <= 90 &&
                    earthquake.longitude >= -180 && earthquake.longitude <= 180
                }) { earthquake in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(
                        latitude: earthquake.latitude,
                        longitude: earthquake.longitude
                    )) {
                        EarthquakeMapPin(earthquake: earthquake) {
                            viewStore.send(.earthquakeSelected(earthquake))
                        }
                    }
                }
                .ignoresSafeArea()
                
                // Loading overlay
                if viewStore.isLoading && viewStore.earthquakes.isEmpty {
                    VStack {
                        ProgressView()
                        Text("Loading earthquakes...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .shadow(radius: 2)
                }
                
                // Error message
                if let errorMessage = viewStore.errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.title)
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            viewStore.send(.refresh)
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .shadow(radius: 2)
                }
                
                // Offline indicator
                if !viewStore.isOnline {
                    VStack {
                        HStack {
                            Image(systemName: "wifi.slash")
                            Text(viewStore.isUsingCachedData ? "Offline - Showing cached data" : "Offline")
                        }
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange)
                        .cornerRadius(12)
                        Spacer()
                    }
                    .padding(.top, 8)
                }
                
                // Refresh indicator
                if viewStore.isLoading && !viewStore.earthquakes.isEmpty {
                    VStack {
                        Spacer()
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
            }
            .navigationTitle("Earthquake Map")
            .onAppear {
                viewStore.send(.onAppear)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        viewStore.send(.refresh)
                    }
                    .disabled(viewStore.isLoading)
                }
            }
            .sheet(
                store: store.scope(state: \.$earthquakeDetail, action: \.earthquakeDetail)
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

struct EarthquakeMapPin: View {
    let earthquake: Earthquake
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(magnitudeColor(for: earthquake.magnitude))
                    .frame(width: pinSize(for: earthquake.magnitude), height: pinSize(for: earthquake.magnitude))
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .shadow(radius: 2)
                
                Text(String(format: "%.1f", earthquake.magnitude))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
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
    
    private func pinSize(for magnitude: Double) -> CGFloat {
        switch magnitude {
        case 0..<2.5:
            return 20
        case 2.5..<4.5:
            return 25
        case 4.5..<6.0:
            return 30
        case 6.0...:
            return 35
        default:
            return 20
        }
    }
}

#Preview {
    NavigationView {
        EarthquakeMapView(
            store: Store(initialState: EarthquakeMapFeature.State()) {
                EarthquakeMapFeature()
            } withDependencies: {
                $0.earthquakeClient = .previewValue
            }
        )
    }
}