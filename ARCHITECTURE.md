# Architecture Overview

## System Design

```
┌─────────────────────────────────────────────────────────────┐
│                     FLUTTER MOBILE APP                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   UI Layer   │  │   UI Layer   │  │   UI Layer   │      │
│  │  Screens &   │  │   Splash,    │  │  Dashboard   │      │
│  │  Widgets     │  │  Auth, Home  │  │  Events      │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │              │
│  ┌──────▼──────────────────▼──────────────────▼──────┐      │
│  │         STATE MANAGEMENT & LOGIC LAYER             │      │
│  │  Services: Auth, CheckIn, Sync, Connectivity     │      │
│  └──────┬──────────────────┬───────────────────────┬──┘      │
│         │                  │                       │          │
│  ┌──────▼────────┐  ┌──────▼─────────┐  ┌────────▼───────┐ │
│  │  Local Storage│  │   MongoDB API  │  │  Connectivity  │ │
│  │  (Hive/SQLite)│  │   (HTTP/REST)  │  │  Service       │ │
│  └──────┬────────┘  └──────┬─────────┘  └────────────────┘ │
│         │                  │                                 │
└─────────┼──────────────────┼─────────────────────────────────┘
          │                  │
          │                  │ (Network)
          │                  │
    ┌─────▼──────────────────▼──────┐
    │     BACKEND API (Node.js)      │
    │  • Express Server              │
    │  • JWT Authentication          │
    │  • REST Endpoints              │
    └─────┬──────────────────┬───────┘
          │                  │
    ┌─────▼─────────────────▼──────┐
    │      MongoDB Database         │
    │  • Users                      │
    │  • Events                     │
    │  • Participants               │
    │  • Check-Ins                  │
    └───────────────────────────────┘
```

---

## Layer Breakdown

### 1. Presentation Layer (UI)

**Location:** `lib/screens/`, `lib/widgets/`

**Screens:**
- `splash_screen.dart` - App initialization
- `auth/login_screen.dart` - User login
- `auth/signup_screen.dart` - User registration
- `home_screen.dart` - Event list dashboard
- `create_event_screen.dart` - Event creation form
- `event_detail_screen.dart` - Event management & check-in
- `search_logs_screen.dart` - Participant search & history

**Widgets:**
- `crowd_status_indicator.dart` - Visual crowd level display

**Pattern:** Stateful widgets with UI logic separated from business logic

---

### 2. Business Logic Layer (Services)

**Location:** `lib/services/`

#### `auth_service.dart`
- User authentication (signup, login, logout)
- Token management
- Session restoration
- User data persistence

#### `mongodb_service.dart`
- API communication with backend
- HTTP requests for CRUD operations
- Error handling
- Response parsing

#### `local_storage_service.dart`
- Local data persistence using Hive
- CRUD operations for all entities
- Sync status management
- Offline data storage

#### `sync_service.dart`
- Offline-first check-in logic
- Duplicate detection
- Capacity validation
- Data synchronization orchestration

#### `connectivity_service.dart`
- Internet connectivity monitoring
- Connection state streaming
- Offline/online detection

---

### 3. Data Layer (Models)

**Location:** `lib/models/`

```
User
├── id
├── name
├── email
├── role (organizer/admin)
└── createdAt

Event
├── id
├── name
├── dateTime
├── maxCapacity
├── organizerId
├── createdAt
└── synced

Participant
├── id
├── name
├── ticketId
├── eventId
├── createdAt
└── synced

CheckIn
├── id
├── participantId
├── eventId
├── checkedInAt
├── status (success/duplicate/full/failed)
├── errorMessage
├── synced
└── createdAt
```

---

## Data Flow

### Check-In Flow (Offline-First)

```
1. User enters Participant ID
   ↓
2. App checks local storage for duplicates
   ├─ If duplicate found → Show error ✗
   │
3. App checks if event is at capacity
   ├─ If at capacity → Show error ✗
   │
4. Create CheckIn record locally
   ├─ Save to Hive with synced=false (offline)
   ├─ Save to Hive with synced=true (online)
   │
5. If online:
   ├─ POST to /api/events/{eventId}/checkin
   ├─ If success → Update synced=true
   ├─ If error → Keep as pending
   │
6. Update UI
   ├─ Increment count
   ├─ Show success/error message
   │
7. When online later:
   ├─ Background sync finds unsynced records
   ├─ POST to /api/events/{eventId}/sync-checkins
   ├─ Mark as synced
```

### Sync Flow

```
1. User taps sync button / App detects internet restored
   ↓
2. Find all unsynced check-ins in local storage
   ↓
3. Group by event
   ↓
4. For each event:
   ├─ POST to /api/events/{eventId}/sync-checkins
   ├─ Include all pending check-ins
   ├─ On success → Mark all as synced
   ├─ On error → Keep as pending for retry
   │
5. Display sync results to user
```

---

## Storage Strategy

### Local Storage (Hive)
- **When:** Immediately on user action
- **What:** Events, participants, check-ins
- **Why:** Offline capability, fast access
- **Format:** Serialized JSON objects

### Remote Storage (MongoDB)
- **When:** When internet available
- **What:** Synced versions of all data
- **Why:** Persistence, multi-device sync
- **Format:** MongoDB documents

