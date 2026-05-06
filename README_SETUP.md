# Smart Event Check-in & Crowd Management App

A Flutter-based mobile application for efficient participant check-in, real-time attendance tracking, and crowd management with offline-first functionality.

## Features

✅ **Event Management** - Create and manage events with capacity limits
✅ **Manual Check-in** - Enter participant ID manually for quick check-ins
✅ **Real-time Dashboard** - Monitor attendance and crowd capacity
✅ **Offline Functionality** - Works without internet, syncs when online
✅ **Duplicate Prevention** - Prevents multiple check-ins for same participant
✅ **Search & Logs** - Search participants and view check-in history
✅ **User Authentication** - Secure login and signup
✅ **Responsive UI** - Clean, intuitive interface

## Architecture

### Tech Stack
- **Frontend**: Flutter 3.11.1
- **State Management**: Provider
- **Local Database**: Hive (NoSQL)
- **Backend**: Node.js + Express (MongoDB API)
- **Authentication**: JWT
- **Connectivity**: Connectivity Plus

### Project Structure
```
lib/
├── models/              # Data models (User, Event, Participant, CheckIn)
├── services/            # Business logic services
│   ├── auth_service.dart
│   ├── mongodb_service.dart
│   ├── local_storage_service.dart
│   ├── sync_service.dart
│   └── connectivity_service.dart
├── screens/             # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── home_screen.dart
│   ├── create_event_screen.dart
│   ├── event_detail_screen.dart
│   └── search_logs_screen.dart
├── widgets/             # Reusable widgets
│   └── crowd_status_indicator.dart
└── main.dart
```

## Setup Instructions

### 1. Frontend Setup (Flutter)

#### Prerequisites
- Flutter 3.11.1+ installed
- Dart 3.11.1+ installed
- Android Studio or VS Code with Flutter extension

#### Installation
```bash
cd flutter_application_1
flutter pub get
flutter run
```

### 2. Backend Setup (Node.js + MongoDB)

#### Prerequisites
- Node.js 16+ installed
- MongoDB installed locally (or MongoDB Atlas account)
- npm or yarn

#### Create Backend API

Create a new Node.js project:

```bash
mkdir event-checkin-api
cd event-checkin-api
npm init -y
npm install express mongoose bcryptjs jsonwebtoken cors dotenv
npm install --save-dev nodemon
```

Create `.env` file:
```
MONGODB_URI=mongodb://localhost:27017/event-checkin
JWT_SECRET=your-secret-key-here
PORT=3000
NODE_ENV=development
```

Create `server.js`:

```javascript
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// MongoDB Connection
mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
}).then(() => console.log('MongoDB connected'))
  .catch(err => console.log(err));

// User Schema
const userSchema = new mongoose.Schema({
  name: String,
  email: { type: String, unique: true },
  password: String,
  role: { type: String, enum: ['organizer', 'admin'] },
  createdAt: { type: Date, default: Date.now }
});

// Event Schema
const eventSchema = new mongoose.Schema({
  name: String,
  dateTime: Date,
  maxCapacity: Number,
  organizerId: String,
  createdAt: { type: Date, default: Date.now },
  synced: { type: Boolean, default: true }
});

// Participant Schema
const participantSchema = new mongoose.Schema({
  name: String,
  ticketId: String,
  eventId: String,
  createdAt: { type: Date, default: Date.now },
  synced: { type: Boolean, default: true }
});

// CheckIn Schema
const checkInSchema = new mongoose.Schema({
  participantId: String,
  eventId: String,
  checkedInAt: Date,
  status: String,
  errorMessage: String,
  synced: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now }
});

const User = mongoose.model('User', userSchema);
const Event = mongoose.model('Event', eventSchema);
const Participant = mongoose.model('Participant', participantSchema);
const CheckIn = mongoose.model('CheckIn', checkInSchema);

// Auth Routes
app.post('/api/auth/signup', async (req, res) => {
  try {
    const { email, password, name, role } = req.body;
    
    let user = await User.findOne({ email });
    if (user) {
      return res.status(400).json({ message: 'User already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    
    user = new User({
      name,
      email,
      password: hashedPassword,
      role: role || 'organizer'
    });

    await user.save();

    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET);

    res.status(201).json({
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role
      }
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET);

    res.json({
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role
      }
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Middleware to verify token
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) return res.sendStatus(401);

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
};

// Event Routes
app.post('/api/events', authenticateToken, async (req, res) => {
  try {
    const { name, dateTime, maxCapacity } = req.body;

    const event = new Event({
      name,
      dateTime,
      maxCapacity,
      organizerId: req.user.userId
    });

    await event.save();
    res.status(201).json(event);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

app.get('/api/events', authenticateToken, async (req, res) => {
  try {
    const events = await Event.find({ organizerId: req.user.userId });
    res.json(events);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

app.get('/api/events/:eventId', authenticateToken, async (req, res) => {
  try {
    const event = await Event.findById(req.params.eventId);
    if (!event) return res.status(404).json({ message: 'Event not found' });
    res.json(event);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

app.delete('/api/events/:eventId', authenticateToken, async (req, res) => {
  try {
    await Event.findByIdAndDelete(req.params.eventId);
    res.json({ message: 'Event deleted' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Participant Routes
app.post('/api/events/:eventId/participants', authenticateToken, async (req, res) => {
  try {
    const { participants } = req.body;

    const created = await Participant.insertMany(
      participants.map(p => ({
        ...p,
        eventId: req.params.eventId
      }))
    );

    res.status(201).json(created);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

app.get('/api/events/:eventId/participants', authenticateToken, async (req, res) => {
  try {
    const participants = await Participant.find({ eventId: req.params.eventId });
    res.json(participants);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// CheckIn Routes
app.post('/api/events/:eventId/checkin', authenticateToken, async (req, res) => {
  try {
    const { participantId } = req.body;
    const eventId = req.params.eventId;

    // Check if already checked in
    const existingCheckIn = await CheckIn.findOne({
      participantId,
      eventId,
      status: 'success'
    });

    if (existingCheckIn) {
      return res.status(400).json({
        message: 'Participant already checked in',
        status: 'duplicate'
      });
    }

    // Check capacity
    const checkInCount = await CheckIn.countDocuments({
      eventId,
      status: 'success'
    });

    const event = await Event.findById(eventId);
    if (checkInCount >= event.maxCapacity) {
      return res.status(400).json({
        message: 'Event is full',
        status: 'full'
      });
    }

    // Create check-in
    const checkIn = new CheckIn({
      participantId,
      eventId,
      checkedInAt: new Date(),
      status: 'success'
    });

    await checkIn.save();
    res.status(200).json(checkIn);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

app.get('/api/events/:eventId/checkins', authenticateToken, async (req, res) => {
  try {
    const checkIns = await CheckIn.find({ eventId: req.params.eventId });
    res.json(checkIns);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

app.post('/api/events/:eventId/sync-checkins', authenticateToken, async (req, res) => {
  try {
    const { checkIns } = req.body;

    const results = await Promise.all(
      checkIns.map(async (ci) => {
        const existingCheckIn = await CheckIn.findOne({
          participantId: ci.participantId,
          eventId: req.params.eventId,
          status: 'success'
        });

        if (existingCheckIn) {
          return { ...ci, synced: true };
        }

        const checkIn = new CheckIn({
          participantId: ci.participantId,
          eventId: req.params.eventId,
          checkedInAt: ci.checkedInAt,
          status: ci.status,
          synced: true
        });

        await checkIn.save();
        return checkIn;
      })
    );

    res.json({ message: 'Sync completed', data: results });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

app.get('/api/events/:eventId/stats', authenticateToken, async (req, res) => {
  try {
    const checkInCount = await CheckIn.countDocuments({
      eventId: req.params.eventId,
      status: 'success'
    });

    const event = await Event.findById(req.params.eventId);

    res.json({
      totalCapacity: event.maxCapacity,
      checkedIn: checkInCount,
      remaining: event.maxCapacity - checkInCount
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

Update `package.json` scripts:
```json
"scripts": {
  "start": "node server.js",
  "dev": "nodemon server.js"
}
```

#### Run Backend
```bash
npm run dev
```

The API will be available at `http://localhost:3000`

### 3. MongoDB Setup

#### Local MongoDB

```bash
# Install MongoDB Community Edition
# Windows: https://docs.mongodb.com/manual/tutorial/install-mongodb-on-windows/
# Mac: brew install mongodb-community
# Linux: apt-get install mongodb

# Start MongoDB service
mongod
```

#### Or Use MongoDB Atlas (Cloud)

