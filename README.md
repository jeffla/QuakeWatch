# QuakeWatch

A SwiftUI iOS app for monitoring earthquake data from the USGS API, built with The Composable Architecture (TCA).

## Features

### 🌍 Real-time Earthquake Monitoring
- Fetches live earthquake data from the USGS GeoJSON API
- Displays earthquakes with magnitude, location, and time information
- Auto-refresh capabilities with configurable intervals

### 📱 Multiple View Modes
- **List View**: Scrollable list of earthquakes with detailed information
- **Map View**: Interactive map showing earthquake locations with color-coded pins
- **Detail View**: Comprehensive earthquake details with direct USGS links

### 🔍 Advanced Filtering
- Filter by magnitude range (0.0 - 10.0)
- Filter by time period (past hour, day, week, month, or all time)
- Filter by location with text search
- Clear visual indicators for active filters

### ⚙️ Customizable Settings
- Configurable auto-refresh intervals (1 min to 1 hour)
- Notification threshold settings
- Display preferences (magnitude labels, metric units)
- Toggle minor earthquakes visibility

### 📶 Offline Support
- Local data caching for offline viewing
- Smart cache validation (5-minute fresh data window)
- Automatic fallback to cached data when network is unavailable
- Clear offline indicators in the UI

## Architecture

QuakeWatch is built using **The Composable Architecture (TCA)**, providing:
- Predictable state management
- Testable business logic
- Modular feature composition
- Comprehensive dependency injection

### Key Components

- **Models**: `Earthquake` data model with USGS GeoJSON parsing
- **Clients**: `EarthquakeClient` for API communication, `CacheManager` for local storage
- **Features**: TCA-based features with State/Action/Reducer patterns
- **Views**: SwiftUI views with proper state observation

## Technical Requirements

- **iOS**: 18.5+
- **Xcode**: 15.0+
- **Swift**: 5.0+
- **Dependencies**: 
  - SwiftUI
  - The Composable Architecture
  - MapKit
  - Swift Testing (for tests)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/QuakeWatch.git
   cd QuakeWatch
   ```

2. Open the project in Xcode:
   ```bash
   open QuakeWatch/QuakeWatch.xcodeproj
   ```

3. Build and run the project using Xcode or the command line:
   ```bash
   xcodebuild -project QuakeWatch/QuakeWatch.xcodeproj -scheme QuakeWatch -destination 'platform=iOS Simulator,name=iPhone 16' build
   ```

## Development

### Building
- **Xcode**: Use Cmd+B to build
- **Command Line**: `xcodebuild -project QuakeWatch/QuakeWatch.xcodeproj -scheme QuakeWatch -destination 'platform=iOS Simulator,name=iPhone 16' build`

### Running Tests
- **Xcode**: Use Cmd+U to run all tests
- **Command Line**: `xcodebuild test -project QuakeWatch/QuakeWatch.xcodeproj -scheme QuakeWatch -destination 'platform=iOS Simulator,name=iPhone 16'`

### Code Quality
- The project uses Xcode's built-in analyzer (Product → Analyze)
- Swift Testing framework for modern, expressive tests
- Comprehensive test coverage for all features including offline scenarios

## API Reference

QuakeWatch uses the [USGS Earthquake Hazards Program API](https://earthquake.usgs.gov/earthquakes/feed/v1.0/geojson.php):
- **Endpoint**: `https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson`
- **Format**: GeoJSON with earthquake features
- **Update Frequency**: Real-time (typically updated every 5 minutes)

## Project Structure

```
QuakeWatch/
├── QuakeWatch/
│   ├── QuakeWatchApp.swift          # App entry point
│   ├── ContentView.swift            # Root view with tab navigation
│   ├── Models/
│   │   └── Earthquake.swift         # Core data models
│   ├── Clients/
│   │   ├── EarthquakeClient.swift   # API client
│   │   └── CacheManager.swift       # Local caching
│   ├── Features/
│   │   ├── EarthquakeListFeature.swift      # List feature logic
│   │   ├── EarthquakeDetailFeature.swift    # Detail feature logic
│   │   ├── EarthquakeMapFeature.swift       # Map feature logic
│   │   ├── SettingsFeature.swift           # Settings feature logic
│   │   └── RootFeature.swift               # Root navigation logic
│   └── Views/
│       ├── EarthquakeListView.swift        # List view UI
│       ├── EarthquakeDetailView.swift      # Detail view UI
│       ├── EarthquakeMapView.swift         # Map view UI
│       └── SettingsView.swift              # Settings view UI
├── QuakeWatchTests/
│   └── QuakeWatchTests.swift        # Comprehensive test suite
└── README.md                        # This file
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [USGS Earthquake Hazards Program](https://earthquake.usgs.gov/) for providing real-time earthquake data
- [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) for the architectural framework
- Apple's SwiftUI and MapKit frameworks for the user interface

## Screenshots

![Simulator Screenshot - iPhone 16 Pro - 2025-07-03 at 19 42 42](https://github.com/user-attachments/assets/be8fc9b8-3758-4e3f-b85c-94ebe894cac2)

![Simulator Screenshot - iPhone 16 Pro - 2025-07-03 at 19 43 02](https://github.com/user-attachments/assets/8881de96-40f7-408b-8ea6-a3f49ab00e22)

![Simulator Screenshot - iPhone 16 Pro - 2025-07-03 at 18 17 50](https://github.com/user-attachments/assets/d5d7f12a-6337-4425-95fc-360c7b8198fb)

---
**Note**: This app is for educational and informational purposes. For official earthquake information and alerts, please refer to your local geological survey or emergency management agency.
