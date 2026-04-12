# 🎬 Movie Explorer

A beautifully crafted **Flutter** application for discovering, searching, and saving your favorite movies — powered by the [TMDB API](https://www.themoviedb.org/).

---

## ✨ Features

| Feature | Description |
|---|---|
| 🔐 **Authentication** | Login with DummyJSON auth — persists session via `SharedPreferences` |
| 🌗 **Theme Toggle** | Seamless Dark / Light mode switch, saved locally |
| 🏠 **Home Screen** | Three curated sections: New Movies, Trending Now, Top Rated |
| ♾️ **Infinite Scroll** | Auto-loads more movies as you scroll horizontally in each section |
| 🔍 **Discover & Search** | Real-time movie search with paginated results |
| ❤️ **Favorites** | Add/remove favorites, persisted locally across sessions |
| 🎞️ **Movie Details** | Full detail page with poster, overview, rating, release date, and favorite toggle |
| 🚀 **Splash Screen** | Animated splash that auto-navigates based on session state |

---

## 🏗️ Architecture

The app follows a clean **Provider-based** state management architecture:

```
lib/
├── core/
│   ├── api_client.dart        # Dio HTTP client setup
│   ├── constants.dart         # API keys, URLs, SharedPreferences keys
│   └── theme.dart             # Light & Dark ThemeData definitions
├── models/
│   ├── movie.dart             # Movie data model (fromJson / toJson)
│   └── user.dart              # User data model
├── providers/
│   ├── auth_provider.dart     # Login / logout state
│   ├── movie_provider.dart    # Movies, search, favorites state
│   └── theme_provider.dart    # Theme toggle state
├── screens/
│   ├── splash_screen.dart     # Entry point with auth check
│   ├── login_screen.dart      # Login form with validation
│   ├── main_screen.dart       # Bottom nav scaffold
│   ├── home_screen.dart       # Horizontal movie lists with infinite scroll
│   ├── discover_screen.dart   # Search screen with paginated results
│   ├── favorites_screen.dart  # Saved favorites list
│   └── movie_details.dart     # Full movie detail page
└── services/
    ├── auth_service.dart      # Auth API calls
    ├── movie_service.dart     # TMDB API calls (trending, now playing, top rated, search)
    └── local_storage.dart     # SharedPreferences helpers
```

---

## 🛠️ Tech Stack

- **Flutter** `^3.x` / **Dart** `^3.11.3`
- **Provider** `^6.1.5` — State management
- **Dio** `^5.9.2` — HTTP client
- **SharedPreferences** `^2.5.5` — Local persistence
- **flutter_form_builder** `^10.3.0` — Form handling
- **form_builder_validators** `^11.3.0` — Input validation
- **flutter_dotenv** `^6.0.0` — Environment variable management
- **TMDB API** — Movie data source
- **DummyJSON** — Mock authentication backend

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and configured
- A free [TMDB API key](https://www.themoviedb.org/settings/api)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/youssef1232004/movie_explorer.git
   cd movie_explorer
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**

   Create a `.env` file in the project root:
   ```env
   TMDB_API_KEY=your_tmdb_api_key_here
   ```

   > 💡 The app currently uses a default key in `constants.dart`. Replace it with your own key for production use.

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 🔑 Demo Credentials

The app authenticates against the [DummyJSON](https://dummyjson.com) mock API.

| Field | Value |
|---|---|
| Username | `emilys` |
| Password | `emilyspass` |

---

## 🎨 Design System

The app supports both **Light** and **Dark** themes with a consistent design language:

| | Light Mode | Dark Mode |
|---|---|---|
| **Background** | `#FAF6F0` (soft cream) | `#0A0A0A` (deep black) |
| **Accent** | `Colors.deepOrange` | `#E50914` (vibrant red) |
| **Cards** | Elevated white cards | `#1A1A1A` dark cards |

- **Material 3** design system
- Rounded cards with `16px` border radius
- `Hero` animations on movie posters
- Gradient overlays on movie cards for readability

---

## 📦 Key Packages

| Package | Purpose |
|---|---|
| `provider` | Reactive state management across the app |
| `dio` | Powerful HTTP client for TMDB API calls |
| `shared_preferences` | Persist auth tokens, favorites, and theme preference |
| `flutter_form_builder` | Declarative form building for the login screen |
| `form_builder_validators` | Field-level input validation |

---

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

<p align="center">
  Built with ❤️ using Flutter &amp; the TMDB API
</p>
