# 💰 PettyCashPro

A modern iOS app built with **SwiftUI** for managing petty cash expense requests in an organisation. Staff members can submit requests, scan receipts, and track status — while managers can approve/reject, control budgets, and generate monthly reports.

---

## 📱 Features

### 👤 Authentication
- Email & password login
- **Face ID / Touch ID** biometric login
- Role-based access — **Staff** or **Manager**
- Session persistence using `UserDefaults`

### 🧑‍💼 Staff Features
- Submit petty cash expense requests with amount, category, reason
- Mark requests as **Urgent**
- Scan receipts using the camera (OCR support)
- View personal request history with status filters (Pending / Approved / Rejected)
- Dashboard showing pending amount, approved this month, request counts
- Find nearby **ATM locations** using MapKit

### 🏢 Manager Features
- Dashboard with summary stats (total requests, pending count, budget used)
- Approve or reject requests with comments
- **Budget Control** — set and track budgets per expense category
- **Monthly Report** — view and export expense reports as PDF
- Approve urgent requests with priority view

### 🔔 Notifications
- Push notifications for new requests (staff → manager)
- Local notifications for approval/rejection updates
- Badge count management

### 🍎 Siri Shortcuts
- Submit expense requests via Siri using `AppIntents`

---

## 🗂️ Project Structure

```
PettyCashPro/
├── Models/
│   └── Models.swift              # AppUser, ExpenseRequest, BudgetCategory, Enums
├── ViewModels/
│   ├── AuthViewModel.swift       # Login, logout, biometric auth
│   ├── StaffViewModel.swift      # Submit requests, load history
│   └── ManagerViewModel.swift    # Approve/reject, budget control
├── Views/
│   ├── Auth/                     # LoginView, RoleSelectionView, RootView
│   ├── Staff/                    # Dashboard, SubmitRequest, MyRequests, ATMLocation, ReceiptScanner
│   ├── Manger/                   # Dashboard, ApprovalList, BudgetControl, MonthlyReport
│   └── Shared/                   # DesignSystem (colors, fonts, components)
├── Services/
│   ├── NetworkService.swift      # All API calls (login, submit, approve, etc.)
│   ├── NotificationService.swift # Push & local notifications
│   ├── BiometricAuthService.swift# Face ID / Touch ID
│   ├── PDFReportGenerator.swift  # Monthly PDF export
│   └── SiriIntentHandler.swift   # Siri Shortcuts integration
└── Core/
    ├── AppSettings.swift         # User preferences (dark mode, biometrics)
    └── Splash/SplashView.swift   # Launch screen
```

---

## 🛠️ Tech Stack

| Technology | Usage |
|---|---|
| SwiftUI | All UI screens |
| Combine | Reactive state management |
| LocalAuthentication | Face ID / Touch ID |
| UserNotifications | Push & local notifications |
| MapKit / CoreLocation | ATM location finder |
| Vision / VisionKit | Receipt scanning (OCR) |
| AppIntents | Siri Shortcuts |
| URLSession | REST API networking |
| UserDefaults | Session & settings persistence |

---

## 🔗 Backend API

The app connects to a REST backend. Key endpoints used:

| Method | Endpoint | Description |
|---|---|---|
| POST | `/auth/login` | Login and get JWT token |
| GET | `/requests/my` | Staff: get own requests |
| POST | `/requests` | Staff: submit new request |
| GET | `/requests/all` | Manager: get all requests |
| PATCH | `/requests/:id/review` | Manager: approve or reject |
| GET | `/budget` | Get budget categories |
| PUT | `/budget` | Update budget allocations |

Authentication is done via **Bearer token** in headers.

---

## 💵 Expense Categories

| Category | Icon |
|---|---|
| Food | 🍴 |
| Transport | 🚗 |
| Stationery | 📄 |
| Equipment | 🖥️ |
| Medical | ➕ |
| Utilities | ⚡ |
| Other | ⭕ |

---

## 🧪 Running Unit Tests

Tests are written using **XCTest** and cover Models, AuthViewModel, StaffViewModel, and Enums.

```
Press Cmd + U in Xcode to run all tests
```

Test file: `PettyCashProTests/PettyCashProTests.swift`

---

## 🚀 Getting Started

1. Clone the repository
2. Open `PettyCashPro.xcodeproj` in Xcode
3. Set your backend API base URL inside `NetworkService.swift`
4. Build and run on a real device (Face ID needs real device, not simulator)

---

## 👨‍💻 Developer

**Keshana Liyanaarachchi**
Built with ❤️ using SwiftUI
