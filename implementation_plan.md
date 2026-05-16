# Neuroot — Firebase + Riverpod Implementation Plan 🌱

**Goal:** Wire up the complete Firebase backend and Riverpod state management so every screen in the app is live, functional, and persisting real data — following only what the docs specify for the MVP.

---

## What the Docs Say to Build (MVP Scope)

From `requirements.md` §11.1 and `MVP-roadmap.md` Phase 1:

| Feature | Priority |
|---|---|
| Firebase Auth (Google + Email) | 🔴 Critical |
| Onboarding (semester + subjects + timetable) | 🔴 Critical |
| Attendance tracking (mark, %, safe-leave calc) | 🔴 Critical |
| Task / Assignment / Planner CRUD | 🔴 Critical |
| Dashboard (live greeting, today classes, top tasks, attendance alerts) | 🔴 Critical |
| Focus Mode (Pomodoro timer, session persistence) | 🔴 Critical |
| Emotional Check-in (mood + energy log) | 🟠 High |
| Insights (basic study time + attendance charts) | 🟠 High |
| Profile / Sprout XP system | 🟠 High |

**NOT in this plan (excluded per docs):**
- AI features (Phase 3, separate plan)
- Social / chat / collaborative rooms
- Home screen widgets
- Push notifications (Phase 1 local only, separate)
- Advanced analytics / Crashlytics

---

## User Review Required

> [!IMPORTANT]
> **Firebase project must already exist** with `google-services.json` placed in `android/app/`. The Firebase console must have:
> - Authentication enabled (Email/Password + Google Sign-In)
> - Firestore enabled in test mode initially
>
> If `google-services.json` is not yet set up, please do that first and tell me.

> [!WARNING]
> **New packages needed** in `pubspec.yaml`:
> - `google_sign_in: ^6.2.2` — Google OAuth
> - `flutter_secure_storage: ^9.2.4` — token + biometric flag storage (per tech-stack doc)
> - `shared_preferences: ^2.5.3` — onboarding-complete flag
> - `hive_generator: ^2.0.1` (dev) — for Hive model codegen
> - `fl_chart: ^0.70.2` — charts on Insights screen (already implied by docs)
>
> Confirm you want these added.

---

## Firestore Data Schema

Based on `requirements.md` §6.3–6.11 data fields:

```
users/{uid}
  ├── displayName: string
  ├── email: string
  ├── photoUrl: string
  ├── college: string
  ├── onboardingComplete: bool
  ├── xp: int
  ├── level: int
  ├── streak: int
  └── lastActiveDate: timestamp

users/{uid}/semesters/{semId}
  ├── name: string
  ├── startDate: timestamp
  ├── endDate: timestamp
  ├── attendanceThreshold: int (75/80/85)
  └── isActive: bool

users/{uid}/subjects/{subId}
  ├── name: string
  ├── code: string
  ├── color: string (hex)
  ├── semesterId: string
  ├── totalClasses: int
  ├── presentClasses: int
  └── cancelledClasses: int

users/{uid}/timetable/{entryId}
  ├── subjectId: string
  ├── subjectName: string
  ├── dayOfWeek: int (0=Mon…6=Sun)
  ├── startTime: string ("09:00")
  ├── endTime: string ("10:00")
  └── room: string

users/{uid}/attendance/{recordId}
  ├── subjectId: string
  ├── date: timestamp
  └── status: string ("present" | "absent" | "cancelled")

users/{uid}/tasks/{taskId}
  ├── title: string
  ├── subjectId: string
  ├── type: string ("assignment" | "exam" | "lab" | "task")
  ├── dueDate: timestamp
  ├── priority: string ("high" | "medium" | "low")
  ├── isCompleted: bool
  ├── completedAt: timestamp?
  └── notes: string

users/{uid}/focusSessions/{sessionId}
  ├── date: timestamp
  ├── durationMinutes: int
  ├── sessionsCompleted: int
  └── linkedTaskId: string?

users/{uid}/moodLogs/{logId}
  ├── date: timestamp
  ├── mood: string ("happy" | "focused" | "tired" | "overwhelmed" | "calm" | "anxious")
  └── energy: int (1-5)
```

---

## Architecture: Riverpod Layer

```
Firebase SDK
    ↓
Service Layer  (lib/core/services/)
    ↓
Repository Layer  (lib/features/*/repositories/)
    ↓
Riverpod Providers  (lib/features/*/providers/)
    ↓
Screens / Widgets
```

**Pattern:** `AsyncNotifierProvider` for async CRUD, `StreamProvider` for real-time Firestore listeners, `StateNotifierProvider` for local UI state (timer, form).

---

## Phase Plan

---

### Phase 1 — Foundation: Dependencies + Firebase Init + Data Models

**Goal:** Get Firebase wired in, Hive models codegen, shared auth state available.

#### [MODIFY] `pubspec.yaml`
Add: `google_sign_in`, `shared_preferences`, `flutter_secure_storage`, `fl_chart`, `hive_generator` (dev)

