# QUICK START GUIDE

## 📱 Smart Event Check-in App - Get Running in 10 Minutes

### What You Need
- Flutter 3.11.1+
- Node.js 16+
- MongoDB (local or Atlas)
- Text editor / IDE

---

## STEP 1: Start MongoDB (2 min)

### Option A: Local MongoDB
```bash
# Windows: Download from https://www.mongodb.com/try/download/community
# After install, MongoDB runs as a service automatically

# Verify it's running:
# Open Command Prompt and try to connect:
# mongosh
```

### Option B: MongoDB Atlas (Cloud - Easier)
1. Go to https://www.mongodb.com/cloud/atlas
2. Create free account
3. Create cluster (takes ~3 min)
4. Get connection string
5. Copy to `.env` file later

---

## STEP 2: Start Backend API (3 min)

```bash
# Create backend folder
mkdir event-checkin-api
cd event-checkin-api

# Initialize Node project
npm init -y

# Install dependencies
npm install express mongoose bcryptjs jsonwebtoken cors dotenv
npm install --save-dev nodemon

# Create .env file
echo MONGODB_URI=mongodb://localhost:27017/event-checkin > .env
echo JWT_SECRET=your-secret-key >> .env
echo PORT=3000 >> .env

# Create server.js - copy from README_SETUP.md (the full backend code)

# Update package.json scripts
# Replace scripts section with:
# "scripts": {
#   "start": "node server.js",
#   "dev": "nodemon server.js"
# }

# Start backend
npm run dev
```

✅ **Backend should say:** `Server running on port 3000`

---

## STEP 3: Start Flutter App (5 min)

```bash
# Navigate to Flutter project
cd flutter_application_1

# Get dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```

**If it's your first time:**
```bash
# For Android Emulator
flutter emulators
flutter emulators launch Pixel_API_30  # or your emulator
flutter run

# For iOS Simulator (Mac only)
open -a Simulator
flutter run
```

---

## STEP 4: Test the App

### Create Account
1. App opens → Tap "Sign Up"
2. Enter:
   - Name: `John Organizer`
   - Email: `john@example.com`
   - Password: `password123`
3. Tap "Sign Up"

### Create Event
1. Tap "+" button
2. Enter:
   - Event Name: `Tech Conference 2024`
   - Maximum Capacity: `100`
   - Date & Time: Pick tomorrow
3. Tap "Create Event"

### Check In Participant
1. Tap on the event
2. In "Manual Entry" section:
   - Participant ID: `P001`
   - Tap "Check In Participant"
3. ✅ Success! You should see count update

### Try It Again
- Same participant ID → See "Duplicate entry" error ✓
- Try different IDs: `P002`, `P003`, etc.

### Search Check-ins
1. Tap search icon
2. Type `P001`
3. View full check-in history

---

## 🔧 Configuration Fixes

### If Backend Connection Fails

**In `lib/services/mongodb_service.dart`, line ~12:**

```dart
// CHANGE THIS:
static const String baseUrl = 'http://10.0.2.2:3000/api';

// TO YOUR IP IF USING PHYSICAL DEVICE:
// Find your IP: 
// Windows: ipconfig | find "IPv4"
// Mac/Linux: ifconfig | grep inet
static const String baseUrl = 'http://192.168.x.x:3000/api';
```

### If MongoDB Connection Fails

**In backend `.env`:**
```
# Try local first:
MONGODB_URI=mongodb://localhost:27017/event-checkin

# Or MongoDB Atlas:
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/event-checkin?retryWrites=true&w=majority
```

---

## 📋 File Structure Summary

```
Your Machine:
├── event-checkin-api/          (Backend - Node.js)
│   ├── server.js
│   ├── .env
│   └── package.json
│
└── flutter_application_1/       (Frontend - Flutter)
    ├── lib/
    │   ├── models/              (Data structures)
    │   ├── services/            (Business logic)
    │   ├── screens/             (UI pages)
    │   ├── widgets/             (Reusable components)
    │   └── main.dart
    ├── pubspec.yaml
    └── README_SETUP.md
```

---

## 🚀 First-Time Checklist

- [ ] MongoDB running
- [ ] Backend API running (port 3000)
- [ ] Flutter project dependencies installed
- [ ] Device/Emulator connected
- [ ] `flutter run` executed
- [ ] Signed up successfully
- [ ] Created first event
- [ ] Checked in a participant
- [ ] Saw duplicate error on re-check

---

## 💡 Common Issues & Fixes

| Issue | Solution |
|-------|----------|
| "Cannot connect to MongoDB" | Start MongoDB service / Check .env MONGODB_URI |
| "Network error on signup" | Verify backend running on port 3000 |
| "App crashes on launch" | `flutter clean` then `flutter pub get` |
| "Port 3000 already in use" | `lsof -i :3000` (Mac/Linux) or use different port |
| "API endpoint not found" | Check baseUrl in mongodb_service.dart |
| "No events showing" | Sync data button or reload app |

---

## 📱 Test Offline Mode

1. **Turn off WiFi/Mobile data**
2. **Try check-in** → Works! Saved locally ✓
3. **Turn data back on**
4. **Tap sync button** → Uploads to server ✓

---

## 🎯 Next Steps

- Export to APK: `flutter build apk --release`
- Deploy backend to Heroku/AWS
- Add more features (QR code, email reports, etc.)
- Customize styling

---

## 📞 Need Help?

1. Check logs: `flutter logs`
2. Verify API: Open browser → `http://localhost:3000`
3. Check MongoDB: Open `mongosh` and run `show dbs`
4. Review full setup: See `README_SETUP.md`

---

**Happy Building! 🎉**

Last updated: May 6, 2026
