# Notisboard Project Setup Guide

This guide provides step-by-step instructions for setting up the Notisboard project, which includes a Node.js Backend, a Next.js Admin Panel, and a Flutter application for Android and iOS.

---

## 1. Backend Setup (Node.js/Express)
**Path:** `sourcecode/admin/backend/`

The backend provides the REST API, database connectivity (MongoDB), and socket services for real-time features.

### Prerequisites
- [Node.js](https://nodejs.org/)
- [MongoDB](https://www.mongodb.com/) (Local or Atlas database)

### Installation & Run
1. Navigate to the backend directory:
   ```bash
   cd sourcecode/admin/backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Environment Configuration:
   - Ensure your `.env` file (`sourcecode/admin/backend/.env`) contains the correct configuration (e.g., Database URI, JWT Secrets, Firebase credentials, etc.).
4. Start the server (runs via Nodemon for hot-reloading):
   ```bash
   npm start
   ```

---

## 2. Admin Panel Setup (Next.js/React)
**Path:** `sourcecode/admin/frontend/`

The admin panel is a robust frontend built with Next.js 15 and Material-UI (Vuexy Template).

### Prerequisites
- Node.js

### Installation & Run
1. Navigate to the frontend directory:
   ```bash
   cd sourcecode/admin/frontend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
   *(If you face peer dependency errors, try `npm install --legacy-peer-deps`)*
3. Environment Configuration:
   - Create a `.env.local` or update existing environment files to connect to your backend API URL.
4. Start the development server:
   ```bash
   npm run dev
   ```
   *The admin panel will start on port `5001` (accessible at `http://localhost:5001`).*

---

## 3. Mobile App Setup (Android & iOS)
**Path:** `sourcecode/flutterapp/talkin/`

The mobile application is built using the Flutter framework.

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and configured.
- Run `flutter doctor` in your terminal to ensure Android Studio and Xcode are set up correctly.
- CocoaPods (for iOS dependencies).

### Common Setup
1. Navigate to the Flutter app directory:
   ```bash
   cd sourcecode/flutterapp/talkin
   ```
2. Install Flutter packages:
   ```bash
   flutter pub get
   ```

### Running on Android
1. Open an Android Emulator or connect a physical Android device.
2. Build and run the app:
   ```bash
   flutter run
   ```
   *(Select your Android device if prompted).*

### Running on iOS (macOS required)
1. Install iOS-specific dependencies (CocoaPods):
   ```bash
   cd ios
   pod install --repo-update
   cd ..
   ```
   *(If you are on an Apple Silicon Mac and face issues, you might need to use `arch -x86_64 pod install`)*
2. Development Team setup (For physical devices or release builds):
   - Open the iOS project in Xcode: `open ios/Runner.xcworkspace`
   - Select the `Runner` target, go to **Signing & Capabilities**, and assign your Apple Developer Team.
3. Build and run the app:
   ```bash
   flutter run
   ```
   *(Select your iOS Simulator or physical iPhone if prompted).*

---

### General Troubleshooting
- **Flutter Build Issues:** Run `flutter clean` then `flutter pub get` to reset the build cache.
- **Node Modules Issues:** If backend or frontend behaves unexpectedly, delete the `node_modules` folder and `package-lock.json`, then run `npm install` again.
