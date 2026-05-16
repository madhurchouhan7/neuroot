# Neuroot — Product Requirements Document (PRD) 🌱

Version: v1 Draft  
Project Name: Neuroot — AI Powered Student Operating System  
Document Type: Product Requirements Document (PRD)  
Primary Platform: Android  
Future Platforms: iOS

---

# 1. Product Overview

Neuroot is an AI-powered student productivity ecosystem designed to help students manage:

- academics,
- focus,
- attendance,
- emotional wellbeing,
- and daily planning

inside one emotionally intelligent platform.

Neuroot combines:

- student planner,
- attendance tracker,
- AI study assistant,
- focus app,
- emotional productivity system,
- and companion-based gamification.

The product is built specifically for:

- Indian college students,
- engineering students,
- Gen Z users,
- overwhelmed students,
- ADHD-friendly workflows.

---

# 2. Product Vision

## Vision Statement

> "Create the most emotionally intelligent student operating system."

Neuroot should:

- reduce academic overwhelm,
- help students stay organized,
- support emotional wellbeing,
- improve consistency,
- and make productivity feel safe and sustainable.

---

# 3. Product Goals

# 3.1 Primary Goals

- Help students manage semester life easily.
- Reduce burnout and overwhelm.
- Improve focus consistency.
- Track attendance intelligently.
- Provide AI-powered study planning.
- Create emotional attachment through Sprout mascot.
- Deliver a cozy and adaptive productivity experience.

---

# 3.2 Success Metrics

## Retention Metrics

- Day 1 retention > 65%
- Day 7 retention > 40%
- Day 30 retention > 25%

## Engagement Metrics

- Average daily opens > 4
- Average focus sessions/week > 10
- Average task completion rate > 60%

## Emotional Metrics

- Users report reduced overwhelm
- Users feel emotionally supported
- Users build daily habits

---

# 4. Target Users

# 4.1 Primary Users

## Engineering Students

Pain Points:

- attendance pressure,
- assignments,
- exam stress,
- poor planning,
- burnout.

---

## ADHD-Friendly Productivity Users

Pain Points:

- task overwhelm,
- executive dysfunction,
- poor prioritization,
- difficulty breaking tasks down.

---

## Gen Z Students

Needs:

- aesthetic UI,
- emotional safety,
- personalization,
- adaptive systems,
- gamification.

---

# 4.2 Secondary Users

- school students,
- medical students,
- competitive exam aspirants,
- self-improvement users.

---

# 5. Core Product Pillars

Neuroot is built on 5 main pillars:

## 1. Academic Management

- timetable,
- attendance,
- assignments,
- exams,
- semester organization.

---

## 2. AI Productivity

- study planning,
- adaptive schedules,
- microtasks,
- AI insights,
- revision planning.

---

## 3. Emotional Productivity

- burnout reduction,
- emotional check-ins,
- supportive UX,
- mental wellness integration.

---

## 4. Focus Ecosystem

- Pomodoro,
- distraction reduction,
- focus analytics,
- deep work support.

---

## 5. Companion Gamification

- Sprout mascot,
- progression,
- emotional interactions,
- cozy rewards.

---

# 6. Functional Requirements

# 6.1 Authentication System

## Features

- Google Login
- Email Login
- Session Persistence
- Secure Logout

## Requirements

- Authentication must complete within 3 seconds.
- User session should persist securely.
- Passwords should never be stored locally.

---

# 6.2 Onboarding System

## Requirements

User should be able to:

- setup semester,
- add subjects,
- choose goals,
- set emotional preferences,
- personalize dashboard.

## Constraints

- onboarding time < 3 minutes,
- low friction,
- minimal forms.

---

# 6.3 Semester Management

## Features

- create semesters,
- edit semesters,
- semester timeline,
- subject organization,
- semester switching.

## Data Fields

```txt id="m0f8dq"
Semester Name
Start Date
End Date
Subjects
Credits
Goals
```

---

# 6.4 Subject Management

## Features

- create subjects,
- assign colors,
- attendance tracking,
- notes,
- assignments,
- faculty info.

## Subject Data

```txt id="f1r8we"
Subject Name
Code
Faculty
Attendance %
Credits
Class Schedule
Room Number
```

---

