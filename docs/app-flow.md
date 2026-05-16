# Neuroot — Auth Screens, Navigation Map & Screen Connection Guide

---

## PART 2 — COMPLETE SCREEN INVENTORY

_Every screen the app has, including states._

```
TOTAL SCREENS: 36 unique screens + states

AUTH FLOW (6 screens):
  A1. Landing / Welcome
  A2. Sign Up (Email)
  A3. Email Verification
  A4. Sign In
  A5. Forgot Password
  A6. Biometric Setup

ONBOARDING FLOW (4 screens):
  O1. Onboarding Welcome
  O2. Semester Setup
  O3. Timetable Builder
  O4. Meet Sprout

MAIN APP — HOME (3 states):
  H1. Home · Morning
  H2. Home · Evening / Default
  H3. Home · Night Mode
  H4. Home · Exam Week Mode
  H5. Home · Empty State (first launch, no data)

ATTENDANCE (4 screens):
  AT1. Attendance Overview
  AT2. Subject Detail (drill-down)
  AT3. Mark Attendance (single class)
  AT4. Attendance Empty State

PLANNER (5 screens):
  P1. Planner Main
  P2. Add Task (bottom sheet)
  P3. Task Detail / Edit
  P4. Exam Detail
  P5. Planner Empty State

FOCUS MODE (3 states):
  F1. Focus Active
  F2. Focus Break
  F3. Focus Session Complete

MASCOT / COMPANION (2 screens):
  M1. Sprout Companion Screen
  M2. Unlock / Cosmetics Detail

AI PLANNER (2 screens):
  AI1. AI Planner Main
  AI2. AI Roadmap Detail

INSIGHTS (2 screens):
  I1. Insights / Progress Dashboard
  I2. Semester Recap (end of sem)

NOTIFICATIONS (1 screen):
  N1. Notification Center

SETTINGS / PROFILE (3 screens):
  S1. Profile / Settings Main
  S2. Notification Preferences
  S3. Theme / Appearance

SYSTEM (2 screens):
  SY1. No Internet / Offline
  SY2. App Update Required
```

---

---

## PART 3 — COMPLETE NAVIGATION MAP

### How Every Screen Connects

---

### TIER 1: App Launch Flow

```
App Opens
    │
    ▼
[Splash Screen] (1.5s auto)
    │
    ├── First-time user ──────────► [A1: Landing / Welcome]
    │
    └── Returning user (session saved) ──► [H2: Home Dashboard]
                │
                └── Session expired ──────► [A4: Sign In]
```

---

### TIER 2: Auth Flow — New User

```
[A1: Landing / Welcome]
    │
    ├── Tap "Get Started" ──────────────► [A2: Sign Up]
    │
    ├── Tap "Continue with Google" ─────► [Google OAuth → O1: Onboarding Welcome]
    │
    └── Tap "Already have account?" ───► [A4: Sign In]


[A2: Sign Up]
    │
    ├── Tap "← Back" ─────────────────► [A1: Landing]
    │
    ├── Tap "Continue with Google" ─────► [Google OAuth → O1: Onboarding Welcome]
    │
    ├── Fill form + Tap "Create Account"
    │       │
    │       ├── Success ───────────────► [A3: Email Verification]
    │       └── Error (email exists) ──► Inline error toast: "This email is already registered. Sign in instead?" with Sign In CTA
    │
    └── Tap "Sign in" (top right) ─────► [A4: Sign In]


[A3: Email Verification]
    │
    ├── Tap "Open Email App" ──────────► Opens native mail app (external)
    │
    ├── Tap "Resend email" ─────────────► Same screen, resend toast, cooldown timer resets
    │
    ├── Email link clicked (deep link) ─► [A6: Biometric Setup]
    │                                         │
    │                                         └── [O1: Onboarding Welcome]
    │
    └── Tap "Back to Sign Up" ─────────► [A2: Sign Up]
```

---

### TIER 3: Auth Flow — Returning User

```
[A4: Sign In]
    │
    ├── Tap "← Back" ─────────────────► [A1: Landing]
    │
    ├── Tap "Forgot password?" ─────────► [A5: Forgot Password]
    │
    ├── Tap "Continue with Google" ─────► Google OAuth
    │       ├── Existing Google account ► [H2: Home Dashboard]
    │       └── New Google account ──────► [O1: Onboarding Welcome]
    │
    ├── Fill + Tap "Sign In"
    │       ├── Success ───────────────► [H2: Home Dashboard]  (or Exam Week mode if active)
    │       └── Wrong password ─────────► Inline field error: "Incorrect password" red border, shake animation
    │
    ├── Tap fingerprint/face button ───► Biometric auth
    │       ├── Success ───────────────► [H2: Home Dashboard]
    │       └── Fail ───────────────────► Falls back to password field, toast: "Try again or use password"
    │
    └── Tap "Create one free →" ────────► [A2: Sign Up]


[A5: Forgot Password]
    │
    ├── Tap "← Back" ─────────────────► [A4: Sign In]
    │
    ├── Enter email + Tap "Send Reset Link"
    │       ├── Email found ──────────► Same screen, success state card appears
    │       └── Email not found ───────► Toast error: "No account found with this email."
    │
    └── Deep link from reset email ────► Full-screen reset password form (simple, not detailed here)
            └── Success ────────────────► [A4: Sign In] with toast: "Password updated! Sign in."
```