#### [NEW] `lib/core/services/firebase_service.dart`
Firebase.initializeApp() wrapper, called from `main.dart`.

#### [NEW] `lib/core/models/` — all Hive + plain Dart models:
- `user_model.dart` — UserModel (Firestore ↔ Dart)
- `semester_model.dart`
- `subject_model.dart`
- `timetable_entry_model.dart`
- `attendance_record_model.dart`
- `task_model.dart`
- `focus_session_model.dart`
- `mood_log_model.dart`

#### [MODIFY] `lib/main.dart`
- Await `Firebase.initializeApp()`
- Initialize Hive boxes
- `ProviderScope` wraps app

---

### Phase 2 — Auth: Real Firebase Auth + Session Routing

**Goal:** Sign-in, sign-up, Google OAuth, sign-out all wire to Firebase. Router redirects based on auth state.

#### [NEW] `lib/core/services/auth_service.dart`
Methods: `signInWithEmail`, `signUpWithEmail`, `signInWithGoogle`, `signOut`, `sendPasswordReset`, `authStateChanges` stream.

#### [NEW] `lib/features/auth/providers/auth_provider.dart`
- `authStateProvider` — `StreamProvider<User?>` from `authService.authStateChanges`
- `authNotifierProvider` — `AsyncNotifier` for sign-in/sign-up actions + error state

#### [MODIFY] `lib/core/router/app_router.dart`
Add `redirect` callback:
- No user → `/landing`
- User + `onboardingComplete == false` → `/onboarding`
- User + `onboardingComplete == true` → `/home`
Uses `ref.watch(authStateProvider)` via `refreshListenable`.

#### [MODIFY] `lib/features/auth/screens/sign_in_screen.dart`
- Wire sign-in button to `authNotifierProvider`
- Wire Google button
- Show loading state + error toasts per app-flow.md

#### [MODIFY] `lib/features/auth/screens/sign_up_screen.dart`
- Wire create-account to `authNotifierProvider`
- Wire Google button
- Email-exists error toast

#### [MODIFY] `lib/features/auth/screens/splash_screen.dart`
- Remove hardcoded `Timer` navigation
- Watch `authStateProvider`, let router redirect handle it

---

### Phase 3 — User Profile + Onboarding Persistence

**Goal:** Onboarding writes real data to Firestore. `onboardingComplete` flag persists routing.

#### [NEW] `lib/core/services/firestore_service.dart`
Base service: typed `getDoc`, `setDoc`, `updateDoc`, `deleteDoc`, `collectionStream` helpers.

#### [NEW] `lib/features/auth/providers/user_provider.dart`
- `userDocProvider` — `StreamProvider` watching `users/{uid}`
- `userNotifierProvider` — `AsyncNotifier` for profile update

#### [MODIFY] `lib/features/onboarding/screens/onboarding_screen.dart`
Wire the 3 steps to real Firestore writes:
1. **WelcomeStep** — no data, just navigation
2. **SemesterSetupStep** — writes semester doc + subjects sub-collection
3. **MeetSproutStep** — sets `onboardingComplete: true` on user doc → router auto-redirects to `/home`

#### [NEW] `lib/features/onboarding/providers/onboarding_provider.dart`
`AsyncNotifier` handling:
- `createSemester()`
- `addSubjects()`
- `completeOnboarding()`

---

### Phase 4 — Attendance: Full CRUD + Real-Time %

**Goal:** Mark/edit attendance, live percentage update, safe-leave calculator.

#### [NEW] `lib/features/academic/repositories/attendance_repository.dart`
- `markAttendance(subjectId, date, status)` — adds attendance record + updates subject counters atomically
- `editAttendanceLog(recordId, status)` — updates record + recalculates counters
- `getAttendanceStream(subjectId)` — real-time records stream
- `getSubjectsStream()` — real-time subjects stream

#### [NEW] `lib/features/academic/providers/attendance_provider.dart`
- `subjectsStreamProvider` — `StreamProvider<List<SubjectModel>>`
- `attendanceRecordsProvider(subjectId)` — `StreamProvider<List<AttendanceRecord>>`
- `attendanceNotifierProvider` — `AsyncNotifier` for mark/edit actions
- `safeLeavesProvider(subjectId)` — computed: how many classes can be missed

#### [MODIFY] `lib/features/academic/screens/attendance_screen.dart`
- Replace all mock data with `ref.watch(subjectsStreamProvider)`
- `OverallAttendanceCard` shows real combined %
- `AttendanceSubjectCard` shows per-subject real %
- `AttendanceHeatmap` binds to real date-indexed records

#### [NEW] `lib/features/academic/screens/subject_detail_screen.dart`
- Subject detail with mark-attendance bottom sheet (BS4 from app-flow.md)
- What-if calculator (slider → live % recalc, no network call)
- Attendance log list with edit capability (BS5)

---

### Phase 5 — Tasks & Planner: Full CRUD

**Goal:** Add/edit/delete/complete tasks with real Firestore persistence.

