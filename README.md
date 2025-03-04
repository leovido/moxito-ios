# Moxito iOS App

![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%2017.0-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
[![codecov](https://codecov.io/gh/leovido/moxito-ios/branch/main/graph/badge.svg?token=your-token)](https://codecov.io/gh/leovido/moxito-ios)
[![Tests](https://github.com/leovido/moxito-ios/actions/workflows/test.yml/badge.svg)](https://github.com/leovido/moxito-ios/actions/workflows/test.yml)

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

### Diagram

```mermaid
graph TD
    subgraph "UI Layer"
        A[MoxieTrackerApp]
        B[OnboardingView]
        C[ContentView]
        D[ErrorView]
    end

    subgraph "View Models"
        E[AuthViewModel]
        F[MoxieViewModel]
        G[MoxieClaimViewModel]
        H[StepCountViewModel]
    end

    subgraph "Services Layer"
        I[AuthenticationService]
        J[KeychainService]
        K[MoxieClient]
        L[ErrorHandler]
    end

    subgraph "Data Layer"
        M[UserDefaults]
        N[Keychain]
        O[HealthKit]
    end

    subgraph "External Services"
        P[Sentry]
        Q[DevCycle]
        R[Farcaster API]
    end

    %% App Flow
    A --> |Initializes|E
    A --> |Initializes|F
    A --> |Initializes|G
    A --> |Initializes|H

    %% View Dependencies
    B --> |Uses|E
    C --> |Uses|F
    C --> |Uses|G
    C --> |Uses|H

    %% ViewModel -> Service Dependencies
    E --> |Auth Requests|I
    E --> |Store Credentials|J
    F --> |API Requests|K
    G --> |API Requests|K

    %% Service -> Data Layer
    I --> |Store Session|M
    J --> |Secure Storage|N
    K --> |Cache Data|M
    H --> |Health Data|O

    %% Error Handling
    L --> |Log Errors|P
    E --> |Report Errors|L
    F --> |Report Errors|L
    G --> |Report Errors|L

    %% External Integration
    K --> |API Calls|R
    A --> |Feature Flags|Q

    classDef viewLayer fill:#d4eaf7,stroke:#3498db,stroke-width:2px
    classDef viewModelLayer fill:#b5e7a0,stroke:#82b74b,stroke-width:2px
    classDef serviceLayer fill:#ffb7b2,stroke:#e74c3c,stroke-width:2px
    classDef dataLayer fill:#f7dc6f,stroke:#f1c40f,stroke-width:2px
    classDef externalLayer fill:#d7bde2,stroke:#8e44ad,stroke-width:2px

    class A,B,C,D viewLayer
    class E,F,G,H viewModelLayer
    class I,J,K,L serviceLayer
    class M,N,O dataLayer
    class P,Q,R externalLayer
```

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