---

### TIER 4: Onboarding Flow (One-time, New Users Only)

```
[O1: Onboarding Welcome]
    │
    ├── Tap "Let's Get Started" or Swipe ──► [O2: Semester Setup]
    └── Tap "Already have account?" ────────► [A4: Sign In]


[O2: Semester Setup]
    │
    ├── Tap "← Back" ───────────────────────► [O1: Welcome]
    ├── Tap "Skip" ──────────────────────────► [O3: Timetable Builder] (with defaults)
    │
    ├── Fill name, dates, threshold, subjects
    └── Tap "Continue → Build Timetable" ───► [O3: Timetable Builder]
            │
            ● Validation: if no subjects added → shake animation + inline toast:
              "Add at least one subject to continue 🌱"


[O3: Timetable Builder]
    │
    ├── Tap "← Back" ───────────────────────► [O2: Semester Setup]
    ├── Tap "Skip" ──────────────────────────► [O4: Meet Sprout]
    │
    ├── Tap day tab (Mon/Tue/etc.) ──────────► Switches displayed schedule for that day
    │
    ├── Tap "+ Add class for [Day]" ─────────► Bottom sheet: Add Class form
    │       └── Tap "Save Class" / "Done" ───► Returns to O3, class card appears
    │
    └── Tap "Continue → Almost Done!" ───────► [O4: Meet Sprout]


[O4: Meet Sprout]
    │
    └── Tap "Let's Neuroot! 🌱" ───────────────► [H2: Home Dashboard] (with confetti animation)
```

---

### TIER 5: Home Dashboard Navigation

```
[H2: Home Dashboard] ← DEFAULT MAIN SCREEN
    │
    ├── GREETING AREA:
    │       └── Tap Sprout avatar (top right) ────────────────► [M1: Mascot / Companion Screen]
    │
    ├── MOOD SELECTOR (tap any emoji):
    │       └── Mood selected ──────────────────────────────────► Same screen, Sprout reacts (animation)
    │                                                              Mascot expression changes
    │
    ├── NEXT CLASS CARD:
    │       ├── Tap card body ───────────────────────────────────► [AT2: Subject Attendance Detail]
    │       └── Tap attendance % pill ──────────────────────────► [AT2: Subject Attendance Detail]
    │
    ├── TODAY'S 3 PRIORITIES:
    │       ├── Tap checkbox ───────────────────────────────────► Task marked done (inline animation)
    │       ├── Tap task card body ──────────────────────────────► [P3: Task Detail / Edit]
    │       └── Tap "See all →" (if visible) ───────────────────► [P1: Planner Main]
    │
    ├── ATTENDANCE DANGER ALERT:
    │       └── Tap alert card ──────────────────────────────────► [AT2: Subject Attendance Detail]
    │
    ├── FOCUS BUTTON ("Start Focus Session"):
    │       └── Tap ─────────────────────────────────────────────► [F1: Focus Mode Active]
    │
    ├── EXAM WEEK BANNER (if exam week):
    │       └── Tap ─────────────────────────────────────────────► [AI1: AI Planner / Exam Plan]
    │
    └── BOTTOM NAVIGATION:
            ├── Home (active) ────► [H2: Home]
            ├── Planner ─────────► [P1: Planner Main]
            ├── Focus ───────────► [F1: Focus Mode Active]
            ├── Insights ────────► [I1: Insights Dashboard]
            └── Profile ─────────► [S1: Profile / Settings]
```

---

### TIER 6: Attendance Flow