#### [NEW] `lib/features/planning/repositories/task_repository.dart`
- `addTask(TaskModel)` 
- `updateTask(taskId, updates)`
- `deleteTask(taskId)`
- `toggleComplete(taskId, bool)` — also awards XP if completed
- `getTasksStream()` — real-time stream

#### [NEW] `lib/features/planning/providers/task_provider.dart`
- `tasksStreamProvider` — `StreamProvider<List<TaskModel>>`
- `tasksByFilterProvider(filter)` — derived: all/assignments/exams/labs
- `taskNotifierProvider` — `AsyncNotifier` for add/edit/delete

#### [MODIFY] `lib/features/planning/screens/planner_screen.dart`
- Replace mock tasks with `ref.watch(tasksStreamProvider)`
- Wire filter tabs
- Wire swipe-to-delete + complete actions
- Show Add Task bottom sheet (BS1)

#### [NEW] `lib/features/planning/widgets/add_task_bottom_sheet.dart`
Full add-task form per app-flow.md BS1:
- Title, subject chip selector, type, due date picker, priority

#### [NEW] `lib/features/planning/screens/task_detail_screen.dart`
- Edit inline fields
- Subtask rows (toggle done)
- Delete with confirm dialog D1
- "Start Focus" button → navigates to focus with taskId

---

### Phase 6 — Dashboard: Live Data

**Goal:** Dashboard is no longer mocked. All sections show real user data.

#### [NEW] `lib/features/dashboard/providers/dashboard_provider.dart`
- `todayClassesProvider` — derived from timetable for today's weekday
- `topTasksProvider` — top 3 incomplete tasks by priority + due date
- `attendanceDangerProvider` — subjects below threshold
- `userGreetingProvider` — user name + time-based greeting

#### [MODIFY] `lib/features/dashboard/widgets/dashboard_header.dart`
- Show real user `displayName` and `photoUrl` from `userDocProvider`

#### [MODIFY] `lib/features/dashboard/screens/dashboard_screen.dart`
- Replace all mock data with real providers
- Today's classes from timetable
- Top tasks wired to task completion actions
- Attendance danger alert from `attendanceDangerProvider`
- Mood selector writes to `moodLogs` collection

---

### Phase 7 — Focus Mode: Session Persistence

**Goal:** Focus timer sessions save to Firestore, XP is awarded, streak increments.

#### [NEW] `lib/features/focus/providers/focus_provider.dart`
- `focusTimerProvider` — `StateNotifierProvider` (timer state: running/paused/break/done, seconds remaining)
- `focusSessionNotifierProvider` — `AsyncNotifier` saves session to Firestore on complete + awards XP

#### [MODIFY] `lib/features/focus/screens/focus_screen.dart`
- Wire timer controls (play/pause/restart/skip) to `focusTimerProvider`
- On session complete → call `focusSessionNotifierProvider.saveSession()`
- Show F3 session-complete overlay with real stats

---

### Phase 8 — Profile + Insights: Real Data

**Goal:** Profile shows real XP/level/streak. Insights shows real charts.

#### [MODIFY] `lib/features/profile/screens/profile_screen.dart`
- Watch `userDocProvider` for XP, level, streak
- Progress bar = real XP / nextLevelXP
- Milestones use real data

#### [NEW] `lib/features/academic/providers/insights_provider.dart`
- `weeklyFocusHoursProvider` — sum of focus sessions for selected week
- `weeklyAttendanceProvider` — attendance % per subject for charts
- `moodTrendProvider` — last 7 mood logs

#### [MODIFY] `lib/features/academic/screens/insights_screen.dart`
- Wire fl_chart bar chart to `weeklyFocusHoursProvider`
- Wire pie/ring chart to `weeklyAttendanceProvider`

---

## Verification Plan

### After Each Phase
- `flutter run` with Firebase connected
- Verify Firestore console shows written documents
- Verify auth state changes redirect correctly

### End-to-End Flow
1. Sign up with email → Firestore `users/{uid}` created
2. Complete onboarding → semester + subjects written, `onboardingComplete: true`
3. Mark attendance → subject counters update, % reflects real-time
4. Add task → appears in planner + dashboard top tasks
5. Run focus session → session doc written, XP incremented on user doc
6. Check profile → XP bar reflects real value

---

## File Creation Summary

| Phase | New Files | Modified Files |
|---|---|---|
| 1 | 8 models, firebase_service.dart | pubspec.yaml, main.dart |
| 2 | auth_service.dart, auth_provider.dart | splash, signin, signup, router |
| 3 | firestore_service.dart, user_provider.dart, onboarding_provider.dart | onboarding_screen |
| 4 | attendance_repository, attendance_provider, subject_detail_screen | attendance_screen |
| 5 | task_repository, task_provider, add_task_bottom_sheet, task_detail_screen | planner_screen |
| 6 | dashboard_provider | dashboard_screen, dashboard_header |
| 7 | focus_provider | focus_screen |
| 8 | insights_provider | profile_screen, insights_screen |

**Total: ~20 new files, ~10 modified files**
