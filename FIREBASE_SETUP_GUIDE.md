# Firebase Setup Guide

This guide explains how to configure Firebase credentials for the Personal Gym Log App.

## Overview

The app is now configured with Firebase Realtime Database integration. Templates and workout logs are:
- **Stored locally** in Hive database for offline access
- **Automatically synced** to Firebase when online
- **Downloaded from Firebase** and merged with local data

## Configuration Steps

### 1. Get Your Firebase Credentials

1. Go to your [Firebase Console](https://console.firebase.google.com)
2. Select your project (or create a new one)
3. Navigate to **Project Settings** → **General**
4. Find your project credentials:
   - **Project ID**: Shows as `projectId`
   - **Web API Key**: Under "Web API Key"
   - **Database URL**: Under "Realtime Database" → Connection details

### 2. Update firebase_options.dart

Edit `lib/firebase_options.dart` and replace the placeholder values:

**For Android:**
```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY',           // From Google Services or Firebase Console
  appId: '1:YOUR_PROJECT_NUMBER:android:YOUR_ANDROID_APP_ID',  // From google-services.json
  messagingSenderId: 'YOUR_PROJECT_NUMBER',  // Your Firebase Project Number
  projectId: 'YOUR_PROJECT_ID',              // e.g., 'my-gym-app-12345'
  databaseURL: 'https://YOUR_PROJECT_ID.firebasedatabase.app',  // e.g., 'https://my-gym-app-12345.firebasedatabase.app'
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
);
```

**For iOS:**
```dart
static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'YOUR_IOS_API_KEY',              // From GoogleService-Info.plist
  appId: '1:YOUR_PROJECT_NUMBER:ios:YOUR_IOS_APP_ID',  // From GoogleService-Info.plist
  messagingSenderId: 'YOUR_PROJECT_NUMBER',
  projectId: 'YOUR_PROJECT_ID',
  databaseURL: 'https://YOUR_PROJECT_ID.firebasedatabase.app',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  iosBundleId: 'com.example.personalGymLogApp',
);
```

### 3. Set Up Realtime Database Rules

In Firebase Console, go to **Realtime Database** → **Rules** and set:

```json
{
  "rules": {
    "users": {
      "$uid": {
        "templates": {
          ".read": "auth != null || !root.exists()",
          ".write": "auth != null || !root.exists()"
        },
        "workoutLogs": {
          ".read": "auth != null || !root.exists()",
          ".write": "auth != null || !root.exists()"
        }
      }
    }
  }
}
```

> **Note**: These rules allow unauthenticated access for testing. For production, implement proper authentication.

### 4. Configure Google Services Files

#### For Android:
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/`
3. The build process will automatically use it

#### For iOS:
1. Download `GoogleService-Info.plist` from Firebase Console
2. Add it to Xcode project under `ios/Runner/`

### 5. Update main.dart (If Not Already Done)

The app initialization already includes:
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

This is automatically called in `lib/main.dart`.

## How It Works

### Automatic Synchronization

When you add a template via "Add to Template" button:

1. ✅ Template is saved to **local Hive database** 
2. 🔄 Template is uploaded to **Firebase Realtime Database**
3. 📱 Data syncs in background when network is available

### Data Structure in Firebase

Templates and workout logs are stored in:
```
users/
  └── default_user/
      ├── templates/
      │   └── {template_id}.json
      └── workoutLogs/
          └── {log_id}.json
```

### Manual Sync Operations

You can manually trigger sync in your code:

```dart
// Access provider from context
final provider = Provider.of<WorkoutProvider>(context, listen: false);

// Download all from Firebase
await provider.syncFromFirebase();

// Upload all to Firebase
await provider.syncToFirebase();

// Check sync status
if (provider.isSyncing) {
  // Show loading indicator
}
```

## Testing

1. Add a template through the app
2. Check Firebase Console → Realtime Database to see if data appears
3. Clear local data and use `syncFromFirebase()` to verify download works
4. Restart app offline to confirm local data persists

## Troubleshooting

### Firebase Connection Fails
- ✅ Verify `firebase_options.dart` values match your Firebase project
- ✅ Check internet connection
- ✅ Verify Firebase Realtime Database is enabled
- ✅ Check database rules allow read/write

### No Data Appears in Firebase
- ✅ Check that _userId is set and non-empty
- ✅ Look at app logs: `print()` statements show sync status
- ✅ Verify database path: `users/{userId}/templates/`

### App Crashes on Start
- ✅ Ensure `firebase_options.dart` has valid credentials
- ✅ Check pubspec.yaml has firebase dependencies
- ✅ Run `flutter clean && flutter pub get`

## User ID Configuration

Currently, the app uses `'default_user'` as the user ID. This means all data is stored under one user.

**To use different users:**

In `lib/main.dart`, replace:
```dart
const defaultUserId = 'default_user';
```

With your authentication system:
```dart
// Example: use Firebase Auth
final user = FirebaseAuth.instance.currentUser;
FirebaseService().setUserId(user?.uid ?? 'default_user');
```

## Security Notes

⚠️ **For Production Apps:**
- Implement Firebase Authentication (Email, Google Sign-In, etc.)
- Never hardcode user IDs
- Use proper security rules and validation
- Enable Cloud Firestore security audits

## Next Steps

1. ✅ Update `firebase_options.dart` with your credentials
2. ✅ Download and configure `google-services.json` (Android) or `GoogleService-Info.plist` (iOS)
3. ✅ Set up Realtime Database rules in Firebase Console
4. ✅ Test by running the app and adding a template
5. ✅ Verify data appears in Firebase Console

For more help, see the [Firebase Documentation](https://firebase.google.com/docs/database/start).
