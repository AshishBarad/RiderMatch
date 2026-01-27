# Firestore Database Schema Documentation

## Overview
This document describes the complete Firestore database schema for the RiderMatch motorcycle ride matching application.

## Collections Structure

### 1. `users/{uid}`
Stores user profile information.

**Fields:**
```typescript
{
  uid: string;                    // Firebase Auth UID (same as document ID)
  name: string;                   // Full name
  photoUrl?: string;              // Storage URL for profile image
  gender?: string;                // 'MALE' | 'FEMALE' | 'OTHER'
  motorcycleBrand?: string;       // e.g., "Royal Enfield"
  motorcycleModel?: string;       // e.g., "Himalayan 450"
  ridingPreferences: string[];    // ['HIGHWAY', 'OFFROAD', 'CITY']
  createdAt: Timestamp;
  lastActive: Timestamp;
  rideCount: number;              // Denormalized counter
  followerCount: number;          // Denormalized counter
  followingCount: number;         // Denormalized counter
}
```

**Indexes:**
- `lastActive` (DESC)
- Composite: `motorcycleBrand` + `lastActive`

---

### 2. `rides/{rideId}`
Stores ride information.

**Fields:**
```typescript
{
  rideId: string;                 // Auto-generated document ID
  createdBy: string;              // User UID
  rideName: string;
  fromLocation: {
    name: string;
    lat: number;
    lng: number;
  };
  toLocation: {
    name: string;
    lat: number;
    lng: number;
  };
  geoHash: string;                // For geolocation queries
  distanceKm: number;
  startDate: Timestamp;
  startTime: string;              // "HH:MM" format
  isPublic: boolean;
  status: string;                 // 'UPCOMING' | 'COMPLETED' | 'CANCELLED'
  maxParticipants: number;
  currentParticipants: number;    // Denormalized counter
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

**Indexes:**
- `status` + `startDate` (ASC)
- `createdBy` + `createdAt` (DESC)
- `geoHash` + `status` + `startDate`
- `isPublic` + `status` + `startDate`

---

### 3. `ride_members/{rideId}/members/{uid}`
Subcollection storing ride participants.

**Fields:**
```typescript
{
  uid: string;                    // User UID
  joinedAt: Timestamp;
  status: string;                 // 'PENDING' | 'APPROVED' | 'REJECTED'
  role: string;                   // 'MANAGER' | 'MEMBER'
}
```

**Indexes:**
- `status` + `joinedAt`

---

### 4. `user_rides/{uid}/rides/{rideId}`
Index for fast user ride lookups.

**Fields:**
```typescript
{
  rideId: string;
  type: string;                   // 'CREATED' | 'JOINED' | 'COMPLETED'
  createdAt: Timestamp;
}
```

**Indexes:**
- `type` + `createdAt` (DESC)

---

### 5. `follows/{uid}/following/{targetUid}`
Tracks who a user is following.

**Fields:**
```typescript
{
  targetUid: string;
  followedAt: Timestamp;
}
```

---

### 6. `follows/{uid}/followers/{sourceUid}`
Tracks who follows a user.

**Fields:**
```typescript
{
  sourceUid: string;
  followedAt: Timestamp;
}
```

---

### 7. `ride_media/{rideId}/items/{mediaId}`
Media files associated with rides.

**Fields:**
```typescript
{
  mediaId: string;
  uploadedBy: string;             // User UID
  mediaType: string;              // 'IMAGE' | 'VIDEO'
  mediaUrl: string;               // Storage URL
  thumbnailUrl?: string;
  createdAt: Timestamp;
}
```

---

### 8. `ride_posts/{rideId}/posts/{postId}`
Feed/updates for a ride.

**Fields:**
```typescript
{
  postId: string;
  postedBy: string;               // User UID
  message: string;
  mediaUrl?: string;
  createdAt: Timestamp;
}
```

**Indexes:**
- `createdAt` (DESC)

---

### 9. `direct_chats/{chatId}`
Direct message conversations.

**Fields:**
```typescript
{
  chatId: string;
  participantIds: string[];       // [uid1, uid2] - always 2 users
  lastMessage?: string;
  lastMessageTime?: Timestamp;
  status: string;                 // 'APPROVED' | 'PENDING' | 'REJECTED'
  requestedBy: string;            // User UID who initiated
  unreadCount: {                  // Map of uid -> count
    [uid: string]: number;
  };
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

**Indexes:**
- Composite: `participantIds` (array-contains) + `updatedAt` (DESC)

---

### 10. `chat_messages/{chatId}/messages/{messageId}`
Messages within a direct chat.

**Fields:**
```typescript
{
  messageId: string;
  chatId: string;
  senderId: string;               // User UID
  content: string;
  isRead: boolean;
  createdAt: Timestamp;
}
```

**Indexes:**
- `createdAt` (ASC)

---

### 11. `chat_requests/{requestId}`
Chat access requests from non-followers.

**Fields:**
```typescript
{
  requestId: string;
  fromUserId: string;
  toUserId: string;
  message?: string;               // Optional intro message
  status: string;                 // 'PENDING' | 'APPROVED' | 'REJECTED'
  createdAt: Timestamp;
}
```

**Indexes:**
- `toUserId` + `status` + `createdAt` (DESC)
- `fromUserId` + `toUserId` + `status`

---

## Geolocation Strategy

### Using GeoHash for Proximity Queries

**Implementation:**
```typescript
import * as geofirestore from 'geofirestore';

// When creating a ride
const geoHash = geofirestore.encodeGeohash(
  ride.fromLocation.lat,
  ride.fromLocation.lng
);

ride.geoHash = geoHash;
```

**Query nearby rides:**
```typescript
const center = { lat: userLat, lng: userLng };
const radiusInKm = 50;

const query = geofirestore.query(
  ridesCollection,
  center,
  radiusInKm
);
```

---

## Denormalized Counters

To minimize reads, we maintain counters:

- `users.rideCount` - Updated when ride is completed
- `users.followerCount` - Updated on follow/unfollow
- `users.followingCount` - Updated on follow/unfollow
- `rides.currentParticipants` - Updated when member approved

**Update via Cloud Functions** to ensure consistency.

---

## Data Access Patterns

### Common Queries

1. **Get user's created rides:**
   ```
   user_rides/{uid}/rides
   WHERE type == 'CREATED'
   ORDER BY createdAt DESC
   ```

2. **Get nearby upcoming rides:**
   ```
   rides
   WHERE geoHash IN [calculated hashes]
   WHERE status == 'UPCOMING'
   WHERE isPublic == true
   ORDER BY startDate ASC
   ```

3. **Get ride members:**
   ```
   ride_members/{rideId}/members
   WHERE status == 'APPROVED'
   ORDER BY joinedAt ASC
   ```

4. **Get user's chats:**
   ```
   direct_chats
   WHERE participantIds array-contains {uid}
   WHERE status == 'APPROVED'
   ORDER BY updatedAt DESC
   ```

---

## Security Considerations

- Phone numbers stored ONLY in Firebase Auth, not in Firestore
- User UID is the single source of identity
- All timestamps use Firestore server timestamps
- Sensitive data (location history) not stored permanently
- Media URLs are signed URLs from Firebase Storage