```
[AT1: Attendance Overview]
    │
    ├── Reached via: Bottom nav (no dedicated nav icon — accessed from Home, Planner, or Settings)
    │   Actually: Tap "Attendance" in Home card area or via ← back from AT2
    │
    ├── OVERALL CARD:
    │       └── No tap action (display only)
    │
    ├── SUBJECT CARDS (each card):
    │       ├── Tap subject card body ──────────────────────────► [AT2: Subject Detail]
    │       └── Tap "Mark today →" button ──────────────────────► [AT3: Mark Attendance] (bottom sheet)
    │
    ├── SORT BY RISK toggle ──────────────────────────────────────► Reorders cards (inline, no new screen)
    │
    ├── HEATMAP CARD:
    │       └── Tap any square ──────────────────────────────────► Tooltip popup: "Present · Mon 12 May" (inline overlay)
    │
    └── ← Back ──────────────────────────────────────────────────► [H2: Home]


[AT2: Subject Attendance Detail]
    │
    ├── TOP BAR back "← Attendance" ────────────────────────────► [AT1: Overview] or [H2: Home]
    │
    ├── QUICK MARK ROW (3 buttons):
    │       ├── Tap "✓ Present" ────────────────────────────────► Inline: percentage updates, bar animates, toast "Marked Present ✓"
    │       ├── Tap "✗ Absent" ─────────────────────────────────► Inline: percentage drops, danger check, toast "Marked Absent"
    │       └── Tap "◎ Cancelled" ──────────────────────────────► Inline: no % change, toast "Class cancelled — not counted"
    │
    ├── WHAT-IF CALCULATOR:
    │       └── Drag slider ─────────────────────────────────────► Live % calculation updates in real time (no new screen)
    │
    ├── ATTENDANCE LOG rows:
    │       └── Tap any log row ──────────────────────────────────► Edit bottom sheet: change status for that date
    │                                                                Fields: date (read-only), status buttons
    │
    └── Share icon (top right) ─────────────────────────────────► Native share sheet: share attendance stats card


[AT3: Mark Attendance] — BOTTOM SHEET
    │
    ├── Appears over AT2 or AT1 (darkened overlay behind)
    │
    ├── Tap "Present / Absent / Cancelled" ──────────────────────► Closes sheet, updates parent screen
    │
    └── Tap overlay / "×" ───────────────────────────────────────► Dismisses, no change
```

---

### TIER 7: Planner Flow

```
[P1: Planner Main]
    │
    ├── FILTER TABS:
    │       └── Tap any tab (All/Assignments/Exams/Labs) ────────► Filters task list inline (no new screen)
    │
    ├── ADD BUTTON "+" (top right):
    │       └── Tap ─────────────────────────────────────────────► [P2: Add Task] bottom sheet slides up
    │
    ├── EXAM COUNTDOWN CARD:
    │       └── Tap ─────────────────────────────────────────────► [P4: Exam Detail]
    │
    ├── TASK CARDS:
    │       ├── Tap checkbox ───────────────────────────────────► Task toggles done/undone (inline animation)
    │       ├── Tap card body ──────────────────────────────────► [P3: Task Detail / Edit]
    │       ├── Swipe left on card ──────────────────────────────► Reveal: Delete (red) | Mark Done (green)
    │       └── Long press card ─────────────────────────────────► Drag-to-reorder mode activates
    │
    └── BOTTOM NAV: active tab = Planner


[P2: Add Task] — BOTTOM SHEET
    │
    ├── Background darkened overlay, sheet slides up
    │
    ├── SUBJECT CHIPS (horizontal scroll):
    │       └── Tap any subject chip ────────────────────────────► Selects/deselects (highlighted state)
    │
    ├── DUE DATE field:
    │       └── Tap ─────────────────────────────────────────────► Inline calendar date picker appears below field
    │
    ├── AI BREAKDOWN TOGGLE:
    │       └── Toggle ON ───────────────────────────────────────► After save, AI generates subtasks (loading state, then reveals)
    │
    ├── Tap "Add Task" ───────────────────────────────────────────► Sheet closes, task appears in P1, Sprout mini-animation on Home
    │       │
    │       └── Validation error (no name / no subject)
    │               └── Field highlight red border + shake + toast: "Give your task a name first 🌱"
    │
    └── Tap overlay / drag down sheet ──────────────────────────► Dismisses, no task added


[P3: Task Detail / Edit]
    │
    ├── Back "← Planner" ───────────────────────────────────────► [P1: Planner]
    │
    ├── Edit any field inline ──────────────────────────────────► Fields become editable on tap
    │
    ├── SUBTASK ROWS:
    │       ├── Tap checkbox ───────────────────────────────────► Subtask toggles done
    │       ├── Tap subtask text ────────────────────────────────► Editable text field inline
    │       └── Tap "+ Add subtask" ──────────────────────────────► New empty subtask row added below
    │
    ├── "Start Focus" button (on task detail):
    │       └── Tap ─────────────────────────────────────────────► [F1: Focus Mode] with this task pre-selected
    │
    ├── "Delete Task" (bottom, red ghost button):
    │       └── Tap ─────────────────────────────────────────────► Confirmation dialog:
    │               "Delete this task?"  [Cancel] [Delete — red]
    │               └── Confirm delete ──────────────────────────► [P1: Planner] + task removed
    │
    └── Changes auto-save ──────────────────────────────────────► No explicit save button needed


[P4: Exam Detail]
    │
    ├── Back "← Planner" ───────────────────────────────────────► [P1: Planner]
    │
    ├── "Let AI make a study plan" button ────────────────────────► [AI1: AI Planner] with this exam pre-loaded
    │
    └── Edit exam details inline
```

