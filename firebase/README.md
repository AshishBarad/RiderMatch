# Firebase Backend - README

## Overview

Complete Firebase backend for RiderMatch motorcycle ride matching application.

## 📁 Directory Structure

```
firebase/
├── functions/                  # Cloud Functions
│   ├── src/
│   │   ├── index.ts           # Main exports
│   │   ├── rides.ts           # Ride management functions
│   │   ├── social.ts          # Follow/unfollow functions
│   │   ├── chat.ts            # Chat system functions
│   │   ├── scheduled.ts       # Cron jobs
│   │   ├── api.ts             # HTTP endpoints
│   │   └── notifications.ts   # FCM utilities
│   ├── package.json
│   └── tsconfig.json
├── firestore.rules            # Firestore security rules
├── storage.rules              # Storage security rules
├── firestore.indexes.json     # Composite indexes
├── firebase.json              # Firebase configuration
├── FIRESTORE_SCHEMA.md        # Database schema docs
├── EMULATOR_SETUP.md          # Local development guide
├── DEPLOYMENT_GUIDE.md        # Production deployment
├── API_DOCUMENTATION.md       # API reference
└── README.md                  # This file
```

## 🚀 Quick Start

### 1. Install Dependencies

```bash
cd functions
npm install
```

### 2. Start Emulators

```bash
firebase emulators:start
```

### 3. Access Emulator UI

Open http://localhost:4000

## 📚 Documentation

- **[Firestore Schema](./FIRESTORE_SCHEMA.md)**: Complete database design
- **[Emulator Setup](./EMULATOR_SETUP.md)**: Local development guide
- **[Deployment Guide](./DEPLOYMENT_GUIDE.md)**: Production deployment
- **[API Documentation](./API_DOCUMENTATION.md)**: API reference

## 🔥 Firebase Services Used

- **Authentication**: Phone OTP + Google OAuth
- **Firestore**: Primary database with real-time sync
- **Storage**: Profile images, ride media
- **Cloud Functions**: Backend logic (Node.js 18)
- **Cloud Messaging**: Push notifications
- **Cloud Scheduler**: Automated tasks

## 🏗️ Architecture Highlights

### Database Design
- Optimized for low reads with denormalized counters
- Geolocation support with GeoHash indexing
- Real-time listeners for live updates
- Composite indexes for complex queries

### Cloud Functions
- **Triggers**: Auto-execute on Firestore changes
- **Scheduled**: Hourly ride completion, daily cleanup
- **HTTP**: REST API endpoints
- **Modular**: Organized by feature (rides, social, chat)

### Security
- Granular Firestore rules per collection
- Storage rules with file type/size validation
- Authentication required for all operations
- Owner-only write access for user data

## 🔒 Security Rules

### Firestore
- Users: Owner-only write, public read
- Rides: Creator edit, manager approve members
- Chats: Participants only
- Media: Members upload, public view for public rides

### Storage
- Profile images: Owner upload only (5MB limit)
- Ride media: Members upload only (50MB limit)
- File type validation (images/videos only)

## 📊 Key Collections

| Collection | Purpose | Access |
|------------|---------|--------|
| `users` | User profiles | Public read, owner write |
| `rides` | Ride information | Public/members read, creator write |
| `ride_members` | Ride participants | Members read, creator approve |
| `direct_chats` | P2P conversations | Participants only |
| `chat_messages` | Chat messages | Participants only |
| `follows` | Social graph | Public read, owner write |

## 🔔 Notifications

### FCM Topics
- `user_{uid}`: Per-user notifications
- `ride_{rideId}`: Ride-specific updates

### Notification Types
- `NEW_RIDE`: Follower created a ride
- `RIDE_JOIN_REQUEST`: Someone wants to join
- `RIDE_JOIN_APPROVED`: Request approved
- `CHAT_MESSAGE`: New direct message
- `NEW_FOLLOWER`: Someone followed you
- `RIDE_COMPLETED`: Ride finished

## ⚡ Performance

### Optimizations
- Denormalized counters (followers, rides)
- Composite indexes for common queries
- Batched writes for atomic operations
- Pagination with `limit()` and `startAfter()`

### Expected Performance
- Firestore reads: <100ms
- Cloud Functions: <500ms cold start, <50ms warm
- Real-time updates: <200ms latency

## 💰 Cost Estimates

**For 10,000 active users/month:**
- Firestore: ~$20-30
- Cloud Functions: ~$10-15
- Storage: ~$5-10
- FCM: Free
- **Total**: ~$35-55/month

## 🧪 Testing

### Unit Tests
```bash
cd functions
npm test
```

### Integration Tests
```bash
firebase emulators:exec --only firestore,functions "npm test"
```

### Manual Testing
Use Emulator UI at http://localhost:4000

## 🐛 Debugging

### View Logs
```bash
# Emulator logs
firebase emulators:start

# Production logs
firebase functions:log
```

### Common Issues
- **Port conflicts**: Change ports in `firebase.json`
- **Rules blocking**: Check Emulator UI Rules tab
- **Function errors**: Check logs for stack traces

## 📦 Deployment

### Development
```bash
firebase use dev
firebase deploy
```

### Production
```bash
firebase use prod
firebase deploy --only functions,firestore,storage
```

See [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) for details.

## 🔄 CI/CD

Recommended GitHub Actions workflow:

```yaml
name: Deploy to Firebase
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
      - run: cd functions && npm ci && npm run build
      - uses: w9jds/firebase-action@master
        with:
          args: deploy --only functions
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
```

## 📝 Contributing

1. Create feature branch
2. Test locally with emulators
3. Update documentation
4. Submit pull request

## 🆘 Support

- **Documentation**: See `/firebase/*.md` files
- **Issues**: Check function logs
- **Firebase Support**: https://firebase.google.com/support

## 📄 License

Proprietary - RiderMatch Application

---

**Built with ❤️ using Firebase**
