# 🏗️ SiteTracker - Construction Site Attendance Management System

A comprehensive Flutter-based mobile application for managing construction site attendance, worker assignments, and site coordination with real-time tracking and announcements.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the Application](#running-the-application)
- [User Roles](#user-roles)
- [API Endpoints](#api-endpoints)
- [Database Schema](#database-schema)
- [Screenshots](#screenshots)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

SiteTracker is a full-stack mobile application designed to streamline attendance management for construction sites. It provides role-based access control for administrators, site coordinators, and workers, featuring GPS-based attendance tracking, selfie verification, dynamic site management, and real-time announcements.

## ✨ Features

### 🔐 Authentication & User Management
- Secure user registration with role selection (Worker/Site-Coordinator)
- Mobile number-based login with country code support
- JWT-based authentication
- Profile image upload and management
- Secure password hashing with bcrypt

### 👷 Worker Features
- **Attendance Tracking**: GPS-based punch-in/punch-out with selfie verification
- **Real-time Announcements**: View site-specific and global announcements
- **Attendance History**: View personal attendance records
- **Dashboard**: Quick access to daily attendance and important updates

### 👨‍💼 Site-Coordinator Features
- **Worker Management**: Add and manage workers assigned to sites
- **Attendance Oversight**: View and filter attendance records for assigned sites
- **Announcements**: Create and manage site-specific announcements
- **Worker List**: View all workers in assigned sites
- **Punch-in/Punch-out**: Same attendance functionality as workers

### 🔧 Admin Features
- **Site Management**: Create, update, and manage construction sites
- **User Assignment**: Assign workers and coordinators to specific sites
- **Global Announcements**: Create announcements for all sites or specific sites
- **Comprehensive Attendance Reports**: Filter and export attendance data
- **Worker Overview**: View all workers across all sites
- **Site Coordinator Management**: Add and manage site coordinators

### 📊 General Features
- **GPS Location Tracking**: Accurate location capture for punch-in/punch-out
- **Camera Integration**: Selfie capture for attendance verification
- **Offline Support**: Secure local storage with `flutter_secure_storage`
- **Responsive Design**: Modern UI with consistent design system
- **Data Export**: Export attendance reports to Excel and CSV formats
- **Real-time Updates**: Live data synchronization across devices

## 🛠️ Tech Stack

### Frontend (Mobile)
- **Framework**: Flutter 3.10+ (Dart)
- **State Management**: Provider
- **Navigation**: GoRouter 14.0.0
- **Storage**: 
  - `shared_preferences` - Local preferences
  - `flutter_secure_storage` - Secure token storage
- **HTTP Client**: http 1.2.0
- **Camera**: camera 0.11.0+1
- **Location**: geolocator 14.0.2
- **Permissions**: permission_handler 12.0.1
- **Image Handling**: image_picker 1.0.7
- **Data Export**: 
  - `excel` 4.0.6
  - `csv` 6.0.0

### Backend (API)
- **Runtime**: Node.js
- **Framework**: Express.js 5.1.0
- **ORM**: Prisma 6.19.0
- **Database**: PostgreSQL
- **Authentication**: 
  - `jsonwebtoken` 9.0.2
  - `bcrypt` 6.0.0
- **File Upload**: multer 2.0.2
- **Security**: 
  - `helmet` 8.1.0
  - `cors` 2.8.5
- **Environment**: dotenv 17.2.3
- **Development**: nodemon 3.1.11

## 📁 Project Structure

```
flutter_application_1/
├── lib/
│   ├── core/                    # Core configuration and theme
│   ├── models/                  # Data models
│   ├── providers/               # State management providers
│   ├── screens/                 # UI screens
│   │   ├── admin/              # Admin screens
│   │   ├── coordinator/        # Coordinator screens
│   │   └── worker/             # Worker screens
│   ├── services/               # API services
│   ├── utils/                  # Utility functions
│   ├── widgets/                # Reusable widgets
│   └── main.dart               # App entry point
│
├── backend/
│   ├── src/
│   │   ├── config/            # Database and JWT configuration
│   │   ├── controllers/       # Request handlers
│   │   ├── middlewares/       # Auth and upload middlewares
│   │   ├── routes/            # API route definitions
│   │   ├── services/          # Business logic layer
│   │   └── utils/             # Utility functions
│   ├── prisma/
│   │   └── schema.prisma      # Database schema
│   ├── uploads/               # Uploaded files storage
│   ├── index.js               # Server entry point
│   └── package.json           # Backend dependencies
│
├── assets/
│   └── images/                # App images and assets
│
├── android/                   # Android-specific configuration
├── ios/                      # iOS-specific configuration
├── web/                      # Web-specific configuration
└── pubspec.yaml              # Flutter dependencies

```

## 📦 Prerequisites

### System Requirements
- **Flutter SDK**: 3.10 or higher
- **Dart SDK**: Included with Flutter
- **Node.js**: 16.x or higher
- **npm** or **yarn**: Latest version
- **PostgreSQL**: 12.x or higher
- **Git**: For version control

### Platform-Specific Requirements
- **Android**: Android Studio with SDK 21+
- **iOS**: Xcode 13+ (macOS only), CocoaPods
- **Development Environment**: VS Code or Android Studio recommended

## 🚀 Installation

### 1. Clone the Repository
```bash
git clone <repository-url>
cd flutter_application_1
```

### 2. Frontend Setup

#### Install Flutter Dependencies
```bash
flutter pub get
```

#### Verify Flutter Installation
```bash
flutter doctor
```

### 3. Backend Setup

#### Navigate to Backend Directory
```bash
cd backend
```

#### Install Node Dependencies
```bash
npm install
```

#### Setup Database
```bash
# Generate Prisma Client
npm run db:generate

# Run database migrations
npm run db:migrate

# (Optional) Seed database with test data
npm run db:seed
```

## ⚙️ Configuration

### Backend Configuration

Create a `.env` file in the `backend/` directory:

```env
# Database Configuration
DATABASE_URL="postgresql://username:password@localhost:5432/sitetracker"

# JWT Configuration
JWT_SECRET="your-super-secret-jwt-key-change-this-in-production"
JWT_EXPIRES_IN="7d"

# Server Configuration
PORT=3000
NODE_ENV=development

# File Upload Configuration
MAX_FILE_SIZE=5242880  # 5MB in bytes
UPLOAD_DIR=./uploads
```

### Frontend Configuration

Update the API base URL in your Flutter app (typically in a config or service file):

```dart
// lib/services/api_config.dart or similar
static const String baseUrl = 'http://localhost:3000/api';
// For Android Emulator: 'http://10.0.2.2:3000/api'
// For iOS Simulator: 'http://localhost:3000/api'
// For Physical Device: 'http://YOUR_LOCAL_IP:3000/api'
```

### Database Setup

1. **Install PostgreSQL** on your system
2. **Create a new database**:
   ```sql
   CREATE DATABASE sitetracker;
   ```
3. **Update the `DATABASE_URL`** in `.env` with your credentials

## 🏃 Running the Application

### Start the Backend Server

```bash
cd backend

# Development mode with auto-reload
npm run dev

# Production mode
npm start
```

The backend will start at `http://localhost:3000`

### Run the Flutter App

```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter devices  # List available devices
flutter run -d <device-id>

# Run in release mode
flutter run --release
```

### Platform-Specific Commands

```bash
# Android
flutter run -d android

# iOS (macOS only)
flutter run -d ios

# Web
flutter run -d chrome
```

## 👥 User Roles

### Admin
- **Permissions**: Full system access
- **Capabilities**: 
  - Manage all sites, workers, and coordinators
  - Create global announcements
  - View comprehensive attendance reports
  - Assign users to sites

### Site-Coordinator
- **Permissions**: Limited to assigned sites
- **Capabilities**:
  - Manage workers in assigned sites
  - Create site-specific announcements
  - View attendance for assigned sites
  - Punch-in/punch-out attendance

### Worker
- **Permissions**: Personal data only
- **Capabilities**:
  - Punch-in/punch-out with GPS and selfie
  - View personal attendance history
  - View announcements for assigned sites

## 🔌 API Endpoints

### Authentication
```
POST   /api/auth/register          # User registration
POST   /api/auth/login             # User login
GET    /api/auth/profile           # Get user profile
PUT    /api/auth/profile           # Update user profile
```

### Attendance
```
POST   /api/attendance/punch-in    # Punch in attendance
POST   /api/attendance/punch-out   # Punch out attendance
GET    /api/attendance/my-history  # Get user attendance history
GET    /api/attendance/filter      # Filter attendance records
```

### Sites
```
GET    /api/sites                  # Get all sites
POST   /api/sites                  # Create new site
GET    /api/sites/:id              # Get site by ID
PUT    /api/sites/:id              # Update site
DELETE /api/sites/:id              # Delete site
```

### Users
```
GET    /api/users                  # Get all users
GET    /api/users/:id              # Get user by ID
POST   /api/users/assign-site      # Assign user to site
GET    /api/users/site/:siteId     # Get users by site
DELETE /api/users/unassign/:id     # Unassign user from site
```

### Announcements
```
GET    /api/announcements          # Get all announcements
POST   /api/announcements          # Create announcement
GET    /api/announcements/:id      # Get announcement by ID
PUT    /api/announcements/:id      # Update announcement
DELETE /api/announcements/:id      # Deactivate announcement
```

## 🗄️ Database Schema

### Main Tables

#### users
- User accounts (Admin, Site-Coordinator, Worker)
- Authentication credentials
- Profile information

#### sites
- Construction site details
- GPS coordinates
- Site codes and addresses

#### attendance
- Daily attendance records
- Punch-in/punch-out times and locations
- Selfie URLs
- Total hours worked

#### announcements
- Site-specific or global announcements
- Priority levels
- Expiry dates
- Active status

#### site_user_assignments
- User-site relationships
- Role assignments per site

## 📸 Screenshots

<!-- Add screenshots here when available -->

*Screenshots coming soon...*

## 🧪 Testing

### Backend Testing
```bash
cd backend
npm test
```

Refer to `backend/TESTING_GUIDE.md` for detailed API testing instructions.

### Frontend Testing
```bash
flutter test
```

## 🔒 Security Features

- JWT-based authentication
- Bcrypt password hashing
- Helmet.js security headers
- CORS protection
- SQL injection prevention (Prisma ORM)
- Secure file upload validation
- Role-based access control

## 🚀 Deployment

### Backend Deployment
- Deploy to services like Heroku, AWS, DigitalOcean, or Railway
- Set up PostgreSQL database on cloud provider
- Configure environment variables
- Run migrations: `npm run db:migrate`

### Mobile App Deployment

#### Android
```bash
flutter build apk --release          # Build APK
flutter build appbundle --release    # Build App Bundle for Play Store
```

#### iOS (macOS only)
```bash
flutter build ios --release
# Then archive and upload via Xcode
```

## 📝 License

This project is proprietary and confidential.

## 🤝 Contributing

This is a private project. Contact the repository owner for contribution guidelines.

## 📧 Support

For support, please contact the development team.

---

**Version**: 0.1.0  
**Last Updated**: December 2025  
**Developed with**: Flutter & Node.js
