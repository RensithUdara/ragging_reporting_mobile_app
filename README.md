# 🛡️ Ragging Reporting Mobile App

A comprehensive mobile application for reporting ragging incidents anonymously and securely, built with Flutter and Supabase backend.

## 📱 Overview

The Ragging Reporting Mobile App provides a safe platform for students and individuals to report ragging incidents in educational institutions. The app ensures anonymity, secure data handling, and efficient complaint management through a modern MVC architecture.

## ✨ Features

### 🔐 Authentication System
- **User Registration** with email verification
- **Secure Login** with encrypted credentials
- **Forgot Password** functionality
- **Logout** with secure session management

### 📊 Dashboard
- **Statistics Overview** with visual charts
- **Recent Complaints** tracking
- **Quick Actions** for easy navigation
- **User Profile** summary

### 📝 Complaint Management
- **Report Incidents** with detailed forms
- **Anonymous Reporting** option
- **Evidence Upload** (photos, documents)
- **Status Tracking** for submitted complaints
- **My Complaints** history

### 👤 User Profile
- **Profile Management** 
- **Account Settings**
- **Help & Support**
- **Notification Preferences**

### 🔔 Notification System
- **Real-time Updates** on complaint status
- **System Notifications**
- **Push Notifications** (database-based)

### 🔒 Security Features
- **End-to-end Encryption** for sensitive data
- **Anonymous Reporting** capabilities
- **Secure File Storage**
- **Row-level Security** with Supabase

## 🏗️ Architecture

The app follows the **Model-View-Controller (MVC)** pattern for clean code organization:

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user_model.dart
│   ├── complaint_model.dart
│   ├── notification_model.dart
│   └── dashboard_stats_model.dart
├── views/                    # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── dashboard/
│   │   └── home_screen.dart
│   ├── complaint/
│   │   ├── report_incident_screen.dart
│   │   ├── check_status_screen.dart
│   │   └── my_complaints_screen.dart
│   ├── profile/
│   │   ├── profile_screen.dart
│   │   └── notifications_screen.dart
│   └── splash_screen.dart
├── controllers/              # Business logic & state management
│   ├── auth_controller.dart
│   ├── complaint_controller.dart
│   └── notification_controller.dart
├── services/                 # Backend integration
│   ├── auth_service.dart
│   ├── complaint_service.dart
│   ├── notification_service.dart
│   └── storage_service.dart
├── widgets/                  # Reusable UI components
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   ├── custom_card.dart
│   └── stats_card.dart
├── theme/                    # App theming
│   └── app_theme.dart
├── constants/               # App constants
│   └── app_constants.dart
└── utils/                   # Utility functions
    └── validators.dart
