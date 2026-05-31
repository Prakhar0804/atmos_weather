# Flutter Weather App — Implementation Plan

## Overview

Build a premium, visually stunning Flutter weather app with a **glassmorphism dark UI**, dynamic weather-based gradients, city search, and multi-day forecasts — all powered by the **Open-Meteo API** (free, no API key required).

---

## User Review Required

> [!IMPORTANT]
> **Weather API Choice:** This plan uses [Open-Meteo](https://open-meteo.com/) — it's completely free, open-source, and requires **no API key**. If you prefer a different provider (e.g., OpenWeatherMap, WeatherAPI), let me know.

> [!IMPORTANT]
> **Architecture Complexity:** For a portfolio-quality app, I'm using a **feature-first architecture** with clean separation of data/domain/presentation layers. This is more than a minimal MVP but demonstrates professional Flutter skills. Let me know if you'd prefer a simpler structure.

> [!IMPORTANT]
> **State Management:** I plan to use **flutter_bloc** (Cubit) for state management — it's the enterprise standard and great for portfolios. Alternatively, I can use Riverpod or Provider. What's your preference?

---

## Open Questions

> [!NOTE]
> 1. **Target platforms:** Android only, or Android + iOS + Web?
> 2. **Location permission:** Should the app auto-detect the user's GPS location on launch, or start with a default city?
> 3. **Additional features:** Do you want any of these in the initial version?
>    - Dark/Light theme toggle
>    - Multiple saved cities
>    - Weather alerts/notifications
>    - Air quality index
> 4. **App name:** Any specific name in mind, or should I go with something like "SkyPulse" or "Atmos"?

---

## Design Philosophy

The app will feel **premium and immersive** with:

| Aspect | Details |
|---|---|
| **Background** | Full-screen dynamic gradient that shifts color based on weather condition (sunny → warm orange/amber, rainy → deep blue/purple, cloudy → slate gray/teal, night → dark indigo) |
| **Cards** | Frosted glassmorphism panels with `BackdropFilter` blur, semi-transparent white/dark backgrounds, subtle borders |
| **Typography** | Google Fonts — **Inter** for body, **Outfit** for headings — clean, modern, highly readable |
| **Icons** | Weather-appropriate icons using a curated icon set (weather_icons package or custom SVGs) |
| **Animations** | Smooth page transitions, shimmer loading states, gentle fade-ins for data, animated temperature text |

---

## Proposed Architecture

```
lib/
├── app.dart                          # MaterialApp, theme, routing
├── main.dart                         # Entry point
│
├── core/
│   ├── constants/
│   │   └── api_constants.dart        # Open-Meteo base URLs
│   ├── theme/
│   │   ├── app_theme.dart            # ThemeData, colors, text styles
│   │   └── app_colors.dart           # Color palette & gradient definitions
│   ├── utils/
│   │   ├── weather_utils.dart        # WMO weather code → icon/description mapping
│   │   └── date_utils.dart           # Date/time formatting helpers
│   └── widgets/
│       ├── glass_container.dart      # Reusable glassmorphism card widget
│       └── shimmer_loading.dart      # Loading placeholder widget
│
├── features/
│   └── weather/
│       ├── data/
│       │   ├── models/
│       │   │   ├── weather_model.dart        # JSON ↔ Dart model for API response
│       │   │   └── location_model.dart       # Geocoding API response model
│       │   ├── repositories/
│       │   │   └── weather_repository.dart   # API calls + data transformation
│       │   └── datasources/
│       │       └── weather_api_client.dart    # Raw HTTP client for Open-Meteo
│       │
│       ├── domain/
│       │   └── entities/
│       │       ├── weather.dart              # Clean weather entity
│       │       ├── hourly_forecast.dart       # Hourly data entity
│       │       └── daily_forecast.dart        # Daily data entity
│       │
│       └── presentation/
│           ├── bloc/
│           │   ├── weather_cubit.dart        # Business logic (fetch, refresh)
│           │   └── weather_state.dart        # States: initial, loading, loaded, error
│           ├── screens/
│           │   ├── home_screen.dart          # Main weather dashboard
│           │   └── search_screen.dart        # City search with autocomplete
│           └── widgets/
│               ├── current_weather_card.dart  # Large hero card with temp, condition
│               ├── weather_details_grid.dart  # Wind, humidity, UV, pressure grid
│               ├── hourly_forecast_list.dart  # Horizontal scrolling hourly forecast
│               ├── daily_forecast_list.dart   # 7-day vertical forecast list
│               └── dynamic_background.dart    # Animated gradient background
│
└── pubspec.yaml
```

---

## Proposed Changes

### Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0              # HTTP client for API calls
  flutter_bloc: ^8.1.0      # State management (Cubit)
  equatable: ^2.0.5          # Value equality for states
  intl: ^0.19.0              # Date/time formatting
  google_fonts: ^6.1.0       # Inter + Outfit fonts
  geolocator: ^12.0.0        # GPS location (optional)
  geocoding: ^3.0.0          # Reverse geocoding (optional)
  shimmer: ^3.0.0            # Loading shimmer effect
```

---

### Core Layer

#### [NEW] [api_constants.dart](file:///d:/Flutter%20Portfolio/Weather%20app/lib/core/constants/api_constants.dart)
- Open-Meteo forecast base URL: `https://api.open-meteo.com/v1/forecast`
- Geocoding base URL: `https://geocoding-api.open-meteo.com/v1/search`
- Default query parameters for current, hourly, and daily data

#### [NEW] [app_colors.dart](file:///d:/Flutter%20Portfolio/Weather%20app/lib/core/theme/app_colors.dart)
- Define weather-condition-based gradient maps (sunny, rainy, cloudy, night, thunderstorm, snow)
- Glassmorphism overlay colors (semi-transparent white/dark)

#### [NEW] [app_theme.dart](file:///d:/Flutter%20Portfolio/Weather%20app/lib/core/theme/app_theme.dart)
- Dark theme `ThemeData` with Google Fonts (Inter, Outfit)
- Custom text theme, card themes, icon themes

#### [NEW] [glass_container.dart](file:///d:/Flutter%20Portfolio/Weather%20app/lib/core/widgets/glass_container.dart)
- Reusable widget wrapping `ClipRRect` + `BackdropFilter` + semi-transparent `Container`
- Parameters: child, borderRadius, blur intensity, opacity, border

#### [NEW] [weather_utils.dart](file:///d:/Flutter%20Portfolio/Weather%20app/lib/core/utils/weather_utils.dart)
- Map WMO weather codes (0–99) to human-readable descriptions and icon data
- Helper to determine gradient set from weather code + time of day

---

### Data Layer

#### [NEW] [weather_api_client.dart](file:///d:/Flutter%20Portfolio/Weather%20app/lib/features/weather/data/datasources/weather_api_client.dart)
- `fetchWeather(double lat, double lon)` → raw JSON map
- `searchCity(String query)` → raw JSON list from geocoding API
- Error handling with custom exceptions

#### [NEW] [weather_model.dart](file:///d:/Flutter%20Portfolio/Weather%20app/lib/features/weather/data/models/weather_model.dart)
- `fromJson` factory constructor for Open-Meteo response
- Parses current, hourly (24h), and daily (7-day) data

#### [NEW] [location_model.dart](file:///d:/Flutter%20Portfolio/Weather%20app/lib/features/weather/data/models/location_model.dart)
- Model for geocoding API response (name, country, lat, lon, timezone)

#### [NEW] [weather_repository.dart](file:///d:/Flutter%20Portfolio/Weather%20app/lib/features/weather/data/repositories/weather_repository.dart)
- Orchestrates API client calls
- Transforms raw models into domain entities

---

### Domain Layer

#### [NEW] [weather.dart](file:///d:/Flutter%20Portfolio/Weather%20app/lib/features/weather/domain/entities/weather.dart)
- Clean entity: `cityName`, `temperature`, `feelsLike`, `weatherCode`, `humidity`, `windSpeed`, `uvIndex`, `pressure`, `visibility`, `sunrise`, `sunset`

#### [NEW] [hourly_forecast.dart](file:///d:/Flutter%20Portfolio/Weather%20app/lib/features/weather/domain/entities/hourly_forecast.dart)
- Entity: `time`, `temperature`, `weatherCode`, `precipitationProbability`

#### [NEW] [daily_forecast.dart](file:///d:/Flutter%20Portfolio/Weather%20app/lib/features/weather/domain/entities/daily_forecast.dart)
- Entity: `date`, `tempMax`, `tempMin`, `weatherCode`, `precipitationProbability`, `sunrise`, `sunset`

---

### Presentation Layer

#### [NEW] [weather_state.dart](file:///d:/Flutter%20Portfolio/Weather%20app/lib/features/weather/presentation/bloc/weather_state.dart)
- States: `WeatherInitial`, `WeatherLoading`, `WeatherLoaded`, `WeatherError`
- Uses Equatable for proper state comparison

#### [NEW] [weather_cubit.dart](file:///d:/Flutter%20Portfolio/Weather%20app/lib/features/weather/presentation/bloc/weather_cubit.dart)
- `fetchWeather(String city)` — searches city → fetches weather
- `fetchWeatherByCoords(double lat, double lon, String cityName)` — direct coord fetch
- `refreshWeather()` — re-fetch current location's data

#### [NEW] [home_screen.dart](file:///d:/Flutter%20Portfolio/Weather%20app/lib/features/weather/presentation/screens/home_screen.dart)
- Full-screen dynamic gradient background
- `RefreshIndicator` for pull-to-refresh
- Vertical scroll layout:
  1. Current weather hero card (large temp, condition icon, city name)
  2. Weather details grid (wind, humidity, UV, pressure — in glass cards)
  3. Hourly forecast horizontal list
  4. 7-day forecast vertical list

#### [NEW] [search_screen.dart](file:///d:/Flutter%20Portfolio/Weather%20app/lib/features/weather/presentation/screens/search_screen.dart)
- Search bar with debounced input
- Live autocomplete results from Open-Meteo geocoding API
- Glass-styled result tiles showing city, country, coordinates
- Tap a result → navigate back with selected city data

#### [NEW] [current_weather_card.dart](file:///d:/Flutter%20Portfolio/Weather%20app/lib/features/weather/presentation/widgets/current_weather_card.dart)
- Large temperature display (80px+ font)
- Weather condition icon + description
- "Feels like" temperature
- City name + date

#### [NEW] [weather_details_grid.dart](file:///d:/Flutter%20Portfolio/Weather%20app/lib/features/weather/presentation/widgets/weather_details_grid.dart)
- 2×2 or 2×3 grid of glass cards
- Each card shows an icon + label + value (wind, humidity, UV, pressure, visibility, sunrise/sunset)

#### [NEW] [hourly_forecast_list.dart](file:///d:/Flutter%20Portfolio/Weather%20app/lib/features/weather/presentation/widgets/hourly_forecast_list.dart)
- Horizontal `ListView` inside a glass container
- Each item: time, weather icon, temperature

#### [NEW] [daily_forecast_list.dart](file:///d:/Flutter%20Portfolio/Weather%20app/lib/features/weather/presentation/widgets/daily_forecast_list.dart)
- Vertical list inside a glass container
- Each row: day name, weather icon, temp range bar (min–max), precipitation %

#### [NEW] [dynamic_background.dart](file:///d:/Flutter%20Portfolio/Weather%20app/lib/features/weather/presentation/widgets/dynamic_background.dart)
- `AnimatedContainer` with gradient that transitions smoothly when weather data changes
- Weather code → gradient mapping (defined in `app_colors.dart`)

---

## Key Technical Details

### Open-Meteo API Request Example
```
GET https://api.open-meteo.com/v1/forecast
  ?latitude=28.6139
  &longitude=77.2090
  &current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,surface_pressure,uv_index
  &hourly=temperature_2m,weather_code,precipitation_probability
  &daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,sunrise,sunset
  &timezone=auto
  &forecast_days=7
```

### WMO Weather Codes (subset)
| Code | Condition |
|------|-----------|
| 0 | Clear sky |
| 1–3 | Partly cloudy |
| 45, 48 | Fog |
| 51–55 | Drizzle |
| 61–65 | Rain |
| 71–75 | Snowfall |
| 80–82 | Rain showers |
| 95, 96, 99 | Thunderstorm |

---

## Verification Plan

### Automated Tests
```bash
# Create the Flutter project
flutter create --project-name weather_app .

# Get dependencies
flutter pub get

# Build check (ensures no compilation errors)
flutter analyze
flutter build apk --debug
```

### Manual Verification
- Launch on emulator/device and verify:
  - App loads with default city weather
  - City search returns results and updates weather
  - Pull-to-refresh works
  - Gradient changes with different weather conditions
  - All data fields display correctly
  - Glassmorphism effects render properly
  - Smooth animations and transitions
