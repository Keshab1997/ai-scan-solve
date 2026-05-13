# AI Scan & Solve 📱✨

**AI-powered Bengali text extractor from images** — built with Flutter and Google Gemini API.

## Features

- 📸 **Camera & Gallery** — Capture or select images of question papers
- 🧠 **AI Text Extraction** — Uses Google Gemini 1.5 Flash to extract Bengali text
- 📝 **Structured Output** — Automatically separates questions and answers with numbering
- 📋 **Copy & Share** — One-tap copy to clipboard or share via WhatsApp, Messenger, etc.
- 💾 **Local History** — All scanned results saved locally with Hive (offline support)
- 🌐 **Web & Mobile** — Works on Android, iOS, and web browsers

## Setup

### 1. Prerequisites
- Flutter SDK 3.0+
- Dart SDK 3.0+

### 2. Get Gemini API Key
1. Go to [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Create a free API key
3. Replace `YOUR_GEMINI_API_KEY` in `lib/services/gemini_service.dart`

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Run
```bash
# Mobile
flutter run

# Web
flutter build web --web-renderer canvaskit --release
```

## Project Structure

```
lib/
├── main.dart                  # App entry with Hive init
├── models/
│   ├── scan_result.dart       # Hive-annotated data model
│   └── scan_result.g.dart     # Manual TypeAdapter
├── screens/
│   ├── home_screen.dart       # History list + FAB
│   ├── scan_screen.dart       # Camera/Gallery + AI processing
│   └── result_screen.dart     # Result view with actions
├── services/
│   ├── gemini_service.dart    # Gemini API integration
│   └── database_service.dart  # Hive local storage
└── widgets/
    └── history_card.dart      # Reusable history card
```

## Tech Stack

| Component | Technology |
|---|---|
| Framework | Flutter 3.x |
| AI Engine | Google Gemini 1.5 Flash |
| Local DB | Hive (web + mobile compatible) |
| Image Picker | image_picker |
| Share | share_plus |
| Toasts | fluttertoast |

## Cost

- **Gemini API:** Free tier (15 req/min)
- **Hosting:** Free (GitHub Pages / Firebase)
- **Total:** $0

## License

MIT License — feel free to use and modify!