---

### TIER 8: Focus Mode Flow

```
[F1: Focus Mode — Active]
    │
    ├── REACHED FROM:
    │       ├── Home "Start Focus Session" button
    │       ├── P3 Task Detail "Start Focus" button
    │       └── Bottom nav "Focus" tab
    │
    ├── MODE PILLS (25/5, 50/10, Custom):
    │       └── Tap to switch ───────────────────────────────────► Timer resets to new mode, confirmation dialog if mid-session:
    │               "Switch mode? This will reset your current session."
    │               [Cancel] [Switch]
    │
    ├── PAUSE button (center):
    │       └── Tap ─────────────────────────────────────────────► Timer pauses, button becomes PLAY icon
    │               Plant animation pauses
    │               Sprout shows "paused" expression (tilted head, question mark)
    │
    ├── RESTART button (left):
    │       └── Tap ─────────────────────────────────────────────► Confirmation: "Restart this session?"
    │               [Cancel] [Restart]
    │
    ├── SKIP button (right):
    │       └── Tap ─────────────────────────────────────────────► Skips to next phase (Focus→Break or Break→Focus)
    │
    ├── Timer reaches 0:00 (Focus complete):
    │       └── Auto-transitions ─────────────────────────────────► [F2: Break Mode]
    │               Transition: gentle chime sound + Sprout celebrates + soft animation
    │
    ├── Timer reaches 0:00 (Break complete):
    │       └── Auto-transitions ─────────────────────────────────► Back to [F1: Focus] for next session
    │
    ├── "End Session ×" (bottom ghost button):
    │       └── Tap ─────────────────────────────────────────────► [F3: Session Complete Screen]
    │
    └── Phone distraction nudge (appears after 5 min):
            ├── Tap "✓ Yes, keep going" ─────────────────────────► Nudge dismisses
            └── Tap "Take a break" ──────────────────────────────► Timer pauses, transitions to [F2: Break]


[F2: Focus Break Mode]
    │
    ├── Same screen layout but:
    │       - Background shifts slightly warmer/lighter
    │       - Timer label says "Break"
    │       - Sprout is in relaxed pose (stretching, holding tiny cup)
    │       - Timer ring color: sage green (not yellow)
    │
    ├── Skip break button ──────────────────────────────────────► Jumps back to [F1: Focus]
    │
    └── Timer reaches 0 ────────────────────────────────────────► Back to [F1: Focus]


[F3: Session Complete]
    │
    ├── Appears as an overlay/celebration screen
    │
    ├── Shows:
    │       - Sprout in celebrating pose
    │       - Sessions completed: "3 sessions · 1.5h focused"
    │       - Streak update: "Day 12 complete 🔥"
    │       - Task linked: "DSA Practice marked in-progress"
    │
    ├── Tap "Mark Task Done ✓" ──────────────────────────────────► Task marked complete, XP added to Sprout
    │
    ├── Tap "Start Another Session" ───────────────────────────── ► [F1: Focus Mode]
    │
    └── Tap "Back to Home" / "Done" ───────────────────────────► [H2: Home Dashboard]
```

---

### TIER 9: Mascot / Companion Flow

```
[M1: Mascot / Companion]
    │
    ├── REACHED FROM: Tap Sprout avatar on Home (top right)
    │
    ├── UNLOCKS GRID:
    │       ├── Tap unlocked item ───────────────────────────────► Applies cosmetic (Sprout changes outfit/room instantly)
    │       └── Tap locked item ─────────────────────────────────► [M2: Unlock Detail]
    │               Shows: "Unlock at Level X" or "Earn by 15-day streak"
    │               CTA: "Keep going!" closes back to M1
    │
    ├── MILESTONES:
    │       └── Tap any milestone ───────────────────────────────► Tooltip/inline card: milestone details
    │
    ├── SHARE button (top right):
    │       └── Tap ─────────────────────────────────────────────► Native share sheet: Sprout stats card image
    │               "Look at my Neuroot companion! 🌱" with XP, level, streak
    │
    └── Back "← Back" ──────────────────────────────────────────► [H2: Home]
```

---

### TIER 10: AI Planner Flow

```
[AI1: AI Planner]
    │
    ├── REACHED FROM:
    │       ├── Exam Week banner on Home
    │       └── Planner exam card "Let AI make a plan"
    │
    ├── WEEK PLAN card:
    │       └── Tap any day row ─────────────────────────────────► Expands that day's tasks inline
    │               Each task in expanded day: tap → [P3: Task Detail]
    │
    ├── AI RESCHEDULING CARD:
    │       ├── Tap "Confirm ✓" ─────────────────────────────────► Tasks rescheduled, planner updates, toast
    │       └── Tap "Edit →" ────────────────────────────────────► [P2: Add Task] with rescheduled task pre-filled
    │
    ├── BURNOUT CARD:
    │       └── Tap "Plan a lighter tomorrow →" ─────────────────► [AI1] scrolls or transitions to "Light Day mode"
    │               Shows lighter plan for next day with only 1-2 gentle tasks
    │
    └── Back ───────────────────────────────────────────────────► Previous screen (Home or Planner)
```

