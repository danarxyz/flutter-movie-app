# Watchly 🎬

**Watchly** is a modern Movie & TV Show recommendation application built with **Flutter**. It utilizes **Clean Architecture** principles and **Riverpod** for state management, providing a robust, scalable, and responsive user experience.

![Watchly Banner](https://via.placeholder.com/1200x500.png?text=Watchly+App+Preview)
*(Replace this link with your actual app screenshot later)*

## ✨ Features

*   **Authentication:** Secure Login, Sign Up, and Forgot Password using **Firebase Auth**.
*   **Home Feed:** Browse Trending, Popular, Top Rated Movies, TV Shows, and Anime.
*   **Rich Details:** View cast, ratings, overview, and production details.
*   **Search:** Real-time search for movies and TV series.
*   **Watchlist:** Save your favorite content locally/cloud with Undo functionality.
*   **Admin Panel:** User management system (CRUD) for administrators.
*   **Modern UI:** Material 3 Dark Theme with haptic feedback and smooth animations.
*   **Responsive:** Optimized for Mobile and Tablet layouts.

## 🛠 Tech Stack

*   **Framework:** [Flutter](https://flutter.dev/) (Dart)
*   **State Management:** [Flutter Riverpod](https://riverpod.dev/) (v2)
*   **Architecture:** Clean Architecture (Domain, Data, Presentation layers)
*   **Navigation:** [GoRouter](https://pub.dev/packages/go_router)
*   **Networking:** [Dio](https://pub.dev/packages/dio) with Interceptors
*   **Backend:** [Firebase](https://firebase.google.com/) (Auth, Firestore)
*   **API:** [The Movie Database (TMDB)](https://www.themoviedb.org/)
*   **Local Storage:** Shared Preferences / Secure Storage

## 🚀 Getting Started

Follow these steps to run the project locally.

### Prerequisites

*   Flutter SDK (Latest Stable)
*   Java Development Kit (JDK) 11 or 17
*   Android Studio / VS Code
*   A TMDB API Key

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/your-username/flutter_movie_recommendation.git
    cd flutter_movie_recommendation
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Environment Setup (.env)**
    Create a file named `.env` in the root directory of the project. Add your TMDB API Key:
    ```env
    TMDB_API_KEY=your_tmdb_api_key_here
    TMDB_BASE_URL=https://api.themoviedb.org/3
    ```

4.  **Firebase Setup**
    This project uses Firebase. You need to configure it for your own project:
    *   Create a project on [Firebase Console](https://console.firebase.google.com/).
    *   Enable **Authentication** (Email/Password) and **Firestore Database**.
    *   Use FlutterFire CLI to generate configuration:
        ```bash
        flutterfire configure
        ```
    *   *Alternatively*, place your `google-services.json` in `android/app/`.

5.  **Run the App**
    ```bash
    flutter run
    ```

## 📂 Project Structure

This project follows **Clean Architecture** to separate concerns and ensure testability.

```
lib/
├── core/                   # Core functionality (Constants, Errors, Utils, DI)
│   ├── constants/
│   ├── di/                 # Dependency Injection (GetIt)
│   ├── error/
│   ├── network/            # Dio Client & Interceptors
│   ├── theme/              # App Theme & Colors
│   └── utils/              # Extensions, Snackbars, Validators
│
├── data/                   # Data Layer (Repositories impl, Data Sources, Models)
│   ├── datasources/        # Remote (API) & Local Data Sources
│   ├── models/             # DTOs (Data Transfer Objects) from JSON
│   └── repositories/       # Implementation of Domain Repositories
│
├── domain/                 # Domain Layer (Entities, UseCases, Repository Interfaces)
│   ├── entities/           # Pure Dart Objects
│   ├── repositories/       # Abstract Interfaces
│   └── usecases/           # Business Logic
│
├── presentation/           # Presentation Layer (UI & State)
│   ├── providers/          # Riverpod Providers
│   ├── screens/            # Screen Widgets (Home, Detail, Auth, etc.)
│   └── widgets/            # Reusable UI Components
│
└── main.dart               # Entry Point
```

## 🧪 Testing

To run unit and widget tests:

```bash
flutter test
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
