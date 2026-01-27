# Firebase Hosting Deployment Guide - RiderMatch

## Overview

This guide walks you through deploying your RiderMatch application to Firebase, including backend (Cloud Functions) and Flutter app distribution.

---

## 🎯 Deployment Strategy

### What We'll Deploy

1. **Backend Services** (Firebase)
   - Cloud Functions
   - Firestore Database
   - Storage Rules
   - Security Rules

2. **Flutter App** (App Distribution)
   - iOS App (TestFlight/App Store)
   - Android App (Play Store/Firebase App Distribution)

---

## 📋 Prerequisites

### Required Tools

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Verify installations
firebase --version
flutterfire --version
flutter --version
```

### Required Accounts

- ✅ Google Account (for Firebase Console)
- ✅ Apple Developer Account (for iOS - $99/year)
- ✅ Google Play Developer Account (for Android - $25 one-time)

---

## 🚀 Step-by-Step Deployment

### Phase 1: Firebase Project Setup (15 minutes)

#### 1.1 Create Firebase Project

```bash
# Login to Firebase
firebase login

# Create new project
firebase projects:create ridermatch-prod

# Select the project
cd /path/to/rider_match/firebase
firebase use ridermatch-prod
```

Or create via Firebase Console:
1. Go to https://console.firebase.google.com
2. Click "Add project"
3. Name: "RiderMatch Production"
4. Enable Google Analytics (recommended)
5. Click "Create project"

#### 1.2 Enable Firebase Services

In Firebase Console, enable:

**Authentication:**
- Go to Authentication → Sign-in method
- Enable "Phone" authentication
- Enable "Google" authentication
- Configure OAuth consent screen

**Firestore Database:**
- Go to Firestore Database
- Click "Create database"
- Start in **production mode**
- Choose location: `asia-south1` (Mumbai) or `us-central1`

**Storage:**
- Go to Storage
- Click "Get started"
- Start in **production mode**
- Use default bucket

**Cloud Functions:**
- Upgrade to **Blaze Plan** (pay-as-you-go)
- Go to Functions → Get started

**Cloud Messaging:**
- Go to Project Settings → Cloud Messaging
- Enable Cloud Messaging API

---

### Phase 2: Backend Deployment (20 minutes)

#### 2.1 Install Dependencies

```bash
cd firebase/functions
npm install
```

#### 2.2 Build Functions

```bash
npm run build
```

#### 2.3 Deploy Firestore Rules & Indexes

```bash
# From firebase directory
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

Wait for indexes to build (check Firebase Console → Firestore → Indexes)

#### 2.4 Deploy Storage Rules

```bash
firebase deploy --only storage
```

#### 2.5 Deploy Cloud Functions

```bash
# Deploy all functions
firebase deploy --only functions

# Or deploy incrementally (safer for first deployment)
firebase deploy --only functions:onRideJoinRequest
firebase deploy --only functions:onRideJoinApproved
firebase deploy --only functions:onRideCreated
firebase deploy --only functions:onFollowUser
firebase deploy --only functions:onUnfollowUser
firebase deploy --only functions:onChatMessage
firebase deploy --only functions:onChatRequestApproved
firebase deploy --only functions:completeRidesScheduler
firebase deploy --only functions:cleanupOldDataScheduler
firebase deploy --only functions:api
```

#### 2.6 Verify Deployment

```bash
# List deployed functions
firebase functions:list

# Check function URLs
# Your API will be at:
# https://us-central1-ridermatch-prod.cloudfunctions.net/api
```

---

### Phase 3: Flutter App Configuration (30 minutes)

#### 3.1 Add Firebase to Flutter

```bash
# From project root
cd /path/to/rider_match

# Configure Firebase for Flutter
flutterfire configure --project=ridermatch-prod
```

This will:
- Create `firebase_options.dart`
- Download `google-services.json` (Android)
- Download `GoogleService-Info.plist` (iOS)

#### 3.2 Add Firebase Dependencies

Update `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.6.0
  firebase_messaging: ^14.7.10
  firebase_analytics: ^10.8.0
```

Run:
```bash
flutter pub get
```

#### 3.3 Initialize Firebase in Flutter

Update `lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}
```

#### 3.4 Configure Android

**`android/app/build.gradle`:**

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Required for Firebase
        multiDexEnabled true
    }
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
}
```

**`android/build.gradle`:**

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

**`android/app/build.gradle` (bottom):**

```gradle
apply plugin: 'com.google.gms.google-services'
```

#### 3.5 Configure iOS

**`ios/Podfile`:**

```ruby
platform :ios, '13.0'  # Minimum for Firebase
```

Run:
```bash
cd ios
pod install
cd ..
```

---

### Phase 4: Build & Test (20 minutes)

#### 4.1 Test Firebase Connection

Create a test file `lib/test_firebase.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> testFirebaseConnection() async {
  try {
    // Test Firestore
    final doc = await FirebaseFirestore.instance
        .collection('test')
        .doc('connection')
        .get();
    
    print('✅ Firebase connected successfully!');
  } catch (e) {
    print('❌ Firebase connection failed: $e');
  }
}
```

#### 4.2 Build Release APK (Android)

```bash
# Build release APK
flutter build apk --release

# Or build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Output: build/app/outputs/flutter-apk/app-release.apk
# Or: build/app/outputs/bundle/release/app-release.aab
```

#### 4.3 Build iOS App

```bash
# Build iOS
flutter build ios --release