---

### TIER 11: Insights Flow

```
[I1: Insights Dashboard]
    │
    ├── WEEK SELECTOR "This Week ▾":
    │       └── Tap ─────────────────────────────────────────────► Dropdown: "This Week / Last Week / This Semester"
    │               Selecting changes all charts inline
    │
    ├── SPROUT WEEKLY WRAP card:
    │       └── Tap (anywhere) ──────────────────────────────────► Expands full Sprout summary (inline expand or new screen)
    │
    ├── STUDY TIME chart:
    │       └── Tap any bar ─────────────────────────────────────► Tooltip: "Thursday · 2.5h · 3 sessions"
    │
    ├── ATTENDANCE RING chart:
    │       └── Tap any arc segment ─────────────────────────────► [AT2: Subject Detail] for that subject
    │
    ├── FOCUS STREAKS heatmap:
    │       └── Tap any square ──────────────────────────────────► Tooltip: "Studied 1.5h · Thursday 8 May"
    │
    └── Bottom nav: Insights tab active
```

---

### TIER 12: Settings / Profile Flow

```
[S1: Profile / Settings]
    │
    ├── USER PROFILE SECTION:
    │       └── Tap "Edit Profile" ──────────────────────────────► Edit name, college, profile photo (inline edit)
    │
    ├── SEMESTER SETTINGS:
    │       └── Tap "Edit Semester" ──────────────────────────────► [O2: Semester Setup] in edit mode (not onboarding)
    │
    ├── "Notification Settings":
    │       └── Tap ─────────────────────────────────────────────► [S2: Notification Preferences]
    │
    ├── "Appearance / Theme":
    │       └── Tap ─────────────────────────────────────────────► [S3: Theme Screen]
    │               Toggle: Auto (time-based) / Always Light / Always Dark
    │               Premium themes: "Dark Academia", "Sakura Spring", etc. (locked behind Pro)
    │
    ├── "AI Assistant":
    │       └── Tap ─────────────────────────────────────────────► Toggle Sprout AI features on/off
    │
    ├── "Sign Out":
    │       └── Tap ─────────────────────────────────────────────► Confirmation dialog:
    │               "Sign out? Sprout will miss you! 🌱"
    │               [Cancel] [Sign Out]
    │               └── Confirm ──────────────────────────────────► [A1: Landing / Welcome]
    │
    └── Bottom nav: Profile tab active
```

---

---

## PART 4 — COMPLETE EMPTY STATES

_Every empty state across the app. Each should have Sprout + supportive message._

---

### HOME EMPTY STATE — H5 (First launch, no semester data)

```
TRIGGER: User just completed onboarding but skipped all setup (no subjects, no timetable)

SCREEN CONTENT:
- Sprout (slightly confused but cheerful expression, 100px) in center
- Heading: "Your semester is waiting 🌱"
- Body: "Add your subjects and timetable to unlock your dashboard."
- Primary CTA: "Set Up Semester →" — yellow button → [O2: Semester Setup]
- Ghost button: "Explore the app first" → Dismisses, shows skeleton/demo version of Home

RULES:
- NO attendance widget shown
- NO task section shown
- "Next Class" card shows: "Add timetable to see your next class →"
- Bottom nav still fully visible and functional
```

---

### ATTENDANCE EMPTY STATE — AT4

```
TRIGGER: User has subjects added but has never marked attendance

SCREEN CONTENT:
- Sprout (holding tiny clipboard, curious expression)
- Heading: "No attendance tracked yet"
- Body: "Mark your first class today and Sprout will start tracking your progress."
- Subject chips shown (from setup), each with "Start tracking →" button
- Primary CTA: "Mark Today's Classes →" → [AT3: Mark Attendance]

TRIGGER 2: No subjects added at all
- Heading: "Add subjects first 🌱"
- CTA: "Set Up Subjects →" → [O2: Semester Setup]
```

---

### PLANNER EMPTY STATES — P1

