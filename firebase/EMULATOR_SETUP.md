# Firebase Emulator Setup Guide

## Prerequisites

- Node.js 18 or higher
- Firebase CLI
- Java Runtime (for Firestore emulator)

## Installation Steps

### 1. Install Firebase CLI

```bash
npm install -g firebase-tools
```

### 2. Login to Firebase

```bash
firebase login
```

### 3. Initialize Firebase Project

```bash
cd firebase
firebase init
```

Select:
- ✅ Firestore
- ✅ Functions
- ✅ Storage
- ✅ Emulators

### 4. Install Cloud Functions Dependencies

```bash
cd functions
npm install
```

### 5. Start Emulators

```bash
# From firebase directory
firebase emulators:start
```

This will start:
- **Auth Emulator**: http://localhost:9099
- **Firestore Emulator**: http://localhost:8080
- **Functions Emulator**: http://localhost:5001
- **Storage Emulator**: http://localhost:9199
- **Emulator UI**: http://localhost:4000

## Emulator Configuration

The emulators are configured in `firebase.json`:

```json
{
  "emulators": {
    "auth": { "port": 9099 },
    "functions": { "port": 5001 },
    "firestore": { "port": 8080 },
    "storage": { "port": 9199 },
    "ui": { "enabled": true, "port": 4000 }
  }
}
```

## Connect Flutter App to Emulators

In your Flutter app, add this code before initializing Firebase:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<void> connectToEmulators() async {
  const bool useEmulator = true; // Set to false for production
  
  if (useEmulator) {
    // Connect to Firestore emulator
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    
    // Connect to Auth emulator
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    
    // Connect to Storage emulator
    await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
    
    print('✅ Connected to Firebase Emulators');
  }
}
```

## Seed Test Data

### Create Test Users

```bash
# Use Auth Emulator UI at http://localhost:4000
# Or use Firebase Auth SDK to create test users
```

### Add Test Rides

Use the Firestore Emulator UI to manually add test data, or run a seed script:

```typescript
// functions/src/seed.ts
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

async function seedData() {
  // Create test users
  await db.collection('users').doc('test_user_1').set({
    uid: 'test_user_1',
    name: 'John Rider',
    motorcycleBrand: 'Royal Enfield',
    motorcycleModel: 'Himalayan 450',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    rideCount: 0,
    followerCount: 0,
    followingCount: 0,
  });

  // Create test ride
  await db.collection('rides').doc('test_ride_1').set({
    rideId: 'test_ride_1',
    createdBy: 'test_user_1',
    rideName: 'Weekend Mountain Ride',
    fromLocation: {
      name: 'Bangalore',
      lat: 12.9716,
      lng: 77.5946,
    },
    toLocation: {
      name: 'Ooty',
      lat: 11.4102,
      lng: 76.6950,
    },
    distanceKm: 270,
    startDate: admin.firestore.Timestamp.now(),
    isPublic: true,
    status: 'UPCOMING',
    maxParticipants: 5,
    currentParticipants: 1,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  console.log('✅ Test data seeded');
}

seedData();
```

## Testing Cloud Functions

### Test Triggers

1. Create a ride in Firestore UI
2. Watch Functions logs in terminal
3. Verify `onRideCreated` trigger fires

### Test HTTP Endpoints

```bash
# Get nearby rides
curl http://localhost:5001/ridermatch-dev/us-central1/api/rides/nearby?lat=12.9716&lng=77.5946

# Create a ride
curl -X POST http://localhost:5001/ridermatch-dev/us-central1/api/rides/create \
  -H "Content-Type: application/json" \
  -d '{
    "createdBy": "test_user_1",
    "rideName": "Test Ride",
    "fromLocation": {"name": "City A", "lat": 12.9, "lng": 77.5},
    "toLocation": {"name": "City B", "lat": 13.0, "lng": 77.6},
    "distanceKm": 50,
    "startDate": "2024-12-01T10:00:00Z",
    "isPublic": true,
    "maxParticipants": 5
  }'
```

## Debugging Tips

### View Logs

```bash
# Watch all function logs
firebase emulators:start --inspect-functions

# View specific function logs
firebase functions:log
```

### Clear Emulator Data

```bash
# Stop emulators and clear data
firebase emulators:start --import=./emulator-data --export-on-exit
```

### Common Issues

**Issue**: Emulators won't start
- **Fix**: Check if ports are already in use
- **Command**: `lsof -i :8080` (check each port)

**Issue**: Functions not deploying
- **Fix**: Run `npm run build` in functions directory

**Issue**: Firestore rules blocking requests
- **Fix**: Check rules in Emulator UI Rules tab

## Environment Variables

Create `.env` file in functions directory:

```env
FIREBASE_PROJECT_ID=ridermatch-dev
FIREBASE_REGION=us-central1
```

## Next Steps

1. ✅ Start emulators
2. ✅ Connect Flutter app to emulators
3. ✅ Seed test data
4. ✅ Test all Cloud Functions
5. ✅ Verify security rules
6. 🚀 Ready for development!