# Or build for archive
flutter build ipa
```

---

### Phase 5: App Distribution (30 minutes)

#### Option A: Firebase App Distribution (Beta Testing)

**For Android:**

```bash
# Install Firebase App Distribution plugin
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_ANDROID_APP_ID \
  --groups "testers" \
  --release-notes "Initial beta release"
```

**For iOS:**

```bash
firebase appdistribution:distribute build/ios/ipa/RiderMatch.ipa \
  --app YOUR_IOS_APP_ID \
  --groups "testers" \
  --release-notes "Initial beta release"
```

#### Option B: Google Play Store (Android)

1. **Create Play Console Account**
   - Go to https://play.google.com/console
   - Pay $25 one-time fee

2. **Create App**
   - Click "Create app"
   - Fill in app details
   - Upload screenshots, description

3. **Upload App Bundle**
   - Go to Production → Create new release
   - Upload `app-release.aab`
   - Fill in release notes
   - Submit for review

#### Option C: Apple App Store (iOS)

1. **Create App Store Connect Account**
   - Go to https://appstoreconnect.apple.com
   - Pay $99/year

2. **Create App**
   - Click "My Apps" → "+"
   - Fill in app information
   - Upload screenshots

3. **Upload via Xcode**
   - Open `ios/Runner.xcworkspace` in Xcode
   - Product → Archive
   - Distribute App → App Store Connect
   - Upload

---

### Phase 6: Post-Deployment Setup (15 minutes)

#### 6.1 Configure FCM for Push Notifications

**Android:**
- Already configured via `google-services.json`

**iOS:**
1. Upload APNs certificate to Firebase Console
2. Go to Project Settings → Cloud Messaging → iOS
3. Upload APNs Authentication Key

#### 6.2 Set Up Cloud Scheduler

Verify scheduled functions are running:
- Go to Cloud Console → Cloud Scheduler
- Check `completeRidesScheduler` (hourly)
- Check `cleanupOldDataScheduler` (daily)

#### 6.3 Configure Budget Alerts

1. Go to Google Cloud Console → Billing
2. Set up budget alerts
3. Recommended: $50/month for testing, $200/month for production

#### 6.4 Enable Monitoring

1. Go to Firebase Console → Analytics
2. Enable crash reporting
3. Set up performance monitoring

---

## 🔒 Security Checklist

Before going live:

- [ ] Security rules deployed and tested
- [ ] API keys restricted (Firebase Console → Project Settings)
- [ ] OAuth consent screen configured
- [ ] App Check enabled (optional but recommended)
- [ ] HTTPS only for all endpoints
- [ ] Environment variables secured
- [ ] Backup strategy in place

---

## 📊 Monitoring & Maintenance

### Daily Checks

```bash
# View function logs
firebase functions:log --only onRideJoinRequest

# Check for errors
firebase crashlytics:reports
```

### Weekly Tasks

- Review Cloud Console billing
- Check function performance
- Monitor Firestore usage
- Review crash reports

---

## 💰 Expected Costs

**For 1,000 active users/month:**

| Service | Cost |
|---------|------|
| Firestore | $5-10 |
| Cloud Functions | $3-5 |
| Storage | $2-3 |
| FCM | Free |
| Hosting | $0 (using App Distribution) |
| **Total** | **$10-18/month** |

**For 10,000 active users/month:** ~$50-80/month

---

## 🐛 Troubleshooting

### Common Issues

**Issue: Functions deployment fails**
```bash
# Solution: Check Node.js version
node --version  # Should be 18.x

# Rebuild
cd functions
npm run build
```

**Issue: App can't connect to Firestore**
```bash
# Solution: Verify firebase_options.dart exists
# Re-run: flutterfire configure
```

**Issue: iOS build fails**
```bash
# Solution: Clean and reinstall pods
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter build ios
```

---

## 🚀 Quick Deployment Commands

```bash
# Complete deployment in one go
cd firebase

# 1. Deploy backend
firebase deploy --only firestore,storage,functions

# 2. Build Flutter apps
cd ..
flutter build apk --release
flutter build ios --release

# 3. Distribute
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_APP_ID --groups "testers"
```

---

## 📱 App Store Submission Checklist

### Google Play Store

- [ ] App bundle built (`app-release.aab`)
- [ ] Screenshots (phone + tablet)
- [ ] Feature graphic (1024x500)
- [ ] App icon (512x512)
- [ ] Privacy policy URL
- [ ] Content rating questionnaire
- [ ] Target audience selected

### Apple App Store

- [ ] IPA built and uploaded
- [ ] Screenshots (all device sizes)
- [ ] App icon (1024x1024)
- [ ] Privacy policy URL
- [ ] App description (4000 chars max)
- [ ] Keywords
- [ ] Support URL

---

## ✅ Final Checklist

- [ ] Firebase project created
- [ ] All Firebase services enabled
- [ ] Cloud Functions deployed
- [ ] Firestore rules deployed
- [ ] Storage rules deployed
- [ ] Flutter app configured
- [ ] Android app built
- [ ] iOS app built
- [ ] FCM configured
- [ ] Monitoring enabled
- [ ] Budget alerts set
- [ ] App distributed to testers
- [ ] Store listings created
- [ ] Privacy policy published

---

## 🎉 You're Live!

Once all steps are complete:
1. Test the app thoroughly
2. Gather beta tester feedback
3. Fix any issues
4. Submit to app stores
5. Launch! 🚀

---

**Need Help?**
- Firebase Support: https://firebase.google.com/support
- Flutter Docs: https://docs.flutter.dev
- Stack Overflow: Tag `firebase` + `flutter`
