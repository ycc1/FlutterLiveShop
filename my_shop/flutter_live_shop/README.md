# Flutter Live Shop

## Overview
Flutter Live Shop is an electronic shopping mall application built with Flutter. It provides a seamless shopping experience with features such as product display, shopping cart management, user profile management, and live streaming of products.

## Features
- **Product Display**: Browse through a wide range of products with detailed information.
- **Shopping Cart**: Add products to the cart, view cart items, and manage purchases.
- **User Profile**: Manage user information, including login and registration.
- **Live Streaming**: Watch live streams of products and interact with sellers in real-time.

## Project Structure
```
flutter_live_shop
├── android                # Android platform-specific code
├── ios                    # iOS platform-specific code
├── lib                    # Main application code
│   ├── main.dart          # Entry point of the application
│   ├── app.dart           # Application structure and routing
│   ├── core               # Core functionalities
│   │   ├── constants.dart  # Constant values
│   │   ├── theme.dart      # Application theme
│   │   └── config.dart     # Configuration settings
│   ├── models             # Data models
│   │   ├── product.dart    # Product model
│   │   ├── user.dart       # User model
│   │   └── cart_item.dart  # Cart item model
│   ├── services           # Services for API and authentication
│   │   ├── api_service.dart # API calls
│   │   ├── auth_service.dart # Authentication functionalities
│   │   └── streaming_service.dart # Live streaming management
│   ├── repositories       # Data repositories
│   │   └── product_repository.dart # Product data access
│   ├── providers          # State management providers
│   │   ├── product_provider.dart # Product state management
│   │   ├── cart_provider.dart # Shopping cart state management
│   │   ├── auth_provider.dart # User authentication state management
│   │   └── live_provider.dart # Live streaming state management
│   ├── screens            # UI screens
│   │   ├── splash         # Splash screen
│   │   │   └── splash_screen.dart
│   │   ├── home           # Home screen
│   │   │   └── home_screen.dart
│   │   ├── product        # Product screens
│   │   │   ├── product_list_screen.dart
│   │   │   └── product_detail_screen.dart
│   │   ├── cart           # Cart screen
│   │   │   └── cart_screen.dart
│   │   ├── profile        # Profile screen
│   │   │   └── profile_screen.dart
│   │   ├── auth           # Authentication screens
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   └── live           # Live streaming screens
│   │       ├── live_list_screen.dart
│   │       └── live_player_screen.dart
│   ├── widgets            # Reusable widgets
│   │   ├── product_card.dart
│   │   ├── cart_button.dart
│   │   ├── rating_widget.dart
│   │   └── live_preview_widget.dart
│   ├── routes             # Application routing
│   │   └── app_router.dart
│   └── utils              # Utility functions
│       ├── helpers.dart
│       └── validators.dart
├── assets                 # Asset files
│   ├── icons              # Icon assets
│   └── lottie             # Lottie animation files
├── test                   # Test files
│   └── widget_test.dart   # Widget tests
├── pubspec.yaml           # Flutter configuration file
├── analysis_options.yaml   # Dart analysis options
├── .gitignore             # Git ignore file
└── README.md              # Project documentation
```

## Getting Started
1. Clone the repository.
2. Navigate to the project directory.
3. Run `flutter pub get` to install dependencies.
4. Use `flutter run` to start the application.

## Contributing
Contributions are welcome! Please open an issue or submit a pull request for any enhancements or bug fixes.

## License
This project is licensed under the MIT License. See the LICENSE file for more details.