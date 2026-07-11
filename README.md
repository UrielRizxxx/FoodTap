# food_tap_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Estructura del proyecto::

FOOD_TAP_APP
│
├── android/
├── ios/
├── linux/
├── macos/
├── web/
├── windows/
├── test/
│
├── assets/
│   ├── fonts/
│   │
│   ├── icons/
│   │   ├── logo.png
│   │   ├── logo_white.png
│   │   ├── splash_logo.png
│   │   └── app_icon.png
│   │
│   ├── images/
│   │   ├── auth/
│   │   ├── onboarding/
│   │   ├── categories/
│   │   ├── products/
│   │   └── placeholders/
│   │
│   └── animations/
│
├── lib/
│
│   ├── core/
│   │
│   │   ├── constants/
│   │   │      app_colors.dart
│   │   │      app_strings.dart
│   │   │      app_sizes.dart
│   │   │      app_icons.dart
│   │   │
│   │   ├── theme/
│   │   │      app_theme.dart
│   │   │      text_theme.dart
│   │   │      button_theme.dart
│   │   │
│   │   ├── routes/
│   │   │      app_router.dart
│   │   │
│   │   ├── services/
│   │   │      auth_service.dart
│   │   │      firestore_service.dart
│   │   │      storage_service.dart
│   │   │
│   │   ├── utils/
│   │   │      validators.dart
│   │   │      formatters.dart
│   │   │      helpers.dart
│   │   │
│   │   └── widgets/
│   │          primary_button.dart
│   │          custom_textfield.dart
│   │          loading_widget.dart
│   │          empty_widget.dart
│   │          product_card.dart
│   │
│   ├── models/
│   │      user_model.dart
│   │      product_model.dart
│   │      order_model.dart
│   │      chat_model.dart
│   │      message_model.dart
│   │      category_model.dart
│   │
│   ├── features/
│   │
│   │   ├── splash/
│   │   │      splash_screen.dart
│   │   │
│   │   ├── auth/
│   │   │
│   │   │      screens/
│   │   │           login_screen.dart
│   │   │           register_screen.dart
│   │   │           forgot_password.dart
│   │   │
│   │   │      controllers/
│   │   │
│   │   │      widgets/
│   │   │
│   │   ├── home/
│   │   │
│   │   │      screens/
│   │   │      widgets/
│   │   │
│   │   ├── products/
│   │   │
│   │   │      screens/
│   │   │           product_detail.dart
│   │   │           publish_product.dart
│   │   │           my_products.dart
│   │   │
│   │   │      controllers/
│   │   │
│   │   │      widgets/
│   │   │
│   │   ├── orders/
│   │   │
│   │   │      screens/
│   │   │
│   │   ├── chat/
│   │   │
│   │   │      screens/
│   │   │
│   │   ├── profile/
│   │   │
│   │   │      screens/
│   │   │           profile_screen.dart
│   │   │           edit_profile.dart
│   │   │           settings_screen.dart
│   │   │
│   │   ├── admin/
│   │   │
│   │   │      screens/
│   │   │
│   │   │           dashboard.dart
│   │   │
│   │   │           pending_products.dart
│   │   │
│   │   │           review_product.dart
│   │   │
│   │   │           approved_products.dart
│   │   │
│   │   │           rejected_products.dart
│   │   │
│   │   │           suspended_products.dart
│   │   │
│   │   │           users.dart
│   │   │
│   │   │      widgets/
│   │   │
│   │   │      controllers/
│   │
│   ├── firebase_options.dart
│   │
│   └── main.dart
│
├── .gitignore
├── analysis_options.yaml
├── pubspec.yaml
├── README.md
└── CHANGELOG.md