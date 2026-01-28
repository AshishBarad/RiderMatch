import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/ride.dart';
import '../../domain/entities/ride_stop.dart';

abstract class RideRemoteDataSource {
  Future<List<Ride>> getNearbyRides(
    double lat,
    double lng,
    double radiusKm,
    bool femaleOnly,
  );
  Future<Ride?> getRideById(String id);
  Future<void> createRide(Ride ride);
  Future<void> updateRide(Ride ride);
  Future<void> requestToJoin(String rideId, String userId);
  Future<void> acceptJoinRequest(String rideId, String userId);
  Future<void> rejectJoinRequest(String rideId, String userId);
  Future<void> removeParticipant(String rideId, String userId);
  Future<void> inviteUser(String rideId, String userId);
  Future<void> deleteRide(String rideId);
  Future<List<Ride>> getCreatedRides(String userId);
  Future<List<Ride>> getJoinedRides(String userId);
}

class RideRemoteDataSourceImpl implements RideRemoteDataSource {
  final FirebaseFirestore _firestore;

  RideRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<Ride>> getNearbyRides(
    double lat,
    double lng,
    double radiusKm,
    bool femaleOnly,
  ) async {
    try {
      // 1. Calculate bounding box for latitude (approximate filter)
      // 1 degree latitude is approx 111.32 km

      var query = _firestore
          .collection('rides')
          .where('status', isEqualTo: 'UPCOMING')
          .where('isPublic', isEqualTo: true);

      if (femaleOnly) {
        query = query.where('creatorGender', isEqualTo: 'Female');
      }

      final snapshot = await query.limit(100).get();

      // 2. Filter by longitude and precise distance client-side
      // (Firestore only supports inequality on one field)
      final allRides = snapshot.docs
          .map((doc) => _rideFromFirestore(doc))
          .toList();

      return allRides.where((ride) {
        final distance = _getDistance(lat, lng, ride.fromLat, ride.fromLng);
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get nearby rides: $e');
    }
  }

  double _getDistance(double lat1, double lng1, double lat2, double lng2) {
    const double p = 0.017453292519943295; // Math.PI / 180
    final double a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lng2 - lng1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  @override
  Future<Ride?> getRideById(String id) async {
    try {
      final doc = await _firestore.collection('rides').doc(id).get();

      if (!doc.exists) {
        return null;
      }

      var ride = _rideFromFirestore(doc);

      // Fetch participants for detail view
      try {
        final membersSnapshot = await _firestore
            .collection('ride_members')
            .doc(id)
            .collection('members')
            .where('status', whereIn: ['APPROVED', 'OWNER'])
            .get();

        final participantIds = membersSnapshot.docs
            .map((d) => d.data()['uid'] as String)
            .toList();

        return ride.copyWith(participantIds: participantIds);
      } catch (e) {
        debugPrint('Error fetching participants: $e');
        return ride; // Return ride without participants if fetch fails
      }
    } catch (e) {
      throw Exception('Failed to get ride: $e');
    }
  }

  @override
  Future<void> createRide(Ride ride) async {
    try {
      final rideRef = _firestore.collection('rides').doc();

      // 1. Create the ride document
      await rideRef.set({
        'rideId': rideRef.id,
        'rideName': ride.title,
        'description': ride.description,
        'fromLocation': {
          'name': ride.fromLocation,
          'lat': ride.fromLat,
          'lng': ride.fromLng,
        },
        'toLocation': {
          'name': ride.toLocation,
          'lat': ride.toLat,
          'lng': ride.toLng,
        },
        'distanceKm': ride.validDistanceKm,
        'startDate': Timestamp.fromDate(ride.dateTime),
        'difficulty': ride.difficulty,
        'isPublic': true,
        'isPrivate': ride.isPrivate,
        'encodedPolyline': ride.encodedPolyline,
        'maxParticipants': 10, // Default value
        'createdBy': ride.creatorId,
        'status': 'UPCOMING',
        'currentParticipants': 1, // Start with 1 (the creator)
        'stops': ride.stops.map((s) => s.toJson()).toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Add creator to ride_members as OWNER and APPROVED
      await _firestore
          .collection('ride_members')
          .doc(rideRef.id)
          .collection('members')
          .doc(ride.creatorId)
          .set({
            'uid': ride.creatorId,
            'joinedAt': FieldValue.serverTimestamp(),
            'status': 'APPROVED',
            'role': 'OWNER',
          });

      // 3. Add to user_rides for quick lookup
      await _firestore
          .collection('user_rides')
          .doc(ride.creatorId)
          .collection('rides')
          .doc(rideRef.id)
          .set({
            'rideId': rideRef.id,
            'type': 'CREATED', // or 'JOINED'
            'joinedAt': FieldValue.serverTimestamp(),
          });

      // Cloud Function will handle adding creator as manager
    } catch (e) {
      throw Exception('Failed to create ride: $e');
    }
  }

  @override
  Future<void> updateRide(Ride ride) async {
    try {
      await _firestore.collection('rides').doc(ride.id).update({
        'rideName': ride.title,
        'description': ride.description,
        'fromLocation': {
          'name': ride.fromLocation,
          'lat': ride.fromLat,
          'lng': ride.fromLng,
        },
        'toLocation': {
          'name': ride.toLocation,
          'lat': ride.toLat,
          'lng': ride.toLng,
        },
        'distanceKm': ride.validDistanceKm,
        'startDate': Timestamp.fromDate(ride.dateTime),
        'difficulty': ride.difficulty,
        'isPrivate': ride.isPrivate,
        'encodedPolyline': ride.encodedPolyline,
        'stops': ride.stops.map((s) => s.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update ride: $e');
    }
  }

  @override
  Future<void> requestToJoin(String rideId, String userId) async {
    try {
      await _firestore
          .collection('ride_members')
          .doc(rideId)
          .collection('members')
          .doc(userId)
          .set({
            'uid': userId,
            'joinedAt': FieldValue.serverTimestamp(),
            'status': 'PENDING',
            'role': 'MEMBER',
          });

      // Cloud Function will handle validation and notifications
    } catch (e) {
      throw Exception('Failed to request join: $e');
    }
  }

  @override
  Future<void> acceptJoinRequest(String rideId, String userId) async {
    try {
      await _firestore
          .collection('ride_members')
          .doc(rideId)
          .collection('members')
          .doc(userId)
          .update({
            'status': 'APPROVED',
            'approvedAt': FieldValue.serverTimestamp(),
          });

      // Cloud Function will handle updating participant count and notifications
    } catch (e) {
      throw Exception('Failed to accept join request: $e');
    }
  }

  @override
  Future<void> rejectJoinRequest(String rideId, String userId) async {
    try {
      await _firestore
          .collection('ride_members')
          .doc(rideId)
          .collection('members')
          .doc(userId)
          .update({
            'status': 'REJECTED',
            'rejectedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to reject join request: $e');
    }
  }

  @override
  Future<void> removeParticipant(String rideId, String userId) async {
    try {
      await _firestore
          .collection('ride_members')
          .doc(rideId)
          .collection('members')
          .doc(userId)
          .delete();

      // Update participant count
      await _firestore.collection('rides').doc(rideId).update({
        'currentParticipants': FieldValue.increment(-1),
      });
    } catch (e) {
      throw Exception('Failed to remove participant: $e');
    }
  }

  @override
  Future<void> inviteUser(String rideId, String userId) async {
    try {
      final batch = _firestore.batch();

      // 1. Create an invitation document
      final inviteRef = _firestore.collection('ride_invitations').doc();
      batch.set(inviteRef, {
        'rideId': rideId,
        'invitedUserId': userId,
        'status': 'PENDING',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Update the ride document's invitedUserIds array
      final rideRef = _firestore.collection('rides').doc(rideId);
      batch.update(rideRef, {
        'invitedUserIds': FieldValue.arrayUnion([userId]),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to invite user: $e');
    }
  }

  @override
  Future<void> deleteRide(String rideId) async {
    try {
      await _firestore.collection('rides').doc(rideId).delete();

      // Cloud Function should handle cleanup of related data
    } catch (e) {
      throw Exception('Failed to delete ride: $e');
    }
  }

  @override
  Future<List<Ride>> getCreatedRides(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('rides')
          .where('createdBy', isEqualTo: userId)
          //.orderBy('createdAt', descending: true) // Removed to avoid index error
          .get();

      return snapshot.docs.map((doc) => _rideFromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get created rides: $e');
    }
  }

  @override
  Future<List<Ride>> getJoinedRides(String userId) async {
    try {
      // Get ride IDs from user_rides logic
      final userRidesSnapshot = await _firestore
          .collection('user_rides')
          .doc(userId)
          .collection('rides')
          .orderBy('joinedAt', descending: true)
          .get();

      final rideIds = userRidesSnapshot.docs
          .map((doc) => doc.data()['rideId'] as String)
          .toList();

      if (rideIds.isEmpty) {
        return [];
      }

      // Fetch ride details
      final rides = <Ride>[];
      for (final rideId in rideIds) {
        final ride = await getRideById(rideId);
        if (ride != null) {
          rides.add(ride);
        }
      }

      return rides;
    } catch (e) {
      throw Exception('Failed to get joined rides: $e');
    }
  }

  Ride _rideFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Ride(
      id: doc.id,
      creatorId: data['createdBy'] ?? '',
      creatorGender:
          data['creatorGender'] ?? 'Male', // TODO: Fetch from user profile
      title: data['rideName'] ?? '',
      description: data['description'] ?? '',
      fromLocation: data['fromLocation']['name'] ?? '',
      fromLat: (data['fromLocation']['lat'] as num?)?.toDouble() ?? 0.0,
      fromLng: (data['fromLocation']['lng'] as num?)?.toDouble() ?? 0.0,
      toLocation: data['toLocation']['name'] ?? '',
      toLat: (data['toLocation']['lat'] as num?)?.toDouble() ?? 0.0,
      toLng: (data['toLocation']['lng'] as num?)?.toDouble() ?? 0.0,
      dateTime: (data['startDate'] as Timestamp).toDate(),
      validDistanceKm: (data['distanceKm'] as num?)?.toDouble() ?? 0.0,
      difficulty: data['difficulty'] ?? 'Easy',
      encodedPolyline: data['encodedPolyline'] ?? '',
      isPrivate: data['isPrivate'] ?? false,
      participantIds:
          (data['participantIds'] as List?)?.map((e) => e as String).toList() ??
          [],
      invitedUserIds:
          (data['invitedUserIds'] as List?)?.map((e) => e as String).toList() ??
          [],
      participantGenders: [], // Fetch separately if needed
      stops:
          (data['stops'] as List?)
              ?.map((e) => RideStop.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
