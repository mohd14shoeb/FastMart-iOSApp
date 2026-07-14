# FastMart — iOS App (MVVM-C Architecture)

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         APP COORDINATOR                             │
│                 (Root — owns everything)                            │
│   ┌───────────┐                          ┌──────────────────────┐   │
│   │   Auth    │  ── login success ──►     │       Main           │   │
│   │Coordinator│                          │    Coordinator        │   │
│   │           │                          │                       │   │
│   │ • Login   │                          │ • TabBarController    │   │
│   │ • Forgot  │                          │   ├─ Home (grid)      │   │
│   │   Password│                          │   ├─ Cart (list)      │   │
│   └───────────┘                          │   ├─ Services (list)  │   │
│                                          │   └─ Help (FAQ)       │   │
│                                          │                       │   │
│                                          │ • SideMenu (left)     │   │
│                                          │ • Logout → Auth       │   │
│                                          └───────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

## Project Structure

```
FastMart/
├── App/
│   ├── AppDelegate.swift          ← @main entry point
│   ├── SceneDelegate.swift        ← Window + root coordinator
│   └── Info.plist
│
├── Core/
│   ├── Coordinator/
│   │   ├── Coordinator.swift      ← Base protocol
│   │   ├── AppCoordinator.swift   ← Root: auth ↔ main switch
│   │   ├── AuthCoordinator.swift  ← Login → ForgotPassword flow
│   │   └── MainCoordinator.swift  ← TabBar + SideMenu + logout
│   │
│   └── Extensions/
│       └── UIKit+Extensions.swift ← Shake, password toggle, keyboard
│
├── Modules/
│   ├── Auth/
│   │   ├── Login/
│   │   │   ├── LoginModel.swift
│   │   │   ├── LoginViewModel.swift
│   │   │   └── LoginViewController.swift
│   │   │
│   │   └── ForgotPassword/
│   │       ├── ForgotPasswordModel.swift
│   │       ├── ForgotPasswordViewModel.swift
│   │       └── ForgotPasswordViewController.swift
│   │
│   └── Main/
│       ├── Home/
│       │   ├── HomeViewModel.swift
│       │   └── HomeViewController.swift       ← UICollectionView grid
│       ├── Cart/
│       │   ├── CartViewModel.swift
│       │   └── CartViewController.swift       ← UITableView + stepper
│       ├── Services/
│       │   ├── ServicesViewModel.swift
│       │   └── ServicesViewController.swift   ← UITableView list
│       ├── Help/
│       │   ├── HelpViewModel.swift
│       │   └── HelpViewController.swift       ← FAQ UITableView
│       └── SideMenu/
│           ├── SideMenuViewModel.swift
│           └── SideMenuViewController.swift   ← Left drawer
```

## MVVM-C Principles Applied

### 1. **Model** — Pure data, no logic
- `LoginModel`, `ForgotPasswordModel` — simple structs
- `HomeViewModel.DashboardItem`, `CartViewModel.CartItem` — view-specific DTOs

### 2. **ViewModel** — Business logic, no UIKit imports
- Owns state (`email`, `password`, `isLoading`, `errorMessage`)
- Exposes `onStateChanged` closure for UIKit binding
- No reference to ViewController — fully testable

### 3. **ViewController** — UIKit only, no business logic
- Owns UI components (labels, text fields, collection views)
- Binds to `viewModel.onStateChanged` for UI updates
- Delegates actions to ViewModel
- Never imports Model directly

### 4. **Coordinator** — Navigation only
- Each coordinator owns a `UINavigationController`
- Spawns child coordinators for sub-flows
- ViewControllers never know about other screens
- Callbacks (`onLoginSuccess`, `onLogout`) decouple flows

## Data Flow (one direction)

```
User Action
    │
    ▼
ViewController  ─── delegate ───►  ViewModel  ─── mutate ───►  Model
    ▲                                  │
    │                                  │ onStateChanged
    └────────  update UI  ◄───────────┘
```

## Key Design Choices

| Decision | Rationale |
|---|---|
| **No Storyboard** | All UI in code — merge-friendly, explicit, no XML conflicts |
| **Diffable Data Source** | Native animations, avoids reloadData bugs |
| **iOS 17+ only** | Modern APIs, no legacy compatibility cruft |
| **Edge pan gesture** | Natural swipe-to-open side menu |
| **Singleton Redis-style coordinators** | Each coordinator lives for its flow lifecycle |

## Demo Credentials

- Email: `test@example.com`
- Password: `password`

## Minimum Deployment Target

**iOS 17.0+**
