# 📚 ReadArc  –  Your Personalized Book Reading Companion

![Made with Flutter](https://img.shields.io/badge/Made%20with-Flutter-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Backend-Firebase-orange?logo=firebase)
![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)

ReadArc is a powerful, user-friendly **Flutter** app designed for reading, managing, and exploring a vast collection of books. With **Firebase integration**, **responsive UI**, **PDF viewing**, and **user/admin role-based features**, ReadArc is an ideal full-stack mobile reading platform.

---

##  ✨ Features

- 🔐 Firebase Authentication (User/Admin Login & Register)
- 📖 View, search, and bookmark books
- 🌗 Light & Dark Mode toggle
- 📄 In-app PDF reading with zoom & theme switcher
- 📤 Upload book (PDF + cover image)
- 🔍 Advanced search by title, author, or description (case-insensitive)
- 🧠 Genre-based filtering
- 👤 Edit Profile with image upload
- 🛠️ Admin panel to add, update & delete books
- 🌐 Responsive UI for mobile, tablet, and web

---

## 📱 UI/UX Design (Figma)

We designed **ReadArc** using Figma for a clean and intuitive book reading experience.

[![View on Figma](https://img.shields.io/badge/View%20Design-Figma-blue?logo=figma)](https://www.figma.com/design/IRQecGd1xWH4aDHeR84MqO/E-BOOK-%7C-READARC?t=8UWIu1j4geIpgFTB-0)

## 📦 Tech Stack

| Technology     | Usage                        |
|----------------|------------------------------|
| **Flutter**    | Frontend UI & logic          |
| **Firebase**   | Auth, Firestore, Storage     |
| **pdfx / pdf_viewer** | PDF rendering          |
| **Provider** or **Riverpod** | State management |
| **Dart**       | Backend logic and models     |
| **GitHub Actions** | CI/CD (if enabled)       |

---

## 🔧 Setup Instructions

### 1️⃣ Prerequisites

- Flutter SDK ≥ 3.x
- Firebase Project setup
- Dart enabled IDE (VS Code or Android Studio)

### 2️⃣ Clone the Repo

```bash
git clone https://github.com/Shubham09876543/ReadArc.git
cd ReadArc
```

### 3️⃣ Install Dependencies

```bash
flutter pub get
```

### 4️⃣ Add Firebase Config

Place your `google-services.json` (Android) and `firebase_options.dart` in the appropriate directories.

---

## 🔐 Firebase Setup

- **Authentication**: Email/Password
- **Firestore Collections**:
  - `books`: `{ name, author, description, pdfUrl, imageUrl, genre }`
  - `users`: `{ uid, email, username, role (admin/user), profileImage }`

---

## 🚀 Run the App

```bash
flutter run
```

> ✅ Supports Web, Android, and iOS

---

## 👥 Team

- 👨‍💻 **Leader**: Shubham Gajera ([LinkedIn](https://www.linkedin.com/in/shubham-gajera-2135b8268))
- 👨‍💻 **Member**: Atmin Jarasaniya

📧 Email: **shubhamgajera122@gmail.com**

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙌 Acknowledgements

- Flutter & Firebase Teams
- pdfx & flutter_pdfview contributors
- Open-source community 💙

---

> _“ReadArc is more than a book reader – it’s a smart, cloud-based library experience.”_
