# Flutter Movie Recommendation

Aplikasi mobile untuk rekomendasi film dan TV series yang dibangun dengan Flutter. Aplikasi ini menggunakan The Movie Database (TMDB) API untuk mendapatkan informasi film dan TV series terkini.

## Fitur

- **Autentikasi User**: Login dan registrasi dengan sistem authentication
- **Browse Movies**: Menjelajahi koleksi film populer, terbaru, dan trending
- **Browse TV Shows**: Menjelajahi koleksi TV series populer dan terbaru
- **Search**: Mencari film dan TV series berdasarkan judul
- **Favorites**: Menyimpan film dan TV series favorit secara lokal
- **Detail Page**: Melihat informasi lengkap film/TV series termasuk rating, overview, dan backdrop image
- **User Management**: Manajemen user dengan role-based access (khusus admin)
- **Profile Management**: Update foto profil dan informasi user
- **Light & Dark Mode**: Mendukung tema terang dan gelap yang mengikuti sistem

## Screenshots

(Tambahkan screenshot aplikasi di sini)

## Tech Stack

- **Framework**: Flutter SDK ^3.10.0
- **State Management**: Provider ^6.1.1
- **Database**: SQLite (sqflite ^2.3.0)
- **HTTP Client**: http ^1.2.0
- **Image Caching**: cached_network_image ^3.3.1
- **Local Storage**: shared_preferences ^2.2.2
- **API**: The Movie Database (TMDB) API v3

## Prerequisites

Sebelum memulai, pastikan Anda telah menginstall:

- Flutter SDK (versi 3.10.0 atau lebih tinggi)
- Dart SDK (sudah termasuk dalam Flutter)
- Android Studio / VS Code dengan Flutter extension
- Android Emulator atau iOS Simulator / Physical Device

Untuk memeriksa instalasi Flutter, jalankan:

```bash
flutter doctor
```

## Instalasi

### 1. Clone Repository

```bash
git clone <repository-url>
cd flutter_movie_recommendation
```

### 2. Install Dependencies

Jalankan perintah berikut untuk menginstall semua dependencies yang diperlukan:

```bash
flutter pub get
```

### 3. Konfigurasi API Key (Opsional)

Project ini sudah dikonfigurasi dengan TMDB API key. Namun, jika Anda ingin menggunakan API key sendiri:

