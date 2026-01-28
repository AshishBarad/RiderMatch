import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class SeedData {
  static const List<Map<String, dynamic>> _indianCities = [
    {'name': 'Mumbai', 'lat': 19.0760, 'lng': 72.8777},
    {'name': 'Delhi', 'lat': 28.6139, 'lng': 77.2090},
    {'name': 'Bangalore', 'lat': 12.9716, 'lng': 77.5946},
    {'name': 'Hyderabad', 'lat': 17.3850, 'lng': 78.4867},
    {'name': 'Ahmedabad', 'lat': 23.0225, 'lng': 72.5714},
    {'name': 'Chennai', 'lat': 13.0827, 'lng': 80.2707},
    {'name': 'Kolkata', 'lat': 22.5726, 'lng': 88.3639},
    {'name': 'Surat', 'lat': 21.1702, 'lng': 72.8311},
    {'name': 'Pune', 'lat': 18.5204, 'lng': 73.8567},
    {'name': 'Jaipur', 'lat': 26.9124, 'lng': 75.7873},
    {'name': 'Lucknow', 'lat': 26.8467, 'lng': 80.9462},
    {'name': 'Kanpur', 'lat': 26.4499, 'lng': 80.3319},
    {'name': 'Nagpur', 'lat': 21.1458, 'lng': 79.0882},
    {'name': 'Indore', 'lat': 22.7196, 'lng': 75.8577},
    {'name': 'Thane', 'lat': 19.2183, 'lng': 72.9781},
    {'name': 'Bhopal', 'lat': 23.2599, 'lng': 77.4126},
    {'name': 'Visakhapatnam', 'lat': 17.6868, 'lng': 83.2185},
    {'name': 'Patna', 'lat': 25.5941, 'lng': 85.1376},
    {'name': 'Vadodara', 'lat': 22.3072, 'lng': 73.1812},
    {'name': 'Ghaziabad', 'lat': 28.6692, 'lng': 77.4538},
  ];

  static const List<String> _rideTitles = [
    'Morning Breeze Ride',
    'Weekend Coastal Tour',
    'Highland Adventure',
    'City Lights Night Ride',
    'Heritage Trail Exploration',
    'Lake Side Cruise',
    'Mountain Peak Challenge',
    'Sunset Highway Run',
    'Coffee Plantation Tour',
    'Desert Safari Ride',
  ];

  static Future<void> seedRides() async {
    final firestore = FirebaseFirestore.instance;
    final random = Random();

    debugPrint('🚀 Starting data seeding...');

    // 1. Clear existing data
    final collections = ['rides', 'ride_members', 'user_rides'];
    for (final collection in collections) {
      final snapshot = await firestore.collection(collection).get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
      debugPrint('🗑️ Cleared $collection');
    }

    // 2. Add 100 random rides
    for (int i = 0; i < 100; i++) {
      final city = _indianCities[random.nextInt(_indianCities.length)];
      final title = _rideTitles[random.nextInt(_rideTitles.length)];

      // Randomize location slightly within the city (approx 10km radius)
      final latOffset = (random.nextDouble() - 0.5) * 0.1;
      final lngOffset = (random.nextDouble() - 0.5) * 0.1;

      final rideLat = city['lat'] + latOffset;
      final rideLng = city['lng'] + lngOffset;

      final rideId = 'ride_${i + 1}';
      final creatorId = 'user_${random.nextInt(10) + 1}';

      // Hardcode a featured ride with a road-aware polyline for demonstration
      String encodedPolyline = '';
      bool isPrivateRide = random.nextBool();

      if (i == 0) {
        // Sample curvy route in Mumbai (Marine Drive area)
        encodedPolyline =
            'a{teAk~`u@i@cBqCwAsCm@_B}AsDm@uByAcEi@eBg@kBy@kCe@mBaAmDe@cBa@kBg@kBy@kCe@mBaAmDe@cBa@kBg@kBy@kCe@kBaAmDe@cBa@kBg@kBy@kCe@mBaAmDe';
        isPrivateRide = true;
      }

      await firestore.collection('rides').doc(rideId).set({
        'rideId': rideId,
        'rideName': i == 0
            ? 'Featured Mountain Pass - Mumbai'
            : '$title - ${city['name']} #$i',
        'description':
            'A beautiful $title through the heart of ${city['name']}. Join us for an unforgettable experience!',
        'fromLocation': {
          'name': '${city['name']} Center',
          'lat': rideLat,
          'lng': rideLng,
        },
        'toLocation': {
          'name': '${city['name']} Outskirts',
          'lat': rideLat + 0.05,
          'lng': rideLng + 0.05,
        },
        'distanceKm': 20.0 + random.nextInt(80),
        'startDate': Timestamp.fromDate(
          DateTime.now().add(
            Duration(days: random.nextInt(30), hours: random.nextInt(24)),
          ),
        ),
        'difficulty': ['Easy', 'Medium', 'Hard'][random.nextInt(3)],
        'isPublic': true,
        'isPrivate': isPrivateRide,
        'encodedPolyline':
            encodedPolyline, // Polylines are usually fetched on creation
        'maxParticipants': 5 + random.nextInt(15),
        'createdBy': creatorId,
        'participantIds': [creatorId],
        'status': 'UPCOMING',
        'currentParticipants': 1,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Add creator to members
      await firestore
          .collection('ride_members')
          .doc(rideId)
          .collection('members')
          .doc(creatorId)
          .set({
            'uid': creatorId,
            'joinedAt': FieldValue.serverTimestamp(),
            'status': 'APPROVED',
            'role': 'OWNER',
          });

      if (i % 10 == 0) {
        debugPrint('✅ Seeded $i rides...');
      }
    }

    debugPrint('✨ Seeding complete! 100 rides added across India.');
  }

  static Future<void> deleteUserData() async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('users').get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
    debugPrint('🗑️ Cleared users collection');
  }
}
