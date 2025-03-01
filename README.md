# Moxito iOS App

![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%2017.0-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

Moxito is an iOS application that integrates with Farcaster's social protocol to track and manage Moxie rewards. The app showcases modern iOS development practices, SwiftUI implementation, and robust architecture patterns.

## 📱 Screenshots

<p><img src="./Screenshots/iphone_app_store_moxito_1.png" width="33%" />
<img src="./Screenshots/iphone_app_store_moxito_2.png" width="33%" />
<img src="./Screenshots/iphone_app_store_moxito_3.png" width="33%" />
<img src="./Screenshots/iphone_app_store_moxito_7.png" width="33%" /></p>

## 🌟 Features

- **Farcaster Authentication**: Secure sign-in using Farcaster credentials
- **Real-time Moxie Tracking**: Monitor your Moxie rewards and statistics
- **HealthKit Integration**: Track steps and health metrics
- **Background Updates**: Automatic refresh of Moxie data
- **Push Notifications**: Customizable alerts for rewards and milestones
- **Secure Storage**: Keychain integration for sensitive data
- **Widget Support**: Home screen widgets for quick stats

## 🏗 Architecture & Technical Stack

### Core Technologies
- SwiftUI for modern UI development
- Combine for reactive programming
- Swift concurrency (async/await)
- HealthKit integration
- Background Tasks framework
- Keychain Services
- UserDefaults for persistence
- Sentry for error tracking

### Design Patterns
- MVVM Architecture
- Protocol-oriented programming
- Dependency injection
- Actor-based concurrency
- Repository pattern for data management

## 📱 Key Components

### Authentication
The app implements a secure authentication flow using `ASWebAuthenticationSession` and Sign in with Farcaster login.

### Data Management
Robust data handling with protocol-based services:

- `MoxitoClient`: Handles Farcaster authentication and data fetching
- `HealthKitService`: Manages health data integration
- `StepCountViewModel`: Centralizes step count data and calculations

### Background Processing
Implements sophisticated background task handling for data updates:

- Background tasks for data synchronization
- Background processing of health data
- Background processing of step count data

## 🔒 Security Features

- Secure credential storage using Keychain
- URL scheme validation for deep links
- Error handling with Sentry integration
- Encrypted data persistence

## 🎯 Code Quality

- SwiftLint integration for code consistency
- Comprehensive error handling
- Unit tests
- Documentation and code comments
- Type-safe implementations

## 📊 Performance Optimizations

- Efficient caching mechanisms
- Background task optimization
- Memory management best practices
- Network request batching

## 🛠 Development Setup

1. Clone the repository
2. Open `fc-poc-wf.xcworkspace` in Xcode
3. Select the `Moxito-DEBUG` scheme
4. Run the app on a simulator or connected device

## 📦 Dependencies

- Sentry for error tracking
- MoxieLib for core functionality
- MoxitoLib for additional features

## 🤝 Contributing

We welcome contributions! Please open an issue or submit a pull request.

## 👥 Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- [Website](https://moxito.xyz)
- [Warpcast](https://warpcast.com/moxito)

## 📫 Contact

For any inquiries, please open an issue or contact me on [Warpcast](https://warpcast.com/leovido.eth).