1. Daftar di [The Movie Database (TMDB)](https://www.themoviedb.org/)
2. Dapatkan API Key dari [TMDB API Settings](https://www.themoviedb.org/settings/api)
3. Update file `lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String apiKey = 'YOUR_API_KEY_HERE';
  static const String accessToken = 'YOUR_ACCESS_TOKEN_HERE';
  // ...
}
```

### 4. Jalankan Aplikasi

#### Android

```bash
flutter run
```

#### iOS

```bash
flutter run
```

#### Web

```bash
flutter run -d chrome
```

## Struktur Project

```
lib/
├── config/
│   └── api_config.dart           # Konfigurasi API TMDB
├── models/
│   ├── movie.dart                # Model data Movie
│   ├── tv_show.dart              # Model data TV Show
│   ├── media_item.dart           # Model abstrak untuk media
│   └── user.dart                 # Model data User
├── providers/
│   ├── auth_provider.dart        # State management untuk authentication
│   ├── movie_provider.dart       # State management untuk movies
│   ├── tv_provider.dart          # State management untuk TV shows
│   ├── search_provider.dart      # State management untuk search
│   └── favorites_provider.dart   # State management untuk favorites
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart     # Halaman login
│   │   └── register_screen.dart  # Halaman registrasi
│   ├── movies/
│   │   ├── movies_screen.dart    # Halaman daftar movies
│   │   └── movie_detail_screen.dart  # Halaman detail movie
│   ├── tv_shows/
│   │   ├── tv_shows_screen.dart  # Halaman daftar TV shows
│   │   └── tv_detail_screen.dart # Halaman detail TV show
│   ├── search/
│   │   └── search_screen.dart    # Halaman pencarian
│   ├── favorites/
│   │   └── favorites_screen.dart # Halaman favorites
│   ├── profile/
│   │   └── profile_screen.dart   # Halaman profil user
│   ├── user_management/
│   │   ├── user_management_screen.dart  # Halaman manajemen user (admin)
│   │   ├── add_user_screen.dart         # Halaman tambah user
│   │   └── edit_user_screen.dart        # Halaman edit user
│   └── main_screen.dart          # Main screen dengan bottom navigation
├── services/
│   ├── tmdb_service.dart         # Service untuk TMDB API
│   └── database_helper.dart      # Helper untuk SQLite database
├── widgets/
│   ├── media_card.dart           # Widget card untuk media
│   ├── media_list.dart           # Widget list untuk media
│   ├── favorite_button.dart      # Widget button favorite
│   ├── rating_widget.dart        # Widget untuk menampilkan rating
│   ├── backdrop_widget.dart      # Widget untuk backdrop image
│   └── info_row_widget.dart      # Widget untuk info row
└── main.dart                     # Entry point aplikasi
```

## Dependencies

### Production Dependencies

| Package | Version | Deskripsi |
|---------|---------|-----------|
| cupertino_icons | ^1.0.8 | Icon set iOS style |
| http | ^1.2.0 | HTTP client untuk API calls |
| provider | ^6.1.1 | State management solution |
| cached_network_image | ^3.3.1 | Caching gambar dari network |
| shared_preferences | ^2.2.2 | Local storage key-value |
| intl | ^0.19.0 | Internationalization dan formatting |
| sqflite | ^2.3.0 | SQLite database |
| path_provider | ^2.1.1 | Path ke storage directory |
| path | ^1.8.3 | Path manipulation |
| image_picker | ^1.0.7 | Pick image dari gallery/camera |
| crypto | ^3.0.3 | Cryptographic hashing |

### Dev Dependencies

| Package | Version | Deskripsi |
|---------|---------|-----------|
| flutter_test | sdk | Testing framework |
| flutter_lints | ^6.0.0 | Linting rules |

## Kredensial Default

Untuk testing, aplikasi memiliki user default:

**Admin Account:**
- Username: `admin`
- Password: `admin123`

**Regular User:**
- Atau buat akun baru melalui halaman registrasi

## Build untuk Production

### Android (APK)

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android (App Bundle)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS

```bash
flutter build ios --release
```

## Troubleshooting

### Gradle Build Error (Android)

Jika mengalami error saat build untuk Android, coba:

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### iOS Build Error

Pastikan CocoaPods terinstall dan dependencies sudah di-update:

```bash
cd ios
pod install
cd ..
```

### SQLite Error

Jika mengalami error database, hapus dan reinstall aplikasi untuk reset database.

## API Reference

Project ini menggunakan [The Movie Database (TMDB) API](https://developers.themoviedb.org/3). Endpoints yang digunakan:

- `GET /movie/popular` - Daftar film popular
- `GET /movie/now_playing` - Film yang sedang tayang
- `GET /movie/top_rated` - Film dengan rating tertinggi
- `GET /movie/{id}` - Detail film
- `GET /tv/popular` - Daftar TV series popular
- `GET /tv/top_rated` - TV series dengan rating tertinggi
- `GET /tv/{id}` - Detail TV series
- `GET /search/multi` - Search multi (film & TV)

## Contributing

Kontribusi selalu diterima! Silakan:

1. Fork repository ini
2. Buat branch baru (`git checkout -b feature/AmazingFeature`)
3. Commit perubahan (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buat Pull Request

## License

Project ini dibuat untuk keperluan edukasi dan pembelajaran Flutter development.

## Contact

Untuk pertanyaan atau saran, silakan buat issue di repository ini.

---

Dibuat dengan Flutter
