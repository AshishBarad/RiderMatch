# Firebase Production Deployment Guide

## Prerequisites

- Firebase CLI installed
- Access to Firebase project
- Production Firebase project created

## Pre-Deployment Checklist

### 1. Environment Setup

Create production Firebase project:
```bash
firebase projects:create ridermatch-prod
```

### 2. Configure Project

```bash
# Select production project
firebase use ridermatch-prod

# Or add as alias
firebase use --add
# Select project and name it 'prod'
```

### 3. Enable Required Services

In Firebase Console (https://console.firebase.google.com):

- ✅ **Authentication**
  - Enable Phone authentication
  - Enable Google Sign-In
  - Configure OAuth consent screen

- ✅ **Firestore Database**
  - Create database in production mode
  - Select region (e.g., us-central1)

- ✅ **Storage**
  - Create default bucket
  - Select region

- ✅ **Cloud Functions**
  - Upgrade to Blaze plan (pay-as-you-go)

- ✅ **Cloud Messaging**
  - Enable FCM
  - Download google-services.json (Android)
  - Download GoogleService-Info.plist (iOS)

## Deployment Steps

### 1. Build Cloud Functions

```bash
cd functions
npm run build
```

### 2. Deploy Firestore Rules

```bash
firebase deploy --only firestore:rules
```

### 3. Deploy Firestore Indexes

```bash
firebase deploy --only firestore:indexes
```

### 4. Deploy Storage Rules

```bash
firebase deploy --only storage
```

### 5. Deploy Cloud Functions

```bash
# Deploy all functions
firebase deploy --only functions

# Or deploy specific function
firebase deploy --only functions:onRideJoinRequest
```

### 6. Verify Deployment

```bash
# Check function URLs
firebase functions:list

# View logs
firebase functions:log
```

## Post-Deployment Configuration

### 1. Configure Function Environment Variables

```bash
firebase functions:config:set \
  app.region="us-central1" \
  app.timezone="Asia/Kolkata"
```

### 2. Set Up Scheduled Functions

Scheduled functions are automatically deployed with Cloud Scheduler.

Verify in Cloud Console:
- Go to Cloud Scheduler
- Check `completeRidesScheduler` (runs hourly)
- Check `cleanupOldDataScheduler` (runs daily)

### 3. Configure CORS for API

In `functions/src/api.ts`, update CORS settings:

```typescript
app.use(cors({
  origin: [
    'https://your-app-domain.com',
    'https://your-admin-panel.com'
  ],
  credentials: true
}));
```

### 4. Set Up FCM

1. Download server key from Firebase Console
2. Configure in Flutter app:

```dart
// Add to android/app/google-services.json
// Add to ios/Runner/GoogleService-Info.plist
```

## Security Hardening

### 1. Review Security Rules

```bash
# Test rules locally first
firebase emulators:start --only firestore

# Then deploy
firebase deploy --only firestore:rules
```

### 2. Enable App Check

```bash
firebase appcheck:update --app-id=YOUR_APP_ID
```

### 3. Set Up Budget Alerts

In Google Cloud Console:
- Billing → Budgets & alerts
- Set monthly budget limit
- Configure email alerts

## Monitoring & Logging

### 1. Enable Cloud Logging

Functions automatically log to Cloud Logging.

View logs:
```bash
firebase functions:log --only onRideJoinRequest
```

### 2. Set Up Error Reporting

In Cloud Console:
- Error Reporting
- View function errors

### 3. Configure Alerts

Set up alerts for:
- Function failures
- High latency
- Quota exceeded

## Performance Optimization

### 1. Function Memory Allocation

Update function memory in `firebase.json`:

```json
{
  "functions": {
    "runtime": "nodejs18",
    "memory": "256MB",
    "timeoutSeconds": 60
  }
}
```

### 2. Cold Start Optimization

- Keep functions warm with scheduled pings
- Minimize dependencies
- Use function bundling

### 3. Database Optimization

- Verify all indexes are created
- Monitor query performance
- Use denormalized data where appropriate

## Rollback Procedure

If deployment fails:

```bash
# List previous deployments
firebase functions:list

# Rollback to previous version
firebase rollback functions:onRideJoinRequest
```

## Cost Management

### Expected Costs (Approximate)

**Firestore**:
- Reads: $0.06 per 100K
- Writes: $0.18 per 100K
- Storage: $0.18 per GB/month

**Cloud Functions**:
- Invocations: $0.40 per million
- Compute time: $0.0000025 per GB-second

**Storage**:
- Storage: $0.026 per GB/month
- Downloads: $0.12 per GB

**FCM**: Free

### Cost Optimization Tips

1. Use Firestore offline persistence
2. Batch writes when possible
3. Implement pagination
4. Cache frequently accessed data
5. Use Cloud Functions efficiently

## Backup Strategy

### 1. Automated Backups

```bash
# Schedule daily Firestore exports
gcloud firestore export gs://your-backup-bucket
```

### 2. Manual Backup

```bash
# Export Firestore data
firebase firestore:export backup-$(date +%Y%m%d)
```

## Deployment Checklist

- [ ] All tests passing
- [ ] Security rules reviewed
- [ ] Indexes configured
- [ ] Environment variables set
- [ ] CORS configured
- [ ] FCM set up
- [ ] Monitoring enabled
- [ ] Budget alerts configured
- [ ] Backup strategy in place
- [ ] Documentation updated

## Production URLs

After deployment, your endpoints will be:

```
https://us-central1-ridermatch-prod.cloudfunctions.net/api/rides/nearby
https://us-central1-ridermatch-prod.cloudfunctions.net/api/rides/create
...
```

## Support & Troubleshooting

### Common Issues

**Issue**: Function deployment fails
- Check Node.js version (must be 18)
- Verify billing is enabled
- Check function logs for errors

**Issue**: Security rules blocking requests
- Test rules in Firestore Rules Playground
- Check authentication status
- Verify user permissions

**Issue**: High costs
- Review Cloud Console billing
- Check for infinite loops
- Optimize queries

### Getting Help

- Firebase Documentation: https://firebase.google.com/docs
- Stack Overflow: Tag `firebase`
- Firebase Support: https://firebase.google.com/support

## Next Steps

1. ✅ Deploy to production
2. ✅ Test all endpoints
3. ✅ Monitor for 24 hours
4. ✅ Set up CI/CD pipeline
5. 🚀 Launch to users!
