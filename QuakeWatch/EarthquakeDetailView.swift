//
//  EarthquakeDetailView.swift
//  QuakeWatch
//
//  Created by Jeff Lacey on 7/3/25.
//

import SwiftUI
import ComposableArchitecture
import MapKit

struct EarthquakeDetailView: View {
    let store: StoreOf<EarthquakeDetailFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header with magnitude
                    VStack(spacing: 8) {
                        Text(String(format: "%.1f", viewStore.earthquake.magnitude))
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundColor(magnitudeColor(for: viewStore.earthquake.magnitude))
                        
                        Text("Magnitude")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(viewStore.earthquake.magnitudeCategory.rawValue)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(magnitudeColor(for: viewStore.earthquake.magnitude).opacity(0.2))
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Location and Time
                    VStack(alignment: .leading, spacing: 12) {
                        DetailRow(title: "Location", value: viewStore.earthquake.location)
                        DetailRow(title: "Time", value: viewStore.earthquake.formattedTime)
                        DetailRow(title: "Date", value: formatDate(viewStore.earthquake.time))
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Geographic Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Geographic Details")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        DetailRow(title: "Latitude", value: String(format: "%.4f°", viewStore.earthquake.latitude))
                        DetailRow(title: "Longitude", value: String(format: "%.4f°", viewStore.earthquake.longitude))
                        DetailRow(title: "Depth", value: String(format: "%.1f km", viewStore.earthquake.depth))
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Map
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Location Map")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Map(coordinateRegion: .constant(MKCoordinateRegion(
                            center: CLLocationCoordinate2D(
                                latitude: viewStore.earthquake.latitude,
                                longitude: viewStore.earthquake.longitude
                            ),
                            span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
                        )), annotationItems: [viewStore.earthquake]) { earthquake in
                            MapAnnotation(coordinate: CLLocationCoordinate2D(
                                latitude: earthquake.latitude,
                                longitude: earthquake.longitude
                            )) {
                                VStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                        .font(.title2)
                                    Text(String(format: "%.1f", earthquake.magnitude))
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(Color.red)
                                        .cornerRadius(4)
                                }
                            }
                        }
                        .frame(height: 200)
                        .cornerRadius(12)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // USGS Link
                    Button(action: { viewStore.send(.openUSGSLink) }) {
                        HStack {
                            Image(systemName: "link")
                            Text("View on USGS Website")
                            Spacer()
                            if viewStore.isOpeningURL {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.up.right")
                            }
                        }
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .disabled(viewStore.isOpeningURL)
                }
                .padding()
            }
            .navigationTitle("Earthquake Details")
            .navigationBarTitleDisplayMode(.inline)
        }
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    NavigationView {
        EarthquakeDetailView(
            store: Store(initialState: EarthquakeDetailFeature.State(
                earthquake: Earthquake(from: EarthquakeFeature(
                    type: "Feature",
                    properties: EarthquakeProperties(
                        mag: 4.5,
                        place: "10 km N of Ridgecrest, CA",
                        time: Int(Date().addingTimeInterval(-7200).timeIntervalSince1970 * 1000),
                        updated: Int(Date().timeIntervalSince1970 * 1000),
                        tz: nil,
                        url: "https://earthquake.usgs.gov/earthquakes/eventpage/preview1",
                        detail: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/detail/preview1.geojson",
                        felt: nil,
                        cdi: nil,
                        mmi: nil,
                        alert: nil,
                        status: "reviewed",
                        tsunami: 0,
                        sig: 314,
                        net: "ci",
                        code: "12345",
                        ids: ",ci12345,",
                        sources: ",ci,",
                        types: ",general-link,origin,phase-data,",
                        nst: nil,
                        dmin: nil,
                        rms: nil,
                        gap: nil,
                        magType: "ml",
                        type: "earthquake",
                        title: "M 4.5 - 10 km N of Ridgecrest, CA"
                    ),
                    geometry: EarthquakeGeometry(
                        type: "Point",
                        coordinates: [-117.6748, 35.8721, 8.21]
                    ),
                    id: "ci12345"
                ))
            )) {
                EarthquakeDetailFeature()
            }
        )
    }
}