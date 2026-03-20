# Firebase Credentials Quick Reference

## What You Need to Gather

Before updating `lib/firebase_options.dart`, collect these values from your Firebase project:

### Finding Your Credentials

#### 1. Project ID
**Location:** Firebase Console → Project Settings → General
**Looks like:** `my-gym-app-12345`
**Used in:**
- `projectId` field
- Database URL: `https://my-gym-app-12345.firebasedatabase.app`
- Storage bucket: `my-gym-app-12345.appspot.com`

#### 2. Project Number
**Location:** Firebase Console → Project Settings → General
**Looks like:** `123456789012`
**Used in:**
- `messagingSenderId` field
- App IDs (first part): `1:123456789012:android:...`

#### 3. API Keys (Android)
**Location:** Firebase Console → Project Settings → Service Accounts → App → Android
**Or:** Download `google-services.json` from Firebase Console
**Used in:**
- `apiKey` field for Android

#### 4. API Keys (iOS)
**Location:** Firebase Console → Project Settings → Service Accounts → App → iOS
**Or:** Download `GoogleService-Info.plist` from Firebase Console
**Used in:**
- `apiKey` field for iOS

#### 5. App IDs
**Location:** Each app registration in Firebase Console
**Android:** `1:PROJECT_NUMBER:android:FINGERPRINT_HASH`
**iOS:** `1:PROJECT_NUMBER:ios:APP_ID`
**Used in:**
- `appId` field for each platform

#### 6. Database URL
**Location:** Firebase Console → Realtime Database → Connection details
**Looks like:** `https://my-gym-app-12345.firebasedatabase.app`
**Used in:**
- `databaseURL` field

#### 7. Storage Bucket
**Location:** Firebase Console → Cloud Storage → Bucket (or auto-generated)
**Looks like:** `my-gym-app-12345.appspot.com`
**Used in:**
- `storageBucket` field

---

## Step-by-Step Configuration

### Step 1: Update Android Credentials
```dart
// In lib/firebase_options.dart, update:
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSyD...',                    // From google-services.json
  appId: '1:123456789012:android:abc1234', // From google-services.json
  messagingSenderId: '123456789012',       // Your project number
  projectId: 'my-gym-app-12345',           // From Firebase Console
  databaseURL: 'https://my-gym-app-12345.firebasedatabase.app',
  storageBucket: 'my-gym-app-12345.appspot.com',
);
```

### Step 2: Update iOS Credentials
```dart
// In lib/firebase_options.dart, update:
static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'AIzaSyK...',                   // From GoogleService-Info.plist
  appId: '1:123456789012:ios:def5678',    // From GoogleService-Info.plist
  messagingSenderId: '123456789012',      // Your project number
  projectId: 'my-gym-app-12345',          // From Firebase Console
  databaseURL: 'https://my-gym-app-12345.firebasedatabase.app',
  storageBucket: 'my-gym-app-12345.appspot.com',
  iosBundleId: 'com.example.personalGymLogApp',  // Your iOS bundle ID
);
```

---

## Finding Values in Different Places

### From google-services.json (Android)
```json
{
  "project_info": {
    "project_number": "123456789012",           // → messagingSenderId
    "project_id": "my-gym-app-12345",          // → projectId
    "storage_bucket": "my-gym-app-12345.appspot.com"  // → storageBucket
  },
  "client": [
    {
      "client_info": {
        "client_id": "1:123456789012:android:abc123", // → appId
        "client_type": 1
      },
      "api_key": [
        {
          "current_key": "AIzaSyD..."  // → apiKey
        }
      ]
    }
  ]
}
```

### From GoogleService-Info.plist (iOS)
```xml
<key>PROJECT_ID</key>
<string>my-gym-app-12345</string>           <!-- → projectId -->

<key>PROJECT_NUMBER</key>
<string>123456789012</string>               <!-- → messagingSenderId -->

<key>GOOGLE_APP_ID</key>
<string>1:123456789012:ios:def5678</string> <!-- → appId -->

<key>API_KEY</key>
<string>AIzaSyK...</string>                 <!-- → apiKey -->

<key>STORAGE_BUCKET</key>
<string>my-gym-app-12345.appspot.com</string> <!-- → storageBucket -->

<key>DATABASE_URL</key>
<string>https://my-gym-app-12345.firebasedatabase.app</string> <!-- → databaseURL -->
```

---

## Common Issues

❌ **"Project ID is null"**
→ Make sure you filled `projectId` field, not left empty

❌ **"API Key is invalid"**
→ Copy the ENTIRE key string, including any dashes or underscores

❌ **"Database URL not found"**
→ Go to Firebase Console → Realtime Database → Connection details

❌ **iOS Bundle ID mismatch**
→ Check your actual iOS bundle ID in Xcode → General tab

---

## Before You Start

✅ You have created a Firebase project
✅ You have enabled Realtime Database
✅ You have Android / iOS apps registered
✅ You have downloaded google-services.json and/or GoogleService-Info.plist

If you haven't done these, go to [Firebase Console](https://console.firebase.google.com) and complete setup first.

---

## After Updating firebase_options.dart

1. Run `flutter clean`
2. Run `flutter pub get`
3. Run `flutter run` (or build for Android/iOS)
4. Check console for Firebase initialization message
5. Try adding a template
6. Check Firebase Console → Realtime Database for data

Good luck! 🚀
