# Atmos 🌦️

A premium, state-of-the-art weather forecasting application built with **Flutter & Riverpod**. Designed with a modern, high-end glassmorphism UI, fluid micro-animations, and dynamic weather-based gradient backgrounds, **Atmos** is crafted specifically to showcase high-level mobile engineering and design practices.

---

## 🚀 Key Features

*   📍 **Local GPS Weather Detection:** Automatically reads device GPS coordinates on launch, handles permissions gracefully, and retrieves high-accuracy localized data (with a smart fallback to New Delhi).
*   🎨 **Dynamic Gradient Backdrops:** Background gradients change in real-time based on the weather conditions (sunny, rainy, snowy, stormy, fog, or clear night) to deliver an immersive weather experience.
*   🔮 **Premium Glassmorphism UI:** Built with custom dynamic frosted-glass cards (`BackdropFilter` and custom borders) that blend seamlessly into active backdrop gradients.
*   🌓 **Seamless Dark/Light Themes:** Fully integrated, beautifully curated Light and Dark mode options that adapt instantly and persist across app restarts using local storage.
*   📊 **Hourly & Daily Forecasts:** Features a 24-hour horizontal scrolling forecast list and a 7-day extended forecast with visual color range indicators.
*   🌬️ **Air Quality Index (AQI):** Displays comprehensive AQI data (PM2.5, PM10, and health-scale indicators) to keep users informed of air quality.
*   🔍 **Smart City Search:** Debounced autocomplete search that locates and loads any city in the world instantly without overloading API limits.
*   💾 **Saved Cities Manager:** Allows users to save favorite locations. Persisted locally via `shared_preferences` with intuitive **Swipe-to-Delete** gestural interaction.
*   🔄 **Pull-to-Refresh:** Seamless data refresh using native scroll gestures on the main dashboard.

---

## 🏛️ Architecture & Clean Code Design

Atmos is engineered with **Feature-First Clean Architecture**, designed to be scalable, highly testable, and immediately understandable to technical interviewers.

```text
lib/
├── core/                       # Shared app infrastructure
│   ├── constants/              # API endpoints, constants
│   ├── theme/                  # Theme tokens, custom glass themes, color palettes
│   ├── utils/                  # Date/Time helpers, WMO weather code translators
│   └── widgets/                # Reusable cross-cutting UI components (e.g., GlassContainer)
│
└── features/weather/           # Core domain feature folder
    ├── data/                   # Data Access Layer
    │   ├── datasources/        # HTTP API Web Clients (Open-Meteo REST Client)
    │   ├── models/             # Serialization (JSON parsers & mapping)
    │   └── repositories/       # Implementation of domain repositories
    │
    ├── domain/                 # Business Logic/Domain Layer
    │   └── entities/           # Pure Dart business models (Weather, Forecasts)
    │
    └── presentation/           # User Interface Layer (UI)
        ├── providers/          # Riverpod state management (Notifiers & AsyncNotifier)
        ├── screens/            # Main dashboards (HomeScreen, SearchScreen, SavedCitiesScreen)
        └── widgets/            # Feature-specific widgets (CurrentWeatherCard, AQICard, etc.)
```

### Why This Architecture?
1.  **Strict Separation of Concerns:** UI depends solely on providers, providers orchestrate repository operations, and repositories fetch and map clean data to pure domain entities.
2.  **Zero Network Bloat:** All network models and JSON structures are isolated inside the **Data** layer. The **Domain** and **Presentation** layers remain pure Dart, making them completely independent of external API structural shifts.
3.  **State Management with Riverpod:** Using a Notifier pattern provides a reactive, single-source-of-truth state. It avoids the boiler-plate of BLoC while maintaining strong decoupling from the Widget tree.

---

## 🛠️ Technology Stack

*   **Core Framework:** Flutter (Dart SDK)
*   **State Management:** Riverpod 2.x (`flutter_riverpod`)
*   **Networking:** `http` (Concurrent weather and AQI fetches using `Future.wait`)
*   **Geolocation:** `geolocator`
*   **Local Storage:** `shared_preferences` (Theme & favorite cities persistence)
*   **Typography:** Google Fonts (`Inter` & `Outfit`)
*   **Animation & Loaders:** `shimmer` & native Flutter implicit animations

---

## 📥 Getting Started

### Prerequisites
Make sure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and configured on your machine.

### Installation
1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/YOUR_USERNAME/atmos_weather.git
    cd atmos_weather
    ```
2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Run the Application:**
    ```bash
    # Run on a connected device/emulator
    flutter run
    ```
4.  **Build a Release APK (for Android):**
    ```bash
    flutter build apk --release
    ```

---
