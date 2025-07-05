# Shopeasy - Flutter E-commerce Product Showcase App

Shopeasy is a Flutter-based mobile application designed for showcasing e-commerce products with Firebase integration. This is a frontend project assignment developed for the HAPPETO Internship Program.

## 🚀 Features

- User Authentication (Login/Register with Firebase Auth)
- Firebase Firestore integration for storing user data
- Firebase Storage for image uploads
- Google Sign-in Support
- State Management (using Provider - can be extended)
- Form Validation with custom validators
- Image picker for user profile pictures
- Clean and modern UI using Google Fonts and Iconly icons
- Responsive design with scroll support
- Toast messages for user feedback

## 📱 Screens Implemented

- Login Screen
- Registration Screen
- Forgot Password Screen
- Root Screen (Dashboard or Home placeholder)

## 🧑‍💻 Technologies Used

- Flutter 3+
- Dart
- Firebase (Auth, Firestore, Storage)
- Google Fonts
- Flutter Iconly
- Fluttertoast

## 📂 Project Structure

lib/
├── Const/
│ └── my_validators.dart
├── Screens/
│ ├── auth/
│ │ ├── login.dart
│ │ ├── register.dart
│ │ └── forgot_password.dart
│ └── loading_manager.dart
├── Widgets/
│ ├── app_name_text.dart
│ ├── auth/google_button.dart
│ └── auth/image_picker_widget.dart
├── services/
│ └── my_app_methods.dart
├── root_screen.dart
└── main.dart


## ✅ Getting Started

1. **Clone the repository**
   https://github.com/221p/Shopeasy.git

2. Install dependencies
  bash-- flutter pub get

3. Run the app
  bash--flutter run