```
EMPTY STATE 1 — No tasks at all (first time):
- Sprout sitting happily on an empty desk with a tiny potted plant
- Heading: "Your planner is clean 🌿"
- Body: "Add your first assignment or exam — Sprout will help you stay on top of it."
- CTA: "+ Add Your First Task" — yellow → [P2: Add Task sheet]

EMPTY STATE 2 — No tasks for selected filter:
- Sprout looking slightly surprised
- (If "Exams" filter selected and no exams):
  "No exams added yet. Add an exam and Sprout will start the countdown!"
- CTA: "+ Add Exam" → [P2: Add Task, type pre-set to Exam]

EMPTY STATE 3 — All tasks completed (all done!):
- Sprout in full CELEBRATING pose, confetti
- Heading: "All done! You crushed it 🎉"
- Body: "Sprout is super proud. Take a breath — you've earned it."
- CTA: "See Insights →" → [I1: Insights]
- Ghost: "Add more tasks"

EMPTY STATE 4 — No tasks today (Today filter):
- Sprout relaxing in a tiny hammock
- Heading: "Nothing due today 🌿"
- Body: "Enjoy the peace, or get ahead on upcoming work."
- Ghost CTA: "See Upcoming →" → Switches filter to "All"
```

---

### FOCUS EMPTY STATE

```
TRIGGER: User taps Focus tab with no tasks in planner

SCREEN CONTENT:
- Sprout with a tiny question mark thought bubble
- Heading: "What are you studying today?"
- Body: "Add a task to your planner first, then link it to your focus session."
- CTA: "Add a Task →" → [P2: Add Task sheet]
- Ghost CTA: "Start a Free Focus Session" → [F1: Focus] with no task linked
```

---

### INSIGHTS EMPTY STATES — I1

```
EMPTY STATE 1 — No study data yet (new user, no focus sessions):
- Sprout with a tiny telescope (looking ahead)
- Heading: "Your insights are growing 🌱"
- Body: "Complete a focus session or mark some tasks to see your progress here."
- CTA: "Start Studying →" → [F1: Focus Mode]

EMPTY STATE 2 — No attendance data:
- Bar charts shown as gray empty bars (skeleton state)
- Overlay text: "Mark attendance to unlock your charts"
- CTA: "Go to Attendance →" → [AT1: Attendance Overview]

EMPTY STATE 3 — Selected "Last Week" but no data for that week:
- "No data for last week. Keep studying and Sprout will track your progress!"
```

---

### MASCOT EMPTY STATE

```
TRIGGER: User somehow reaches Sprout screen before any activity (shouldn't happen normally, but edge case)

- Sprout at Level 1, almost no XP
- Heading: "Sprout just woke up 🌱"
- Body: "Complete tasks, attend classes, and focus to help Sprout grow!"
- 3 suggestion pills:
  "✓ Complete a task" | "📚 Mark attendance" | "⏱ Start focus"
```

---

### NOTIFICATION EMPTY STATE — N1

```
TRIGGER: No notifications yet (early user)

- Sprout sleeping (tiny Zs floating)
- Heading: "All quiet here 🌙"
- Body: "Sprout will notify you about classes, attendance, and tasks — never too many, never guilt-trips."
- Ghost: "Manage notification settings →" → [S2: Notification Preferences]
```

---

---

## PART 5 — COMPLETE MODAL & OVERLAY INVENTORY

_Every bottom sheet, dialog, and overlay._

---

### BOTTOM SHEETS

| ID   | Name                        | Triggered By              | Content                                |
| ---- | --------------------------- | ------------------------- | -------------------------------------- |
| BS1  | Add Task                    | Planner "+" button        | Full add task form                     |
| BS2  | Add Class (Onboarding)      | "+" in timetable          | Class name, time, room, subject, color |
| BS3  | Add Class (Post-onboarding) | Settings > Timetable      | Same as BS2                            |
| BS4  | Mark Attendance             | Subject card "Mark today" | Present / Absent / Cancelled buttons   |
| BS5  | Edit Attendance Log         | Log row tap               | Date (read-only) + status 3 buttons    |
| BS6  | Date Picker                 | Due date fields           | Calendar view, scrollable months       |
| BS7  | Biometric Setup             | Post-signup               | Enable fingerprint / face / PIN / skip |
| BS8  | Focus Session End           | "End session"             | Stats summary + action buttons         |
| BS9  | Task Swipe Actions          | Swipe left on task card   | Delete (red) + Mark Done (green)       |
| BS10 | Exam Week AI Plan           | Exam week banner          | AI-generated 5-day plan                |

---

### CONFIRMATION DIALOGS

| ID  | Trigger                       | Content                                      | Actions               |
| --- | ----------------------------- | -------------------------------------------- | --------------------- |
| D1  | Delete Task                   | "Delete this task?"                          | Cancel / Delete (red) |
| D2  | Sign Out                      | "Sprout will miss you! 🌱"                   | Cancel / Sign Out     |
| D3  | Switch Focus Mode mid-session | "Switch mode? Resets session."               | Cancel / Switch       |
| D4  | Restart Focus session         | "Restart this session?"                      | Cancel / Restart      |
| D5  | Skip Onboarding entirely      | "Skip setup? You can do this later."         | Skip / Finish Setup   |
| D6  | Semester End detected         | "Semester ending soon! Create new semester?" | Later / Create Now    |