### Conflict Resolution
- **Local is authoritative** for offline entries
- **Server is authoritative** for duplicates
- **Last-write-wins** for concurrent updates

---

## Authentication Flow

```
SIGNUP/LOGIN:
1. User submits credentials
   ↓
2. POST to /api/auth/signup or /api/auth/login
   ↓
3. Backend validates & hashes password
   ↓
4. Returns JWT token + user object
   ↓
5. App saves token to SharedPreferences
   ↓
6. App saves user to Hive
   ↓
7. Set token in MongoDB service headers
   ↓
8. Navigate to home screen

ON APP RESTART:
1. Check if token exists in SharedPreferences
   ↓
2. If yes → Restore session, set token in headers
   ↓
3. Navigate to home screen
   ├─ No re-authentication needed
   │
4. If no token → Navigate to login
```

---

## Error Handling

### Application Level
- Try-catch blocks in services
- Graceful degradation
- User-friendly error messages
- Retry mechanisms for sync

### Network Level
- Timeout handling (5s default)
- Connection error catching
- Fallback to offline mode

### Validation Level
- Duplicate check (local)
- Capacity enforcement (local)
- Email/password validation
- Required field checking

---

## Offline Capabilities

### Works Offline
✅ Create/view events (from local storage)
✅ Check-in participants
✅ View check-in history
✅ Search participants
✅ Browse event dashboard
✅ View crowd status

### Requires Online
❌ Create account (initial)
❌ Login (initial)
❌ Sync data
❌ Fetch latest server data

### Sync Behavior
- **Automatic on connect** (if enabled)
- **Manual sync** (user-triggered)
- **Batch sync** (multiple records at once)
- **Retry on failure** (exponential backoff possible)

---

## State Management

**No external state management library** (by design)
- Services manage state
- Local storage is source of truth
- UI rebuilds on data changes
- Minimal rebuild scope

**Future improvement:** Consider Provider or Riverpod for:
- Reactive state updates
- Better performance
- Easier testing

---

## Performance Optimizations

### Data Structures
- Efficient local queries with Hive
- Indexed lookups where needed
- Minimal data duplication

### Network
- Batch API calls for sync
- HTTP connection reuse
- Compressed responses

### UI
- Lazy loading of lists
- Efficient widget rebuilding
- Cached images/assets

### Storage
- Automatic cleanup of old data
- Configurable retention policies
- Pagination support

---

## Security Measures

### Authentication
✅ JWT tokens
✅ Password hashing (bcryptjs)
✅ Token expiration (implement server-side)
✅ Secure token storage (SharedPreferences)

### Data Protection
✅ HTTPS for API calls
✅ Local encryption (optional with Hive)
✅ User-scoped data queries
✅ Authorization checks on server

### Input Validation
✅ Email format validation
✅ Password strength requirements
✅ Participant ID sanitization
✅ Capacity limit enforcement

---

## Testing Recommendations

### Unit Tests
- Model serialization/deserialization
- Service business logic
- Sync conflict resolution

### Widget Tests
- UI components rendering
- User interactions
- Form validation

### Integration Tests
- Full check-in workflow
- Offline to online transition
- Duplicate prevention

### Manual Testing
- Offline mode (disable network)
- Concurrent check-ins
- Large event capacity
- Network failures recovery

---

## Scalability Considerations

### Current Limits
- Single server instance
- Limited concurrent users (~100)
- Basic MongoDB indexes

### Future Improvements
- Load balancing
- Database optimization
- Caching layer (Redis)
- Message queue for async tasks
- Real-time updates (WebSockets)

---

## File Size Reference

```
lib/models/              ~400 bytes per model
lib/services/            ~300-500 lines per service
lib/screens/             ~300-400 lines per screen
lib/widgets/             ~100-200 lines per widget
```

---

## Deployment Checklist

- [ ] Security review
- [ ] Performance profiling
- [ ] Battery drain testing
- [ ] Memory leak testing
- [ ] Network resilience testing
- [ ] Load testing (backend)
- [ ] User acceptance testing
- [ ] Crash reporting setup
- [ ] Analytics setup
- [ ] Monitoring setup

---

## Maintenance Notes

### Common Tasks
- **Add new event field:** Update model, screen, API
- **Add new endpoint:** Update MongoDB service, UI
- **Fix sync issue:** Check SyncService logic, test offline/online
- **Performance issue:** Check Hive queries, reduce list items

### Debugging Tips
- Check `flutter logs` for errors
- Use DevTools for widget inspection
- Check MongoDB Atlas dashboard for data
- Test with slow network (Throttling)
- Monitor memory usage

---

## Architecture Strengths

✅ Offline-first design
✅ Clean separation of concerns
✅ Reusable services
✅ Scalable to multiple screens
✅ Easy testing
✅ Fast local operations

## Architecture Weaknesses (Future Improvements)

❌ No state management library → Consider Provider
❌ No caching strategy → Add to MongoDB service
❌ Limited error recovery → Add retry logic
❌ No analytics → Add event tracking
❌ Manual sync → Consider background syncing

---

**Version:** 1.0
**Last Updated:** May 6, 2026