```

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** (>=3.0.0)
- **Dart** (>=3.0.0)
- **Android Studio** / **VS Code**
- **Android SDK** (API level 21+)
- **Supabase Account** for backend services

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/RensithUdara/ragging_reporting_mobile_app.git
   cd ragging_reporting_mobile_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment Setup**
   - Create a `.env` file in the root directory
   - Add your Supabase configuration:
   ```env
   SUPABASE_URL=your_supabase_project_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
   ```

4. **Database Setup**
   - Set up your Supabase project
   - Run the SQL migrations (see Database Schema section)
   - Configure Row Level Security (RLS)

5. **Run the app**
   ```bash
   flutter run
   ```

## 🗄️ Database Schema

### Users Table
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR UNIQUE NOT NULL,
    full_name VARCHAR NOT NULL,
    phone_number VARCHAR,
    student_id VARCHAR,
    institution VARCHAR,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

### Complaints Table
```sql
CREATE TABLE complaints (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    complaint_number VARCHAR UNIQUE NOT NULL,
    incident_date DATE NOT NULL,
    incident_time VARCHAR NOT NULL,
    incident_location VARCHAR NOT NULL,
    category VARCHAR NOT NULL,
    description TEXT NOT NULL,
    is_anonymous BOOLEAN DEFAULT FALSE,
    status VARCHAR DEFAULT 'pending',
    priority VARCHAR DEFAULT 'medium',
    submission_date TIMESTAMP DEFAULT NOW(),
    evidence_path VARCHAR,
    evidence_file_name VARCHAR,
    evidence_file_type VARCHAR,
    public_notes TEXT,
    admin_notes TEXT,
    assigned_to UUID,
    resolved_at TIMESTAMP,
    resolution_notes TEXT,
    witnesses TEXT[],
    metadata JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

### Notifications Table
```sql
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    title VARCHAR NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR NOT NULL,
    data JSONB,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    read_at TIMESTAMP
);
```

## 🔧 Configuration

### Android Configuration

Update `android/app/build.gradle`:
```gradle
android {
    compileSdk = 34
    
    defaultConfig {
        minSdk = 21
        targetSdk = 34
    }
}
```

### iOS Configuration

Update `ios/Runner/Info.plist` for camera and storage permissions:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to capture evidence photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select evidence images</string>
```

## 📦 Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.5
  
  # Backend & Database
  supabase_flutter: ^1.10.25
  
  # State Management
  provider: ^6.1.1
  
  # Environment
  flutter_dotenv: ^5.1.0
  
  # UI Components
  lottie: ^2.6.0
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  
  # Storage & Security
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2
  path_provider: ^2.1.1
  
  # Media & Files
  image_picker: ^1.0.4
  file_picker: ^6.1.1
  
  # Utilities
  intl: ^0.18.1
  uuid: ^4.2.1
  url_launcher: ^6.1.14
  http: ^1.1.0
  
  # Charts
  fl_chart: ^0.64.0
  
  # Navigation
  go_router: ^12.1.3
  
  # Animations
  flutter_staggered_animations: ^1.1.1
```

## 🎨 Design System

### Color Palette
- **Primary**: `#2E7D32` (Green)
- **Secondary**: `#FFA726` (Orange)
- **Surface**: `#FFFFFF` (White)
- **Error**: `#D32F2F` (Red)
- **Text Primary**: `#212121` (Dark Grey)
- **Text Secondary**: `#757575` (Grey)

### Typography
- **Headings**: Roboto Bold
- **Body Text**: Roboto Regular
- **Captions**: Roboto Light

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

### Integration Tests
```bash
flutter test integration_test/
```

## 📱 Build & Release

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🔐 Security Considerations

### Data Protection
- All sensitive data is encrypted using AES-256
- User passwords are hashed using bcrypt
- API keys are stored securely using Flutter Secure Storage

### Privacy Features
- Anonymous reporting capabilities
- No tracking of user location without consent
- GDPR compliant data handling

### Backend Security
- Row Level Security (RLS) enabled on all tables
- JWT authentication for API access
- Rate limiting on sensitive endpoints

## 🚀 Deployment

### Supabase Configuration
1. Create a new Supabase project
2. Set up authentication providers
3. Configure storage buckets for file uploads
4. Set up database triggers for notifications

### App Store Deployment
1. **Google Play Store**
   - Generate signed APK/AAB
   - Create store listing
   - Upload release build

2. **Apple App Store**
   - Archive and validate app
   - Upload to App Store Connect
   - Submit for review

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style Guidelines
- Follow Flutter/Dart style guidelines
- Use meaningful variable names
- Add comments for complex logic
- Write unit tests for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support and questions:
- **Email**: support@raggingapp.com
- **Issues**: [GitHub Issues](https://github.com/RensithUdara/ragging_reporting_mobile_app/issues)
- **Documentation**: [Wiki](https://github.com/RensithUdara/ragging_reporting_mobile_app/wiki)

## 🙏 Acknowledgments

- **Flutter Team** for the amazing framework
- **Supabase** for the backend infrastructure
- **Material Design** for UI/UX guidelines
- **Open Source Community** for various packages used

## 📊 Project Status

- ✅ **Authentication System** - Complete
- ✅ **Dashboard** - Complete
- ✅ **Complaint Management** - Complete
- ✅ **User Profile** - Complete
- ✅ **Notifications** - Complete (Database-based)
- 🔄 **Local Push Notifications** - Pending
- 🔄 **Advanced Analytics** - Future Enhancement
- 🔄 **Multi-language Support** - Future Enhancement

## 📈 Version History

### v1.0.0 (Current)
- Initial release with core features
- MVC architecture implementation
- Supabase backend integration
- Complete authentication flow
- Complaint management system
- User profile and settings
- Notification system

### Future Versions
- **v1.1.0** - Local push notifications
- **v1.2.0** - Advanced analytics dashboard
- **v1.3.0** - Multi-language support
- **v2.0.0** - Admin panel integration

---

**Made with ❤️ by the Ragging Reporting Team**

*Building a safer educational environment, one report at a time.*
