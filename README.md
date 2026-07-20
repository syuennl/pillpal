# PillPal 💊

PillPal is a comprehensive Flutter-based medication management and adherence tracking application. It empowers patients to keep track of their medications with smart reminders, while allowing caregivers to monitor adherence and intervene when necessary.

## 🌟 Key Features

- **AI-Powered OCR**: Automatically extract medication details (name, dosage, expiry date etc.) by simply taking a picture of the pill box (powered by Google Gemini).
- **Smart Medication Reminders**: Schedule daily, specific day, or as-needed medication reminders.
- **Adherence Tracking**: Visual dashboards and historical logs for monitoring medication adherence rates.
- **Caregiver Connectivity**: Link patients with primary and secondary caregivers using secure invite codes.
- **Missed Dose Alerts**: Caregivers receive push notifications when a patient misses a scheduled medication dose.

## 🛠 Prerequisites

Before you begin, ensure you have met the following requirements:
* [Flutter SDK](https://docs.flutter.dev/get-started/install) installed (version 3.19.0 or higher recommended)
* Android Studio installed
* A [Firebase](https://firebase.google.com/) account and project
* A [Gemini API Key](https://aistudio.google.com/app/apikey) (for the AI OCR feature)

## 🚀 Setup & Installation

### 1. Clone the repository
```bash
git clone https://github.com/syuennl/pillpal.git
cd pillpal
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Environment Variables
Create a `.env` file in the root of the project and add your API key:
```env
GEMINI_API_KEY=your_gemini_api_key_here
```

### 4. Firebase Configuration
This project relies heavily on Firebase (Authentication, Firestore, Cloud Functions, and Cloud Messaging). 

1. Create a project in the Firebase Console.
2. Register an Android app in your Firebase project.
3. Download the `google-services.json` file and place it in the `android/app/` directory.
4. Ensure your Firestore rules are set up securely (refer to `/firestore.rules`).

### 5. Deploy Cloud Functions
The app uses Firebase Cloud Functions to process missed dose logic and send FCM push notifications to caregivers.   
To deploy them:

```bash
# Navigate to the functions directory
cd functions

# Install node dependencies
npm install

# Deploy the functions to your Firebase project
firebase deploy --only functions
```

## 📱 Running the App

To run the application locally on an emulator or connected device, use:
```bash
flutter run
```

## 📦 Building for Production (Android APK)

If you want to generate an installable Android `.apk` file for testing on physical devices:
```bash
flutter build apk
```
The compiled APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

## 📁 Architecture Overview

- **`lib/screens/`**: UI screens categorised by feature (login, home, medication, history, caregiver, profile).
- **`lib/services/`**: Backend integration logic (AuthService, FcmService, CaregiverService, OCRService etc.).
- **`lib/widgets/`**: Reusable UI components (buttons, cards, forms).
- **`lib/models/`**: Data models (Medication, CaregiverRelationship, HistoryRecord etc.).
- **`lib/utils/`**: Helper files and app-wide constants (colors, globals).
- **`functions/`**: Node.js Firebase Cloud Functions for backend automation.