# 6.5 Timetable System

## Features

- weekly timetable,
- rotating schedules,
- lab classes,
- recurring classes,
- widgets,
- reminders.

## Requirements

- offline access,
- fast rendering,
- color-coded subjects.

---

# 6.6 Attendance Tracking System

## Core Features

- attendance percentage,
- safe leave calculator,
- class-wise tracking,
- attendance analytics,
- attendance warnings,
- attendance trends.

## Smart Features

- attendance prediction,
- shortage alerts,
- AI recommendations.

## Important Requirement

Attendance calculations must update instantly.

---

# 6.7 Assignment Management

## Features

- assignment creation,
- due dates,
- progress tracking,
- priorities,
- reminder scheduling,
- submission tracking.

## AI Features

- estimated completion time,
- microtask generation,
- priority recommendations.

---

# 6.8 Exam Management

## Features

- exam scheduling,
- countdowns,
- syllabus tracking,
- revision planner,
- exam mode activation.

## Requirements

- adaptive dashboard during exams,
- smart reminders,
- priority-based study planning.

---

# 6.9 Task Management System

## Features

- task creation,
- recurring tasks,
- subtasks,
- smart priorities,
- completion streaks,
- categorized tasks.

## AI Features

- microtask breakdown,
- schedule optimization,
- adaptive rescheduling.

---

# 6.10 AI Study Planner

## Inputs

```txt id="2dr1jd"
Exam Dates
Syllabus
Study Hours
Weak Topics
Attendance Status
Task Load
```

## Outputs

- daily study plans,
- revision schedules,
- adaptive priorities,
- microtasks,
- study recommendations.

## Requirements

- AI responses under 8 seconds,
- structured output,
- emotionally safe tone.

---

# 6.11 Focus Mode

## Features

- Pomodoro timer,
- deep work mode,
- study ambience,
- focus analytics,
- app blocking,
- focus streaks.

## UX Requirements

- distraction-free UI,
- fullscreen support,
- calming animations.

---

# 6.12 Emotional Check-in System

## Features

- daily mood check-ins,
- energy tracking,
- stress detection,
- emotional trends,
- burnout indicators.

## Mood Inputs

```txt id="3px6vl"
Happy
Focused
Tired
Overwhelmed
Burned Out
Calm
Anxious
```

## Requirements

- lightweight interactions,
- optional participation,
- non-invasive experience.

---

# 6.13 Sprout Companion System

## Features

- emotional states,
- reactions,
- animations,
- progression,
- growth system.

## Requirements

Sprout should:

- feel alive,
- react contextually,
- never shame users.

---

# 6.14 Notification System

## Features

- smart reminders,
- grouped notifications,
- attendance alerts,
- focus reminders,
- emotional reminders.

## Rules

- no spam,
- context-aware timing,
- emotional-safe language.

---

# 6.15 Dashboard System

## Dashboard Sections

- greeting,
- today's classes,
- top priorities,
- focus progress,
- attendance alerts,
- exam countdowns,
- Sprout widget.

## Requirements

- fast loading,
- low clutter,
- adaptive layout.

---

# 6.16 Analytics System

## Features

- productivity analytics,
- attendance analytics,
- focus analytics,
- emotional trends,
- semester insights.

## Requirements

Insights should:

- feel helpful,
- not judgmental,
- visually simple.

---

# 7. Non-Functional Requirements

# 7.1 Performance Requirements

## App Launch

```txt id="l8yw5o"
Cold Start < 3 sec
Warm Start < 1 sec
```

## UI Performance

```txt id="v0ec8r"
60 FPS minimum
Smooth animations
Low frame drops
```

## API Performance

```txt id="if6mb8"
AI Response < 8 sec
Firestore Queries < 1 sec
Sync < 2 sec
```

---

# 7.2 Offline Requirements

App must support:

- offline timetable,
- offline tasks,
- offline attendance,
- local caching,
- delayed syncing.

---

# 7.3 Scalability Requirements

System should support:

- 100k+ active users initially,
- realtime sync,
- AI processing scalability,
- notification scalability.

---

# 7.4 Security Requirements

## Data Security

- encrypted authentication,
- secure tokens,
- protected APIs,
- Firebase security rules.

## Privacy Requirements

