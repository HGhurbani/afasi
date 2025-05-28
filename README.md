# Azkar Alafasi App (أذكار وأدعية العفاسي)

[![Flutter Version](https://img.shields.io/badge/Flutter-^3.6.0-blue.svg)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-brightgreen)](https://flutter.dev)

The "Azkar Alafasi App" is a comprehensive application developed using Flutter, designed to provide a wide range of Azkar (remembrances), Duas (supplications), Quranic recitations, and Anasheeds (Islamic songs) by Sheikh Mishary Rashid Alafasi. Additionally, the app includes useful Islamic features such as prayer times, Azkar reminders, an electronic Tasbih counter, and Islamic wallpapers.

## 🌟 Key Features

- **📖 Holy Quran:** Listen to selected Quranic recitations by Sheikh Mishary Alafasi with accompanying Quranic text display.
- **🎶 Anasheeds:** A diverse collection of purposeful Islamic Anasheeds.
- **📿 Azkar and Supplications:**
    - Morning and Evening Azkar with audio alerts.
    - Various supplications for different occasions (travel, entering the market, entering the mosque, waking up, for the deceased, for rain, for children, for solar eclipse, and for completing the Quran).
    - Audio and textual Ruqyah Sharia (Islamic healing).
- **⏰ Azkar Reminders:** Schedule audio reminders for Morning and Evening Azkar at your preferred times.
- **🕌 Prayer Times:**
    - Accurate display of prayer times based on your geographical location.
    - Notifications to alert you to prayer times.
- **📿 Electronic Tasbih:** A digital counter to help you with your Tasbih.
- **🖼️ Islamic Wallpapers:** Browse and download various Islamic wallpapers, with the ability to set them as your phone's wallpaper.
- **🎧 Advanced Audio Player:**
    - Play audio from local sources or online (including YouTube links).
    - Download audio for offline listening.
    - Synchronized text display for many supplications and Azkar.
    - Playback controls (forward, rewind, pause, play).
    - **Sleep Timer:** Set a timer to automatically stop audio playback after a specified duration.
    - **Auto-Next & Repeat:** Options to automatically play the next track or repeat the current track.
- **❤️ Favorites:** Add your preferred audio tracks to a favorites list for quick access.
- **🔍 Search:** Easily search for any Dhikr, Dua, or Nasheed within the different categories.
- **🎨 Customizable Interface:**
    - Support for Light and Dark modes.
    - Ability to increase or decrease font size on the text reader page.
- **🌍 Multi-Platform Support:** Built with Flutter, allowing it to run on Android, iOS, Web, Windows, macOS, and Linux.
- **💰 Monetization:** The app includes AdMob ads to support its development and sustainability, while respecting user experience and displaying User Messaging Platform (UMP) consent forms.
- **🔔 Firebase Notifications:** Receive important notifications and updates.

## 📸 Screenshots

*(Add screenshots of the application interfaces here)*
*Example:*
* ```<img src="path/to/screenshot1.png" width="200"/> <img src="path/to/screenshot2.png" width="200"/>``` *

## 🛠️ Technologies Used

- **Framework:** Flutter
- **Programming Language:** Dart
- **State Management:** (Please specify the state management approach used if clear from the code, e.g., Provider, BLoC, Riverpod, GetX, setState)
- **Audio:**
    - `just_audio`: For audio playback.
    - `youtube_explode_dart`: To extract audio links from YouTube.
- **Notifications:**
    - `flutter_local_notifications`: For local notifications (Azkar reminders, prayer times).
    - `firebase_messaging`: For receiving push notifications.
    - `firebase_in_app_messaging`: For in-app messages.
- **Local Storage:**
    - `shared_preferences`: To save user settings (theme, favorites, reminder settings).
    - `path_provider`: To access file paths (for storing downloaded audio).
- **Networking:**
    - `http`: For making network requests (e.g., fetching wallpapers).
    - `connectivity_plus`: To check internet connectivity status.
    - `xml`: For parsing XML data (for image blog feeds).
- **Location and Time Services:**
    - `geolocator`: To determine user location (for prayer times).
    - `adhan`: To calculate prayer times.
    - `timezone`: For handling time zones.
- **Permissions:**
    - `permission_handler`: For requesting permissions (notifications, location, storage).
- **Ads:**
    - `google_mobile_ads`: For displaying AdMob ads (banner, interstitial, native, and rewarded).
    - `user_messaging_platform`: For managing user consent for ads.
- **UI & Utilities:**
    - `flutter_localization`: For multi-language support (the app currently focuses on Arabic).
    - `url_launcher`: To open external links (e.g., rate app, privacy policy).
    - `font_awesome_flutter`: For a variety of icons.
    - `share_plus`: For sharing images (wallpapers).
    - `wallpaper_manager_flutter`: For setting images as device wallpapers.
- **Analytics:**
    - `firebase_core`: For initializing Firebase services.
- **Development Tools:**
    - `flutter_lints`: To ensure code quality and adherence to best practices.

## 🚀 Setup and Installation

To run this project locally, follow these steps:

1.  **Clone the Repository:**
    ```bash
    git clone [https://github.com/hghurbani/afasi.git](https://github.com/hghurbani/afasi.git)
    cd afasi
    ```

2.  **Install Flutter:** Ensure you have the [Flutter SDK](https://flutter.dev/docs/get-started/install) installed and configured correctly.

3.  **Firebase Setup:**
    * **Android:** Place your `google-services.json` file from your Firebase project into the `android/app/` directory.
    * **iOS:** Configure the `GoogleService-Info.plist` file in Xcode.

4.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

5.  **Run the Application:**
    ```bash
    flutter run
    ```
    You can specify a particular device or emulator to run the app on.

## 📋 How to Use

-   **Browse:** Upon opening the app, you will see a list of main audio categories (Holy Quran, Anasheeds, Azkar, Supplications, Ramadan, Ruqyah Sharia). You can use the search bar at the top to filter content within the selected category.
-   **Side Menu (Drawer):** Swipe from left to right (or tap the menu icon) to open the side menu. From here, you can navigate between different categories, access your favorites, Azkar reminders, prayer times, the electronic Tasbih, the wallpapers section, and support the app.
-   **Playing Audio:**
    * Tap on any item in the list to play it. If the audio requires an internet connection and has not been previously downloaded, it will be streamed directly (or extracted if from a source like YouTube).
    * A mini-player appears at the bottom of the screen when any audio is playing, featuring basic controls and a progress bar.
-   **Downloading Audio:** Tap the download icon next to any audio track (if it's not already local or downloaded) to save it to your device for offline listening. The download icon will turn gray to indicate that the audio is available offline.
-   **Reading Texts:** Press the "Read" button in the audio player to display the accompanying text for the audio material (if available), with options to increase or decrease the font size.
-   **Favorites:** Tap the heart icon ❤️ next to any track to add or remove it from your favorites list.
-   **Support the App:** You can support the app's development by watching a rewarded ad. Access this option by tapping the heart icon 💖 in the top app bar or from the side menu.
-   **Instructions and Privacy Policy:** These can be accessed from the side menu or the information icon in the app bar.

## 🤝 Contributing

Contributions are always welcome to improve this application! If you'd like to contribute:

1.  Fork this repository.
2.  Create a new branch for your features (`git checkout -b feature/AmazingFeature`).
3.  Make the necessary changes and commit them (`git commit -m 'Add some AmazingFeature'`).
4.  Push your changes to the branch (`git push origin feature/AmazingFeature`).
5.  Open a Pull Request.

Please ensure you follow coding and contribution guidelines (if provided).

## 📜 License

This project is licensed under the MIT License. See the `LICENSE` file (if present) for more details.
(Assuming MIT License, as no license file was specified in the repository).

## 📞 Contact

-   **Developer:** Hazem Al-Hatti
-   **Email:** hazemhataki@gmail.com

---

We hope this application will be a source of benefit and light for you. Please remember us in your prayers.
