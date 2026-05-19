<div align="center">

# 🌱 Neuroot 
### The AI-Powered Student Operating System

*Study smarter. Live calmer. Grow through college life.*

[![Flutter Version](https://img.shields.io/badge/Flutter-Latest-02569B?logo=flutter)](https://flutter.dev/)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android)](https://www.android.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

</div>

---

## 📖 What is Neuroot?

**Neuroot** is an emotionally intelligent, AI-powered productivity ecosystem designed specifically for modern students. It's not just another timetable or to-do app; it acts as a smart semester planner, attendance tracker, AI study assistant, focus companion, and a calm emotional support system—all seamlessly integrated into one cozy mobile experience.

Our core philosophy: **"Help students survive and grow through college life without burnout."**

---

## ✨ Core Features

### 🎓 Academic Management
* **Smart Timetable:** Dynamic, offline-first scheduling with rotating schedules and color-coded subjects.
* **Attendance System:** Real-time percentage tracking, safe leave calculation, and AI-driven risk prediction.
* **Assignment Manager:** Smart prioritization, submission reminders, and progress tracking.

### 🤖 AI Planning System (Powered by Gemini)
* **Study Coach:** Generates daily study plans, revision cycles, and spaced repetition schedules based on syllabus and exam dates.
* **Microtask Generator:** Breaks down large tasks ("Study Operating Systems") into manageable, bite-sized microtasks.

### 💖 Emotional Productivity
* **Daily Check-ins:** Lightweight emotional prompts to gauge energy and stress levels.
* **Adaptive Workload:** Adjusts task volume and UI tone automatically to prevent burnout.
* **Guilt-Free UX:** Replaces toxic hustle culture with gentle consistency and sustainable growth.

### 🎯 Focus Ecosystem
* **Deep Work Mode:** Built-in Pomodoro timer, distraction blocking, and focus analytics.
* **Sprout (Your Mascot Companion):** A virtual companion that grows and reacts emotionally based on your focus sessions, task completions, and attendance consistency.

---

## 🛠 Tech Stack

### Frontend (Mobile App)
* **Framework:** [Flutter](https://flutter.dev/) (Android First)
* **Language:** Dart
* **State Management:** Riverpod
* **Routing:** GoRouter
* **Local Storage:** Hive
* **Animations:** Rive, Lottie, Flutter Animate

### Backend
* **Environment:** Node.js + TypeScript
* **Framework:** Express.js
* **BaaS:** [Firebase](https://firebase.google.com/) (Auth, Firestore, Storage, Cloud Functions, Cloud Messaging)

### AI & Intelligence
* **Model:** Google Gemini API (Vertex AI)
* **Orchestration:** LangChain.js
* **Vector DB:** Pinecone

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (Latest Stable)
* Android Studio / VS Code
* Node.js & npm (for backend services)
* Firebase CLI

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/neuroot.git
   cd neuroot
   ```

2. **Install Flutter Dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Firebase**
   * Create a project in the Firebase Console.
   * Add an Android app and place the `google-services.json` file in `android/app/`.
   * Ensure Firestore, Authentication, and Storage are enabled.

4. **Environment Variables**
   * Create a `.env` file in the root directory.
   * Add your API keys (Gemini API, Firebase config, etc.).

5. **Run the App**
   ```bash
   flutter run
   ```

---

## 🧠 Architecture Overview

Neuroot follows a modular, feature-based, offline-first architecture:

```text
Flutter App (UI, State, Local DB via Hive)
    │
    ▼
Firebase Services (Auth, Realtime Sync via Firestore)
    │
    ▼
Node.js Backend (Business Logic, Cloud Functions)
    │
    ▼
AI Services Layer (Gemini API, LangChain, Pinecone)
```

---

## 🎨 Design Philosophy
Neuroot embraces a **Cozy Productivity** aesthetic:
* Soft Glassmorphism
* Modern Gen Z Minimalism
* Rounded UI elements with warm shadows
* Intelligent, context-aware adaptive UI (e.g., shifts to a darker, focused UI during exams or a softer, calming UI during high stress).

---

## 🤝 Contributing
We welcome contributions! Please follow our [Contribution Guidelines](CONTRIBUTING.md) and adhere to the project's code of conduct.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License
Distributed under the MIT License. See `LICENSE` for more information.

---
<div align="center">
  <i>Made with ❤️ for students everywhere.</i>
</div>
