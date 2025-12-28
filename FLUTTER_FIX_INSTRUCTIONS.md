# Flutter Dependency Fix Instructions

## Problem
Flutter tools depends on `test` package version that doesn't exist, causing version solving failures.

## Solution: Reinstall Flutter

### Option 1: Fresh Flutter Installation (Recommended)

1. **Download Latest Flutter SDK:**
   - Go to https://flutter.dev/docs/get-started/install/windows
   - Download the latest stable Flutter SDK ZIP file

2. **Backup Current Flutter (Optional):**
   ```powershell
   Rename-Item C:\src\flutter C:\src\flutter_backup
   ```

3. **Extract New Flutter:**
   - Extract the downloaded ZIP to `C:\src\flutter`
   - Or extract to a new location and update your PATH

4. **Update PATH:**
   - Add `C:\src\flutter\bin` to your system PATH
   - Restart your terminal/IDE

5. **Verify Installation:**
   ```powershell
   flutter doctor
   flutter pub get
   ```

### Option 2: Fix Current Installation

1. **Stop All Flutter Processes:**
   - Close all terminals and IDEs using Flutter

2. **Delete Flutter Cache:**
   ```powershell
   Remove-Item -Path "$env:LOCALAPPDATA\Pub\Cache" -Recurse -Force
   Remove-Item -Path "$env:APPDATA\Pub\Cache" -Recurse -Force
   ```

3. **Update Flutter from Git (if installed via git):**
   ```powershell
   cd C:\src\flutter
   git fetch
   git checkout stable
   git pull
   ```

4. **Rebuild Flutter Tools:**
   ```powershell
   cd C:\src\flutter
   .\bin\flutter.bat precache
   ```

### Option 3: Use Flutter Version Manager (fvm)

1. **Install fvm:**
   ```powershell
   dart pub global activate fvm
   ```

2. **Install Specific Flutter Version:**
   ```powershell
   fvm install stable
   fvm use stable
   ```

## Current Temporary Fix Applied

I've updated `C:\src\flutter\packages\flutter_tools\pubspec.yaml` to use `test: 1.25.13` instead of `1.25.15`. However, this is a temporary fix and may be overwritten when Flutter updates.

## After Fixing

Once Flutter is working:
```powershell
cd C:\Users\esmao\OneDrive\BAP\Dixlearning
flutter clean
flutter pub get
flutter run
```

