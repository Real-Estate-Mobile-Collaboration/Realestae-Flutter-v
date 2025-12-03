# Map Feature Documentation

## Overview
The Map feature allows users to view properties on an interactive map, making it easier to find properties in specific locations.

## Features

### Current Implementation
- Basic map screen with placeholder UI
- Navigation from profile screen
- Gradient background design consistent with app theme

### Planned Features
1. **Interactive Map**
   - Display all properties on a map
   - Cluster markers for nearby properties
   - Zoom and pan capabilities

2. **Property Markers**
   - Custom markers showing property type
   - Price display on markers
   - Tap to view property details

3. **Map Filters**
   - Filter by property type
   - Filter by price range
   - Filter by number of bedrooms/bathrooms

4. **Location Search**
   - Search for specific addresses
   - Auto-complete suggestions
   - Current location button

5. **Map Layers**
   - Street view
   - Satellite view
   - Terrain view

## Technical Requirements

### Dependencies
To implement the full map feature, add these dependencies to `pubspec.yaml`:

```yaml
dependencies:
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
  geocoding: ^2.1.1
```

### Platform Configuration

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<manifest>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <application>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_API_KEY_HERE"/>
    </application>
</manifest>
```

#### iOS (`ios/Runner/AppDelegate.swift`)
```swift
import GoogleMaps

GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show nearby properties</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location to show nearby properties</string>
```

## Implementation Guide

### Step 1: Get Google Maps API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable "Maps SDK for Android" and "Maps SDK for iOS"
4. Create API credentials
5. Add API key to platform configurations

### Step 2: Update Map Screen
Replace the placeholder UI in `lib/screens/map/map_screen.dart` with:
- GoogleMap widget
- Property markers from PropertyProvider
- Location services integration

### Step 3: Add Map Controller
Create a MapProvider to manage:
- Map state
- Marker clustering
- Property filtering
- Location updates

### Step 4: Implement Features
- Add marker tap handlers
- Implement filter bottom sheet
- Add location search bar
- Create custom marker icons

## API Integration

### Backend Endpoint
```
GET /api/properties/nearby?lat={latitude}&lng={longitude}&radius={meters}
```

### Response Format
```json
{
  "success": true,
  "properties": [
    {
      "id": "prop123",
      "location": {
        "lat": 33.5731,
        "lng": -7.5898,
        "address": "123 Main St",
        "city": "Casablanca"
      },
      "price": 250000,
      "type": "apartment",
      "bedrooms": 3
    }
  ]
}
```

## Usage Examples

### Basic Map Display
```dart
GoogleMap(
  initialCameraPosition: CameraPosition(
    target: LatLng(33.5731, -7.5898),
    zoom: 12,
  ),
  markers: _markers,
  onMapCreated: _onMapCreated,
)
```

### Add Property Marker
```dart
Marker(
  markerId: MarkerId(property.id),
  position: LatLng(
    property.location.latitude,
    property.location.longitude,
  ),
  infoWindow: InfoWindow(
    title: '\$${property.price}',
    snippet: property.location.address,
  ),
  onTap: () => _showPropertyDetails(property),
)
```

## Best Practices

1. **Performance**
   - Limit number of markers displayed
   - Use marker clustering for dense areas
   - Cache map tiles for offline use

2. **UX**
   - Show loading states
   - Handle location permission gracefully
   - Provide fallback if location unavailable

3. **Security**
   - Restrict API key usage
   - Don't expose API key in version control
   - Use environment variables

## Troubleshooting

### Common Issues

**Map not showing:**
- Check API key is valid
- Verify platform configurations
- Check internet connection

**Location not working:**
- Request location permissions
- Enable location services
- Check permission in app settings

**Markers not appearing:**
- Verify latitude/longitude values
- Check marker visibility settings
- Ensure markers within map bounds

## Resources

- [Google Maps Flutter Plugin](https://pub.dev/packages/google_maps_flutter)
- [Geolocator Package](https://pub.dev/packages/geolocator)
- [Google Maps Platform](https://developers.google.com/maps)
