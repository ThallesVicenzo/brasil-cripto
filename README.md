# Brasil Cripto 🇧🇷

A modern Flutter application for tracking cryptocurrency prices and managing your favorite digital assets.

[🇧🇷 Leia em Português](README_PT.md)

## ✨ Features

### 🔍 **Cryptocurrency Search & Discovery**
- Search for any cryptocurrency by name or symbol
- Browse trending and popular cryptocurrencies
- Real-time price updates and market data
- View market cap rankings and 24h price changes

### 📊 **Interactive Price Charts**
- Beautiful, interactive price charts with touch support
- Multiple time periods: 24h, 7d, 30d, 90d, 1y
- Price trend indicators (positive/negative changes)
- Chart statistics including min/max prices and percentage changes
- Fallback chart data generation for offline reliability

### ❤️ **Favorites Management**
- Add/remove cryptocurrencies to your favorites list
- Persistent storage using secure local storage
- Quick access to your preferred coins
- Real-time synchronization across the app

### 🎨 **Modern UI/UX**
- Clean and intuitive Material Design interface
- Smooth animations including falling coins background
- Responsive design for different screen sizes
- Custom color scheme optimized for crypto data visualization

### 🌐 **Internationalization**
- Multi-language support (English/Portuguese)
- Localized currency formatting
- Adaptive date and number formatting

### 🔒 **Data Security**
- Secure local storage for user preferences
- Privacy-focused design with no personal data collection
- Offline capability with fallback data

## 🚀 Installation

### Prerequisites
- Flutter SDK (>= 3.7.0)
- Dart SDK (>= 3.7.0)
- Android Studio / VS Code with Flutter extensions
- Android/iOS device or emulator

### Step by Step

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/brasil-cripto.git
   cd brasil-cripto
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate necessary files**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   # For debug mode
   flutter run
   
   # For release mode
   flutter run --release
   ```

### Build for Production

**Android APK**
```bash
flutter build apk --release
```

**Android App Bundle**
```bash
flutter build appbundle --release
```

**iOS**
```bash
flutter build ios --release
```

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── app_widget.dart          # Main app widget
├── app_injector.dart        # Dependency injection
├── model/                   # Data models and repositories
│   ├── models/             # Data models (CoinModel, CoinChartModel)
│   ├── repositories/       # Data repositories
│   └── service/           # API services and HTTP client
├── view/                   # UI components
│   ├── pages/             # Screen pages
│   ├── widgets/           # Reusable widgets
│   └── utils/             # UI utilities and routing
├── view_model/            # Business logic and state management
│   ├── services/          # Business services
│   └── utils/             # Utilities (formatters, storage)
└── l10n/                  # Internationalization files
```

## 📱 Screenshots

| Home Screen | Coin Details | Favorites | Chart Interaction |
|-------------|--------------|-----------|-------------------|
| 🏠 Search and browse cryptocurrencies | 📊 Detailed price charts and stats | ❤️ Manage favorite coins | 👆 Interactive chart with touch |

## 🔌 API Integration

This app uses the **CoinGecko API** for cryptocurrency data:

### 📡 **Free API with Rate Limits**
- **Base URL**: `https://api.coingecko.com/api/v3/`
- **Rate Limit**: 10-30 requests per minute (free tier)
- **Data includes**: Current prices, market caps, 24h changes, historical data

### 🎯 **Endpoints Used**
- `GET /coins/markets` - Get cryptocurrency market data
- `GET /coins/{id}/market_chart` - Get historical price data for charts

### ⚠️ **Important Notes**
- The API has rate limiting on the free tier
- If rate limits are exceeded, the app will show appropriate error messages
- The app includes fallback chart data generation when API requests fail

### 🔄 **Error Handling**
- Network error handling with user-friendly messages
- Rate limit detection with upgrade suggestions
- Automatic retry mechanisms
- Offline chart data generation as fallback

## 🛠️ Technologies Used

- **Framework**: Flutter 3.7+
- **Language**: Dart
- **State Management**: Provider + ChangeNotifier
- **HTTP Client**: Dio
- **Routing**: GoRouter
- **Local Storage**: FlutterSecureStorage
- **Dependency Injection**: GetIt
- **Testing**: Mockito + FlutterTest
- **Internationalization**: Flutter Intl
- **Functional Programming**: Dartz (Either, Option)

## 🧪 Testing

Run the test suite:

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=test_driver/app.dart
```

The project includes:
- Unit tests for models and view models
- Widget tests for UI components
- Integration tests for complete workflows
- Mock services for isolated testing

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚡ Performance Notes

- Efficient memory management with proper widget disposal
- Optimized image loading with caching
- Minimal API calls with smart caching strategies
- Smooth animations with proper performance monitoring

## 🙋‍♂️ Support

If you have any questions or need help, please:
1. Check the [Issues](https://github.com/yourusername/brasil-cripto/issues) page
2. Create a new issue with detailed information
3. Feel free to contact me on my professional email

---
