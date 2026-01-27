# RiderMatch API Documentation

## Base URL

**Development**: `http://localhost:5001/ridermatch-dev/us-central1/api`
**Production**: `https://us-central1-ridermatch-prod.cloudfunctions.net/api`

## Authentication

All API requests require Firebase Authentication token in the header:

```
Authorization: Bearer <FIREBASE_ID_TOKEN>
```

Get token in Flutter:
```dart
final token = await FirebaseAuth.instance.currentUser?.getIdToken();
```

---

## Endpoints

### 1. Get Nearby Rides

**GET** `/rides/nearby`

Get public upcoming rides near a location.

**Query Parameters:**
- `lat` (required): Latitude
- `lng` (required): Longitude
- `radiusKm` (optional): Search radius in km (default: 50)
- `limit` (optional): Max results (default: 20)

**Example Request:**
```bash
GET /api/rides/nearby?lat=12.9716&lng=77.5946&radiusKm=50&limit=10
```

**Response:**
```json
{
  "rides": [
    {
      "id": "ride123",
      "rideName": "Weekend Mountain Ride",
      "fromLocation": {
        "name": "Bangalore",
        "lat": 12.9716,
        "lng": 77.5946
      },
      "toLocation": {
        "name": "Ooty",
        "lat": 11.4102,
        "lng": 76.6950
      },
      "distanceKm": 270,
      "startDate": "2024-12-15T06:00:00Z",
      "status": "UPCOMING",
      "maxParticipants": 5,
      "currentParticipants": 2,
      "isPublic": true,
      "createdBy": "user123"
    }
  ]
}
```

---

### 2. Get User Rides

**GET** `/rides/user/:uid`

Get all rides for a specific user.

**Path Parameters:**
- `uid` (required): User ID

**Query Parameters:**
- `type` (optional): Filter by type ('CREATED' | 'JOINED' | 'COMPLETED')

**Example Request:**
```bash
GET /api/rides/user/user123?type=CREATED
```

**Response:**
```json
{
  "rides": [
    {
      "id": "ride123",
      "rideName": "Weekend Mountain Ride",
      ...
    }
  ]
}
```

---

### 3. Create Ride

**POST** `/rides/create`

Create a new ride.

**Request Body:**
```json
{
  "createdBy": "user123",
  "rideName": "Weekend Mountain Ride",
  "fromLocation": {
    "name": "Bangalore",
    "lat": 12.9716,
    "lng": 77.5946
  },
  "toLocation": {
    "name": "Ooty",
    "lat": 11.4102,
    "lng": 76.6950
  },
  "distanceKm": 270,
  "startDate": "2024-12-15T06:00:00Z",
  "startTime": "06:00",
  "isPublic": true,
  "maxParticipants": 5
}
```

**Response:**
```json
{
  "rideId": "ride123",
  "message": "Ride created successfully"
}
```

---

### 4. Join Ride

**POST** `/rides/join`

Request to join a ride.

**Request Body:**
```json
{
  "rideId": "ride123",
  "uid": "user456"
}
```

**Response:**
```json
{
  "message": "Join request sent successfully"
}
```

**Error Responses:**
- `400`: Already requested or joined
- `404`: Ride not found

---

### 5. Approve Ride Member

**POST** `/rides/approve`

Approve a user's request to join a ride.

**Request Body:**
```json
{
  "rideId": "ride123",
  "uid": "user456",
  "approverId": "user123"
}
```

**Response:**
```json
{
  "message": "Member approved successfully"
}
```

**Error Responses:**
- `403`: Only ride creator can approve
- `404`: Ride not found

---

## Firestore Direct Access

For real-time updates, use Firestore SDK directly:

### Get Ride Details

```dart
final rideDoc = await FirebaseFirestore.instance
    .collection('rides')
    .doc(rideId)
    .get();

final ride = rideDoc.data();
```

### Listen to Ride Updates

```dart
FirebaseFirestore.instance
    .collection('rides')
    .doc(rideId)
    .snapshots()
    .listen((snapshot) {
      final ride = snapshot.data();
      // Update UI
    });
```

### Get Ride Members

```dart
final membersSnapshot = await FirebaseFirestore.instance
    .collection('ride_members')
    .doc(rideId)
    .collection('members')
    .where('status', isEqualTo: 'APPROVED')
    .get();

final members = membersSnapshot.docs.map((doc) => doc.data()).toList();
```

### Get User's Chats

```dart
final chatsSnapshot = await FirebaseFirestore.instance
    .collection('direct_chats')
    .where('participantIds', arrayContains: currentUserId)
    .where('status', isEqualTo: 'APPROVED')
    .orderBy('updatedAt', descending: true)
    .get();
```

### Send Chat Message

```dart
await FirebaseFirestore.instance
    .collection('chat_messages')
    .doc(chatId)
    .collection('messages')
    .add({
      'chatId': chatId,
      'senderId': currentUserId,
      'content': messageText,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
```

---

## Cloud Functions Triggers

These are automatically triggered by Firestore changes:

### onRideJoinRequest
- **Trigger**: New document in `ride_members/{rideId}/members/{uid}`
- **Action**: Validates capacity, sends notification to ride manager

### onRideJoinApproved
- **Trigger**: Member status updated to 'APPROVED'
- **Action**: Updates indexes, increments participant count, sends notification

### onRideCreated
- **Trigger**: New document in `rides/{rideId}`
- **Action**: Notifies all followers, adds to creator's ride index

### onFollowUser
- **Trigger**: New document in `follows/{uid}/following/{targetUid}`
- **Action**: Updates follower/following counts, creates reverse relationship

### onChatMessage
- **Trigger**: New document in `chat_messages/{chatId}/messages/{messageId}`
- **Action**: Updates chat metadata, sends FCM notification

---

## Error Codes

| Code | Description |
|------|-------------|
| 400 | Bad Request - Missing or invalid parameters |
| 401 | Unauthorized - Invalid or missing auth token |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource doesn't exist |
| 500 | Internal Server Error |

---

## Rate Limits

- API endpoints: 100 requests/minute per user
- Firestore reads: No hard limit (pay-per-use)
- Firestore writes: 10,000/second per database

---

## Best Practices

1. **Use Real-time Listeners**: For live data (rides, chats), use Firestore snapshots instead of polling
2. **Batch Operations**: Use batch writes for multiple updates
3. **Pagination**: Always use `limit()` and `startAfter()` for large collections
4. **Offline Support**: Enable Firestore offline persistence
5. **Error Handling**: Always handle network errors gracefully

---

## Sample Integration (Flutter)

```dart
class RideService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get nearby rides
  Future<List<Ride>> getNearbyRides(double lat, double lng) async {
    final response = await http.get(
      Uri.parse('$baseUrl/rides/nearby?lat=$lat&lng=$lng'),
      headers: {'Authorization': 'Bearer ${await getToken()}'},
    );
    
    final data = json.decode(response.body);
    return (data['rides'] as List)
        .map((json) => Ride.fromJson(json))
        .toList();
  }
  
  // Listen to ride updates
  Stream<Ride> watchRide(String rideId) {
    return _firestore
        .collection('rides')
        .doc(rideId)
        .snapshots()
        .map((doc) => Ride.fromFirestore(doc));
  }
  
  // Join ride
  Future<void> joinRide(String rideId, String uid) async {
    await _firestore
        .collection('ride_members')
        .doc(rideId)
        .collection('members')
        .doc(uid)
        .set({
          'uid': uid,
          'joinedAt': FieldValue.serverTimestamp(),
          'status': 'PENDING',
          'role': 'MEMBER',
        });
  }
}
```