---

### TOAST NOTIFICATIONS (Inline, 2-3 seconds, non-blocking)

| Trigger                   | Toast Message                                         |
| ------------------------- | ----------------------------------------------------- |
| Task marked done          | "✓ Task complete! Sprout gained +10 XP 🌱"            |
| Task marked undone        | "Task unchecked. No worries!"                         |
| Attendance marked Present | "✓ Present marked for [Subject]"                      |
| Attendance marked Absent  | "Absent noted. You can miss X more in [Subject]"      |
| Attendance danger reached | "⚠ [Subject] attendance critical — attend next class" |
| Focus session started     | "Focus started 🌱 Sprout is ready!"                   |
| Task added                | "Task added to your planner"                          |
| Wrong password on sign in | "Incorrect password. Forgot it?"                      |
| Email already registered  | "Account exists. Sign in instead?"                    |
| AI rescheduled tasks      | "✨ Sprout rescheduled 2 tasks for you"               |
| Streak milestone          | "🔥 12-day streak! Sprout is glowing."                |
| Sprout leveled up         | "🌟 Sprout reached Level 8!"                          |
| New unlock available      | "🎉 New cosmetic unlocked: Scholar Hat!"              |

---

---

## PART 6 — COMPLETE STATE MATRIX

_Every screen and all possible states it can be in._

---

### Home Dashboard States

| State     | Condition            | Key Differences                         |
| --------- | -------------------- | --------------------------------------- |
| Empty     | No semester setup    | Sprout placeholder, setup CTA           |
| Morning   | Time 6AM–11AM        | Warm gradient, energetic Sprout, coffee |
| Afternoon | Time 12PM–5PM        | Neutral cream, focused Sprout           |
| Evening   | Time 6PM–9PM         | Default, warm amber accents             |
| Night     | Time 9PM+            | Dark mode, sleepy Sprout, stars         |
| Exam Week | Exam within 3 days   | Purple exam banner, focused UI          |
| All Done  | All 3 tasks complete | Celebration mini state, Sprout happy    |
| Burnout   | AI detects overload  | Softer card, lighter suggestions        |

---

### Attendance Subject Card States

| State    | Condition                       | Visual                                        |
| -------- | ------------------------------- | --------------------------------------------- |
| Safe     | ≥ threshold + buffer (≥80%)     | Green bar, green chip "Safe"                  |
| OK       | At threshold to buffer (75–79%) | Yellow bar, amber chip "Warning"              |
| Danger   | At exactly threshold (75%)      | Amber bar, amber chip                         |
| Critical | Below threshold (<75%)          | Red bar, red chip "⚠ Danger", red card border |
| Perfect  | 100%                            | Gold bar, special chip "Perfect 🌟"           |
| No data  | 0 classes marked                | Gray empty bar, "Start tracking →"            |

---

### Task Card States

| State        | Condition               | Visual                              |
| ------------ | ----------------------- | ----------------------------------- |
| Pending      | Created, not started    | Empty checkbox, normal text         |
| In Progress  | Has subtasks, some done | Partial subtask progress bar        |
| Done         | Checkbox ticked         | Green checkbox, strikethrough text  |
| Overdue      | Past due date, not done | Red date label, red left border     |
| AI-generated | Created by AI           | Small ✨ sparkle icon in top corner |
| Recurring    | Recurring task          | Circular arrows icon                |

---

### Focus Mode States

| State          | Condition                  | Visual                                       |
| -------------- | -------------------------- | -------------------------------------------- |
| Pre-session    | Just opened Focus tab      | Task selector + "Start" button               |
| Active · Focus | Timer running, focus phase | Dark bg, yellow ring, Sprout focused         |
| Active · Break | Timer running, break phase | Slightly lighter, green ring, Sprout resting |
| Paused         | Pause button tapped        | Timer frozen, Sprout tilted head             |
| Complete       | Session ended              | Celebration overlay, stats shown             |
| No task linked | Opened without task        | Sprout with "?" + task suggestion            |

---

### Sprout / Mascot States

| State          | Trigger                         | Expression                           |
| -------------- | ------------------------------- | ------------------------------------ |
| Happy          | Normal / tasks done             | Big eyes, slight smile               |
| Celebrating    | Task complete, level up, streak | Arms up, confetti                    |
| Focused        | Focus mode active               | Squinting eyes, pencil in hand       |
| Sleepy         | Night mode (9PM+)               | Half-closed eyes, tiny Zs            |
| Gentle Concern | Attendance danger               | Soft worried eyes, one hand on chest |
| Thinking       | AI generating plan              | Hand on chin, thought bubble         |
| Excited        | New unlock                      | Jumping, sparkles                    |
| Resting        | Break mode                      | Relaxed, holding tiny cup            |

