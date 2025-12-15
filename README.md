🎵 Music App

A clean and lightweight Flutter Music Player App inspired by Spotify.
The app focuses on smooth audio playback, playlist queue, and a mini player experience using a single audio engine.

🚀 Features

🎧 Stream music from a remote JSON API

▶️ Play / Pause / Next track

⏪ Skip backward 10 seconds

⏩ Skip forward 10 seconds

🎚 Seek any position using slider

🔁 Auto loop playlist (restart after last song)

📜 Queue-based playback

🎛 Mini Player with synced controls

🎨 Smooth Spotify-like animations

🔄 Pull to refresh song list

🔐 Firebase Authentication (Login / Logout)

🛠 Technologies Used

Flutter

Dart

Firebase Authentication

just_audio

REST API (HTTP)

📂 Project Structure
lib/
├── models/
│   └── song.dart
├── services/
│   └── music_api_service.dart
├── screens/
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── splash_screen.dart
│   └── developers_screen.dart
├── auth.dart
└── main.dart

▶️ Audio Logic

Uses a single AudioPlayer

Songs are played using a playlist queue

Player state is synced using streams

UI updates automatically based on playback state

📄 Notes

This project is for educational purposes

Build and cache files are excluded using .gitignore