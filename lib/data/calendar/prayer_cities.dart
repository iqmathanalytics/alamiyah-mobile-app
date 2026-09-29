class PrayerCity {
  const PrayerCity({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String country;
  final double latitude;
  final double longitude;

  String get label => '$name, $country';
}

/// Curated city list for prayer-time fallback when GPS is off.
const prayerCities = <PrayerCity>[
  PrayerCity(name: 'Makkah', country: 'Saudi Arabia', latitude: 21.4225, longitude: 39.8262),
  PrayerCity(name: 'Madinah', country: 'Saudi Arabia', latitude: 24.4672, longitude: 39.6111),
  PrayerCity(name: 'Riyadh', country: 'Saudi Arabia', latitude: 24.7136, longitude: 46.6753),
  PrayerCity(name: 'Dubai', country: 'UAE', latitude: 25.2048, longitude: 55.2708),
  PrayerCity(name: 'Abu Dhabi', country: 'UAE', latitude: 24.4539, longitude: 54.3773),
  PrayerCity(name: 'Doha', country: 'Qatar', latitude: 25.2854, longitude: 51.5310),
  PrayerCity(name: 'Kuwait City', country: 'Kuwait', latitude: 29.3759, longitude: 47.9774),
  PrayerCity(name: 'Muscat', country: 'Oman', latitude: 23.5880, longitude: 58.3829),
  PrayerCity(name: 'Amman', country: 'Jordan', latitude: 31.9454, longitude: 35.9284),
  PrayerCity(name: 'Cairo', country: 'Egypt', latitude: 30.0444, longitude: 31.2357),
  PrayerCity(name: 'Istanbul', country: 'Türkiye', latitude: 41.0082, longitude: 28.9784),
  PrayerCity(name: 'Jakarta', country: 'Indonesia', latitude: -6.2088, longitude: 106.8456),
  PrayerCity(name: 'Kuala Lumpur', country: 'Malaysia', latitude: 3.1390, longitude: 101.6869),
  PrayerCity(name: 'Karachi', country: 'Pakistan', latitude: 24.8607, longitude: 67.0011),
  PrayerCity(name: 'Lahore', country: 'Pakistan', latitude: 31.5204, longitude: 74.3587),
  PrayerCity(name: 'Dhaka', country: 'Bangladesh', latitude: 23.8103, longitude: 90.4125),
  PrayerCity(name: 'Delhi', country: 'India', latitude: 28.6139, longitude: 77.2090),
  PrayerCity(name: 'London', country: 'UK', latitude: 51.5074, longitude: -0.1278),
  PrayerCity(name: 'Paris', country: 'France', latitude: 48.8566, longitude: 2.3522),
  PrayerCity(name: 'Toronto', country: 'Canada', latitude: 43.6532, longitude: -79.3832),
  PrayerCity(name: 'New York', country: 'USA', latitude: 40.7128, longitude: -74.0060),
  PrayerCity(name: 'Chicago', country: 'USA', latitude: 41.8781, longitude: -87.6298),
  PrayerCity(name: 'Los Angeles', country: 'USA', latitude: 34.0522, longitude: -118.2437),
  PrayerCity(name: 'Cape Town', country: 'South Africa', latitude: -33.9249, longitude: 18.4241),
  PrayerCity(name: 'Sydney', country: 'Australia', latitude: -33.8688, longitude: 151.2093),
];