1. Go to https://www.mongodb.com/cloud/atlas
2. Create a free account
3. Create a cluster
4. Get connection string
5. Update `.env`: `MONGODB_URI=your-atlas-connection-string`

## Configuration

### Update API Endpoint

In `lib/services/mongodb_service.dart`, update the `baseUrl`:

```dart
// For local development (Android Emulator)
static const String baseUrl = 'http://10.0.2.2:3000/api';

// For physical device
static const String baseUrl = 'http://YOUR_MACHINE_IP:3000/api';

// For iOS simulator
static const String baseUrl = 'http://localhost:3000/api';
```

## Usage

### 1. Launch the App
```bash
flutter run
```

### 2. Create an Account
- Sign up with email and password
- Or login if you already have an account

### 3. Create an Event
- Tap the "+" button on home screen
- Enter event details (name, date/time, capacity)
- Save event

### 4. Check in Participants
- Open an event from the dashboard
- Enter participant ID in the input field
- Tap "Check In Participant"
- System prevents duplicates and enforces capacity limits

### 5. Monitor Crowd
- View real-time attendance on the dashboard
- Check crowd status (Safe/Moderate/Full)
- View check-in history

### 6. Search & Logs
- Tap the search icon on event details
- Search participants by ID
- View complete check-in logs with timestamps

### 7. Offline Mode
- App works without internet
- Data is saved locally
- Automatically syncs when connection restored

## Features Breakdown

### Event Setup
✅ Create events with name, date/time, max capacity
✅ View all events on dashboard
✅ Delete events

### Participant Check-in
✅ Manual entry with participant ID
✅ Duplicate entry prevention
✅ Capacity limit enforcement
✅ Real-time confirmation messages

### Crowd Monitoring
✅ Total checked-in count
✅ Remaining capacity
✅ Visual progress indicator
✅ Crowd status (Safe < 50%, Moderate 50-80%, Full > 80%)

### Offline Functionality
✅ Local storage with Hive
✅ Automatic sync when online
✅ Sync status indicator (Synced/Pending)

### Search & Logs
✅ Search by participant ID
✅ View check-in timestamps
✅ Sync status per check-in
✅ Error message display

## Testing

### Manual Testing Checklist

1. **Authentication**
   - [ ] Signup with new email
   - [ ] Login with valid credentials
   - [ ] Error on invalid credentials
   - [ ] Logout functionality

2. **Event Management**
   - [ ] Create event
   - [ ] View events on home
   - [ ] Navigate to event detail
   - [ ] Delete event

3. **Check-in**
   - [ ] Check in valid participant
   - [ ] Prevent duplicate check-in
   - [ ] Prevent check-in when full
   - [ ] Success message displayed

4. **Dashboard**
   - [ ] Correct count display
   - [ ] Correct capacity calculation
   - [ ] Proper status indicator color
   - [ ] Recent check-ins listed

5. **Offline**
   - [ ] Work without internet
   - [ ] Save data locally
   - [ ] Sync when online
   - [ ] Show pending/synced status

6. **Search**
   - [ ] Search returns correct results
   - [ ] Shows check-in history
   - [ ] Shows timestamp
   - [ ] Shows sync status

## Troubleshooting

### App won't connect to API
- Check if backend is running: `http://localhost:3000`
- Verify API endpoint in `mongodb_service.dart`
- For emulator: use `10.0.2.2:3000`
- For device: use your machine IP

### MongoDB connection error
- Ensure MongoDB is running
- Check connection string in `.env`
- Verify MongoDB port (default: 27017)

### Hive error
- Delete app and reinstall
- Clear app data

### Sync not working
- Check internet connection
- Verify backend is running
- Check auth token validity

## Deployment

### Build APK
```bash
flutter build apk --release
```

### Build iOS
```bash
flutter build ios --release
```

### Deploy Backend
- Use Heroku, AWS, or DigitalOcean
- Set MongoDB URI to MongoDB Atlas
- Configure environment variables

## Future Enhancements

- [ ] QR code scanning
- [ ] Bulk participant upload (CSV)
- [ ] Analytics dashboard
- [ ] Email notifications
- [ ] Push notifications
- [ ] Admin panel
- [ ] Export reports

## Support

For issues or questions:
1. Check logs in `android/build` or `ios/build`
2. Verify API connection
3. Check MongoDB connection
4. Review service implementations

## License

MIT

## Contributing

Pull requests are welcome. For major changes, please open an issue first.

---

**Happy Event Managing! 🎉**
