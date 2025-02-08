# Flutter Media Scraper & Video Player

## Overview
This is a **Flutter** application that scrapes websites for different media information, extracts video links from embedded sources, and plays those links using an integrated video player. The app leverages metadata providers like **Kitsu, Jikan, and TMDB** to fetch detailed media info such as trailers, episode details, images, descriptions, and filler information.

---

## Features
- **Scrape websites** for media details and video streaming links.
- **Extract embedded video links** and play them using an in-app video player.
- **Metadata fetching** from Kitsu, Jikan, and TMDB for enriched content details.
- **State management with Bloc & Hydrated Bloc** for persistent state.
- **Favorites & Watch History** with resume playback functionality.
- **Search Page** that searches across all sources.
- **Favorites Page** to manage saved media.
- **Settings Page** to adjust various app options.
- **Skeleton Loading Content

---

## Tech Stack
- **Flutter** (Dart)
- **Bloc & Hydrated Bloc** (State Management & Persistence)
- **HTTP/Web Scraping** (To fetch media data & video links)
- **Video Player** (For streaming extracted video links)

---

## Folder Structure
```
lib/
│── app/
│   ├── bloc/cubit/            # Bloc state management
│   │   ├── active_source_cubit
│   │   ├── favorites_cubit
│   │   ├── settings_cubit
│   │   ├── watch_history_cubit
│   │   └── cubits.dart
│   ├── core/
│   │   ├── utils/              # Utility functions
│   │   │   ├── extractors      # Video link extraction logic
│   │   │   ├── formatters      # Formatting utilities
│   │   │   ├── helpers         # Miscellaneous helpers
│   │   ├── misc/
│   │   ├── network/            # Network-related functions
│   │   ├── values/
│   │   │   ├── constants.dart  # Constant values
│   │   │   ├── regex_patterns.dart  # Regex patterns used for scraping
│   ├── data/
│   │   ├── models/             # Data models
│   │   ├── providers/sources/  # Data sources and scraping logic
│   │   ├── services/           # Services for API interactions
│   ├── screens/
│   │   ├── navigation/         # Different app screens
│   │   │   ├── favorites_screen.dart
│   │   │   ├── home_screen.dart
│   │   │   ├── info_screen.dart
│   │   │   ├── player_screen.dart
│   │   │   ├── player_screen_original.dart
│   │   │   ├── search_screen.dart
│   │   │   ├── settings_screen.dart
│   ├── theme/                  # Theme and UI styles
│   │   ├── app_theme.dart
│   │   ├── color_scheme.dart
│   │   ├── text_theme.dart
│   │   ├── theme_data.dart
│   ├── widgets/                # UI Components
│   │   ├── active_source_manager
│   │   ├── auto_hide_widget
│   │   ├── bottom_sheet
│   │   ├── episode_box
│   │   ├── keep_alive
│   │   ├── player_controls
│   │   ├── skeletons
│   │   ├── swipers
│   │   ├── watch_status_manager
```

---

## Installation & Running the Project
1. Clone the repository:
   ```sh
   git clone https://github.com/wuxnz/mana_debug.git
   cd mana_debug
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Run the application:
   ```sh
   flutter run
   ```

---

## Contribution
Feel free to contribute by opening issues and submitting pull requests!

---

## License
MIT License. See `LICENSE` for details.