---

---

## PART 7 — SCREEN FLOW DIAGRAM (Text Version)

```
APP START
    │
    ├─[Splash]──────────────────────────────────────────────────┐
    │                                                            │
    │  New User                          Returning User          │
    │      │                                 │                  │
    │  [A1: Landing]                   [H2: Home] ◄─────────────┘
    │      │
    │      ├──"Get Started"──► [A2: Sign Up]
    │      │                        │
    │      │               ─────────┴──────────
    │      │              │                    │
    │      │         Success             Email exists
    │      │              │                    │
    │      │        [A3: Verify]          Toast error
    │      │              │
    │      │     Email link clicked
    │      │              │
    │      │        [A6: Biometric]
    │      │              │
    │      │        [O1: Welcome]
    │      │              │
    │      │        [O2: Semester Setup]
    │      │              │
    │      │        [O3: Timetable]
    │      │              │
    │      │        [O4: Meet Sprout]
    │      │              │
    │      │──"Sign In"──► [A4: Sign In]──► [H2: Home]
    │      │                    │
    │      │            "Forgot"─► [A5: Reset Pw]
    │
    │
[H2: HOME] ← CORE HUB ─────────────────────────────────────────────
    │
    ├─ Sprout avatar ──────────────────────────────► [M1: Mascot]
    ├─ Next class card ────────────────────────────► [AT2: Subject Detail]
    ├─ Task checkbox (tap) ────────────────────────► Inline done
    ├─ Task card body (tap) ───────────────────────► [P3: Task Detail]
    ├─ Attendance alert ───────────────────────────► [AT2: Subject Detail]
    ├─ Focus button ───────────────────────────────► [F1: Focus Active]
    ├─ Exam week banner ───────────────────────────► [AI1: AI Planner]
    │
    └─ BOTTOM NAV:
         ├─ 🏠 Home ────────────────────────────────► [H2: Home]
         ├─ 📋 Planner ─────────────────────────────► [P1: Planner]
         │        ├─ "+" ──────────────────────────► [P2: Add Task BS]
         │        ├─ Task body ─────────────────────► [P3: Task Detail]
         │        └─ Exam card ─────────────────────► [P4: Exam Detail]
         │                   └─ "AI plan" ──────────► [AI1: AI Planner]
         ├─ ⏱ Focus ────────────────────────────────► [F1: Focus Active]
         │        ├─ Timer done ──────────────────► [F2: Break]
         │        └─ End session ─────────────────► [F3: Complete]
         ├─ 📊 Insights ─────────────────────────────► [I1: Insights]
         │        └─ Attendance arc tap ─────────────► [AT2: Subject Detail]
         └─ 👤 Profile ──────────────────────────────► [S1: Settings]
                  ├─ Notifications ────────────────► [S2: Notif Prefs]
                  ├─ Appearance ────────────────────► [S3: Themes]
                  └─ Sign Out ──────────────────────► [A1: Landing]
```

---

---

## PART 8 — STITCH PROMPT: AUTH SCREEN (Complete Set Summary)

### Quick Reference for Stitch Input Order

When generating screens in Google Stitch, input in this order for best consistency:

```
STEP 1 — Paste Master Design System (from main prompts doc) as global style context

STEP 2 — Generate Auth screens in order:
  1. A1: Landing / Welcome (pre-login)
  2. A2: Sign Up
  3. A3: Email Verification
  4. A4: Sign In
  5. A5: Forgot Password
  6. A6: Biometric Setup

STEP 3 — Generate Onboarding:
  7. O1: Welcome
  8. O2: Semester Setup
  9. O3: Timetable Builder
  10. O4: Meet Sprout

STEP 4 — Generate Core App:
  11. H2: Home Dashboard (Evening — default)
  12. H3: Home — Night Mode
  13. H1: Home — Morning (variation)
  14. AT1: Attendance Overview
  15. AT2: Subject Detail
  16. P1: Planner Main
  17. P2: Add Task (bottom sheet)
  18. P3: Task Detail
  19. F1: Focus Active
  20. F2: Focus Break
  21. F3: Session Complete
  22. M1: Mascot Screen
  23. AI1: AI Planner
  24. I1: Insights
  25. S1: Profile/Settings

STEP 5 — Empty States:
  26. Home Empty
  27. Planner Empty (no tasks)
  28. Planner Empty (all done)
  29. Attendance Empty
  30. Focus Empty

STEP 6 — Special States:
  31. H4: Exam Week Mode
  32. H7: Home Night + Burnout
  33. Widgets Showcase
  34. Notification Examples

TOTAL: 34 unique screen generations
```

---

_This document covers: 6 auth screens + full navigation map + 36 screen states + 8 empty states + 10 bottom sheets + 6 confirmation dialogs + 15 toast types + Sprout emotion matrix + complete Stitch generation order._