- emotional data privacy,
- AI conversation privacy,
- no unauthorized data sharing.

---

# 7.5 Accessibility Requirements

Support:

- large fonts,
- reduced motion,
- screen readers,
- colorblind users,
- dark mode.

---

# 8. UX Requirements

# 8.1 Emotional UX Rules

The app must:

- feel calming,
- reduce stress,
- avoid guilt,
- support recovery.

Avoid:

- aggressive productivity language,
- harsh notifications,
- overwhelming dashboards.

---

# 8.2 Adaptive UI Requirements

UI should adapt based on:

- exams,
- stress,
- focus,
- burnout,
- nighttime usage.

---

# 8.3 Motion Requirements

Animations should:

- be smooth,
- lightweight,
- emotionally expressive,
- non-distracting.

---

# 9. AI Requirements

# 9.1 AI Personality

AI tone must be:

- supportive,
- calm,
- intelligent,
- emotionally aware.

Avoid:

- robotic tone,
- toxic motivation,
- guilt language.

---

# 9.2 AI Safety Rules

AI must NEVER:

- shame students,
- promote unhealthy study habits,
- encourage burnout,
- manipulate emotions negatively.

---

# 9.3 AI System Features

## AI Modules

- Study Planner
- Attendance Advisor
- Burnout Detector
- Revision Planner
- Microtask Generator
- Smart Scheduler

---

# 10. Technical Requirements

# 10.1 Frontend

Required Stack:

```txt id="utx30z"
Flutter
Riverpod
GoRouter
Hive
Rive
Firebase SDK
```

---

# 10.2 Backend

Required Stack:

```txt id="4r3k1m"
Node.js
Express.js
TypeScript
Firebase
Firestore
Cloud Functions
```

---

# 10.3 AI Stack

Required:

```txt id="21t25n"
Gemini API
LangChain.js
Pinecone
```

---

# 11. MVP Scope

# 11.1 MVP Features

## Included

- authentication,
- onboarding,
- semester setup,
- timetable,
- attendance tracking,
- assignments,
- dashboard,
- focus timer,
- emotional check-ins,
- basic AI planner,
- Sprout companion.

---

## Excluded Initially

- social systems,
- collaborative study rooms,
- LMS integrations,
- web app,
- advanced AI memory,
- voice assistant,
- marketplace.

---

# 12. Monetization Requirements

## Free Tier

Includes:

- planner,
- attendance,
- focus timer,
- basic AI,
- dashboard.

---

## Premium Tier

Includes:

- advanced AI planning,
- analytics,
- premium themes,
- Sprout customization,
- advanced widgets,
- cloud backups.

---

# 13. Analytics Requirements

Track:

- retention,
- onboarding completion,
- focus sessions,
- AI usage,
- attendance usage,
- task completion,
- emotional engagement.

Important:
Analytics must remain privacy-friendly.

---

# 14. Failure Handling Requirements

System must gracefully handle:

- no internet,
- API failures,
- AI timeouts,
- sync conflicts,
- notification failures.

App should NEVER feel broken.

---

# 15. Future Expansion Requirements

Future support for:

- LMS integrations,
- AI notes,
- spaced repetition,
- placement preparation,
- internship tracker,
- collaborative study groups,
- desktop support.

---

# 16. Constraints

## Budget Constraints

- low-cost infrastructure,
- scalable cloud usage,
- optimized AI requests.

## Technical Constraints

- low-end Android support,
- offline-first behavior,
- battery optimization.

---

# 17. Success Definition

Neuroot succeeds if students:

- feel calmer,
- stay more organized,
- reduce overwhelm,
- maintain attendance,
- focus consistently,
- and emotionally connect with the app.

---

# 18. Final Product Goal

Neuroot should become:

> "The emotional operating system for student life."

Not just:

- a planner,
- a productivity app,
- or a focus timer.

But a system students genuinely trust daily.

---

# 19. Final PRD Summary

Neuroot combines:

- academic management,
- AI productivity,
- emotional wellness,
- focus systems,
- and adaptive UX

into one cohesive ecosystem.

The product should:

- feel alive,
- reduce stress,
- improve consistency,
- and help students grow sustainably.

---

# 20. Final Product Mantra

> "Help students survive college life without burning out 🌱"
